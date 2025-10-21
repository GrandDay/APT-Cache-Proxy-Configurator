#!/bin/bash

#########################
# CUSTOMIZE THESE VALUES BEFORE RUNNING
#########################
APT_PROXY_SERVER="http://10.1.50.183:3142"    # Your apt-cacher-ng server address
SSH_USER="root"                                # SSH user for VM access
SSH_KEY_PATH="$HOME/.ssh/id_rsa"              # Path to SSH private key
SSH_PUBLIC_KEY_PATH="$HOME/.ssh/id_rsa.pub"   # Path to SSH public key
CUSTOM_SSH_PUBLIC_KEY=""                       # Optional: Paste existing SSH public key

#########################
# DO NOT EDIT BELOW THIS LINE
#########################
APT_PROXY_CONFIG_FILE="/etc/apt/apt.conf.d/00aptproxy"
APT_PROXY_CONTENT="Acquire::http::Proxy \"${APT_PROXY_SERVER}\";"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if SSH key exists, if not generate it or use custom key
ensure_ssh_key() {
    log_info "Checking SSH key configuration..."
    
    if [ ! -f "$SSH_KEY_PATH" ]; then
        log_warning "SSH key not found at $SSH_KEY_PATH"
        
        # Check if custom public key is provided
        if [ -n "$CUSTOM_SSH_PUBLIC_KEY" ]; then
            log_info "Using provided custom SSH public key..."
            
            # Create .ssh directory if it doesn't exist
            mkdir -p "$(dirname "$SSH_KEY_PATH")"
            mkdir -p "$(dirname "$SSH_PUBLIC_KEY_PATH")"
            
            # Write the custom public key
            echo "$CUSTOM_SSH_PUBLIC_KEY" > "$SSH_PUBLIC_KEY_PATH"
            
            if [ $? -eq 0 ]; then
                log_success "Custom SSH public key installed at $SSH_PUBLIC_KEY_PATH"
                log_warning "Note: Private key not available - you'll need password auth or the matching private key"
                return 0
            else
                log_error "Failed to write custom SSH public key"
                exit 1
            fi
        fi
        
        # Ask to generate new key
        read -p "Generate new SSH key? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Generating SSH key..."
            
            # Create .ssh directory if it doesn't exist
            mkdir -p "$(dirname "$SSH_KEY_PATH")"
            
            ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "proxmox-apt-cache-config"
            if [ $? -eq 0 ]; then
                log_success "SSH key generated successfully"
            else
                log_error "Failed to generate SSH key"
                exit 1
            fi
        else
            log_error "SSH key required for VM configuration. Exiting."
            exit 1
        fi
    else
        log_success "SSH key found at $SSH_KEY_PATH"
    fi
}

# Copy SSH key to target
copy_ssh_key_to_target() {
    local target="$1"
    log_info "Checking SSH access to $target..."
    
    # Test SSH connection
    if ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" exit 2>/dev/null; then
        log_success "SSH key already configured for $target"
        return 0
    fi
    
    log_warning "SSH key not configured for $target"
    log_info "Copying SSH key to $target (you may be prompted for password)..."
    
    ssh-copy-id -i "$SSH_PUBLIC_KEY_PATH" "$target"
    
    if [ $? -eq 0 ]; then
        log_success "SSH key copied successfully to $target"
        return 0
    else
        log_error "Failed to copy SSH key to $target"
        return 1
    fi
}

# Check if apt proxy is already configured
check_apt_proxy_configured() {
    local target_type="$1"
    local target_id="$2"
    
    case "$target_type" in
        lxc)
            if pct exec "$target_id" -- test -f "$APT_PROXY_CONFIG_FILE" 2>/dev/null; then
                return 0
            fi
            ;;
        vm)
            if ssh -o BatchMode=yes "$target_id" "test -f $APT_PROXY_CONFIG_FILE" 2>/dev/null; then
                return 0
            fi
            ;;
        local)
            if [ -f "$APT_PROXY_CONFIG_FILE" ]; then
                return 0
            fi
            ;;
    esac
    return 1
}

# Function: Configure apt proxy for single LXC container
configure_lxc_single() {
    local ctid="$1"
    
    log_info "Checking LXC container $ctid status..."
    
    # Check if container exists
    if ! pct status "$ctid" &>/dev/null; then
        log_error "Container $ctid does not exist"
        return 1
    fi
    
    # Check if container is running
    if ! pct status "$ctid" | grep -q "running"; then
        log_error "Container $ctid is not running"
        return 1
    fi
    
    # Check if already configured
    if check_apt_proxy_configured "lxc" "$ctid"; then
        log_warning "Container $ctid already has apt proxy configured"
        read -p "Reconfigure anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping container $ctid"
            return 0
        fi
    fi
    
    log_info "Configuring LXC container $ctid..."
    
    if pct exec "$ctid" -- bash -c "echo 'Acquire::http::Proxy \"${APT_PROXY_SERVER}\";' | tee ${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
        log_success "Container $ctid configured successfully"
        return 0
    else
        log_error "Failed to configure container $ctid"
        return 1
    fi
}

# Function: Configure apt proxy for all LXC containers
configure_lxc_all() {
    log_info "Discovering LXC containers..."
    
    local containers=$(pct list | awk 'NR>1 {print $1}')
    
    if [ -z "$containers" ]; then
        log_warning "No LXC containers found"
        return 0
    fi
    
    local total=$(echo "$containers" | wc -l)
    local success=0
    local failed=0
    local skipped=0
    
    log_info "Found $total LXC container(s)"
    echo ""
    
    for ct in $containers; do
        if configure_lxc_single "$ct"; then
            ((success++))
        else
            if [ $? -eq 0 ]; then
                ((skipped++))
            else
                ((failed++))
            fi
        fi
        echo ""
    done
    
    log_info "Summary: $success configured, $skipped skipped, $failed failed out of $total total"
}

# Function: Configure apt proxy for single VM via SSH
configure_vm_single() {
    local vm_address="$1"
    local vm_user="${2:-$SSH_USER}"
    local target="${vm_user}@${vm_address}"
    
    log_info "Configuring VM at $vm_address..."
    
    # Ensure SSH key is set up
    ensure_ssh_key
    
    # Check and copy SSH key if needed
    if ! copy_ssh_key_to_target "$target"; then
        log_error "Cannot establish SSH connection to $target"
        return 1
    fi
    
    # Check if already configured
    if check_apt_proxy_configured "vm" "$target"; then
        log_warning "VM $vm_address already has apt proxy configured"
        read -p "Reconfigure anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping VM $vm_address"
            return 0
        fi
    fi
    
    log_info "Applying configuration to VM $vm_address..."
    
    if ssh -o BatchMode=yes "$target" "echo 'Acquire::http::Proxy \"${APT_PROXY_SERVER}\";' | sudo tee ${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
        log_success "VM $vm_address configured successfully"
        return 0
    else
        log_error "Failed to configure VM $vm_address"
        return 1
    fi
}

# Function: Configure apt proxy locally (for current system)
configure_local() {
    log_info "Configuring local system..."
    
    # Check if already configured
    if check_apt_proxy_configured "local"; then
        log_warning "Local system already has apt proxy configured"
        read -p "Reconfigure anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Skipping local system configuration"
            return 0
        fi
    fi
    
    log_info "Applying configuration to local system..."
    
    if echo "Acquire::http::Proxy \"${APT_PROXY_SERVER}\";" | sudo tee "${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
        log_success "Local system configured successfully"
        
        # Verify configuration
        log_info "Verifying configuration..."
        if sudo apt update &>/dev/null; then
            log_success "APT cache proxy is working correctly"
        else
            log_warning "APT update failed - proxy may not be reachable"
        fi
        return 0
    else
        log_error "Failed to configure local system"
        return 1
    fi
}

# Function: Remove apt proxy configuration
remove_proxy() {
    local target_type="$1"
    local target_id="$2"
    
    log_info "Removing apt proxy configuration from $target_type: $target_id..."
    
    case "$target_type" in
        lxc)
            if ! check_apt_proxy_configured "lxc" "$target_id"; then
                log_warning "Container $target_id does not have apt proxy configured"
                return 0
            fi
            
            if pct exec "$target_id" -- rm -f "${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
                log_success "Removed apt proxy from container $target_id"
                return 0
            else
                log_error "Failed to remove apt proxy from container $target_id"
                return 1
            fi
            ;;
        vm)
            ensure_ssh_key
            
            if ! copy_ssh_key_to_target "$target_id"; then
                log_error "Cannot establish SSH connection to $target_id"
                return 1
            fi
            
            if ! check_apt_proxy_configured "vm" "$target_id"; then
                log_warning "VM $target_id does not have apt proxy configured"
                return 0
            fi
            
            if ssh -o BatchMode=yes "$target_id" "sudo rm -f ${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
                log_success "Removed apt proxy from VM $target_id"
                return 0
            else
                log_error "Failed to remove apt proxy from VM $target_id"
                return 1
            fi
            ;;
        local)
            if ! check_apt_proxy_configured "local"; then
                log_warning "Local system does not have apt proxy configured"
                return 0
            fi
            
            if sudo rm -f "${APT_PROXY_CONFIG_FILE}" &>/dev/null; then
                log_success "Removed apt proxy from local system"
                return 0
            else
                log_error "Failed to remove apt proxy from local system"
                return 1
            fi
            ;;
        *)
            log_error "Unknown target type: $target_type"
            return 1
            ;;
    esac
}

# Main execution
main() {
    log_info "APT Cache Proxy Configuration Tool"
    log_info "APT Proxy Server: $APT_PROXY_SERVER"
    log_info "SSH User: $SSH_USER"
    log_info "SSH Key Path: $SSH_KEY_PATH"
    echo ""
    
    case "${1:-}" in
        lxc-single)
            if [ -z "$2" ]; then
                log_error "Missing container ID"
                echo "Usage: $0 lxc-single <CTID>"
                exit 1
            fi
            configure_lxc_single "$2"
            local exit_code=$?
            echo ""
            if [ $exit_code -eq 0 ]; then
                log_success "Operation completed successfully"
            else
                log_error "Operation failed with exit code $exit_code"
            fi
            exit $exit_code
            ;;
        lxc-all)
            configure_lxc_all
            local exit_code=$?
            echo ""
            if [ $exit_code -eq 0 ]; then
                log_success "Operation completed successfully"
            else
                log_error "Operation completed with errors"
            fi
            exit $exit_code
            ;;
        vm)
            if [ -z "$2" ]; then
                log_error "Missing VM address"
                echo "Usage: $0 vm <IP_ADDRESS> [username]"
                exit 1
            fi
            configure_vm_single "$2" "$3"
            local exit_code=$?
            echo ""
            if [ $exit_code -eq 0 ]; then
                log_success "Operation completed successfully"
            else
                log_error "Operation failed with exit code $exit_code"
            fi
            exit $exit_code
            ;;
        local)
            configure_local
            local exit_code=$?
            echo ""
            if [ $exit_code -eq 0 ]; then
                log_success "Operation completed successfully"
            else
                log_error "Operation failed with exit code $exit_code"
            fi
            exit $exit_code
            ;;
        remove)
            if [ -z "$2" ] || [ -z "$3" ]; then
                log_error "Missing arguments"
                echo "Usage: $0 remove <lxc|vm|local> <target>"
                exit 1
            fi
            remove_proxy "$2" "$3"
            local exit_code=$?
            echo ""
            if [ $exit_code -eq 0 ]; then
                log_success "Operation completed successfully"
            else
                log_error "Operation failed with exit code $exit_code"
            fi
            exit $exit_code
            ;;
        *)
            echo "APT Cache Proxy Configuration Tool"
            echo "===================================="
            echo ""
            echo "BEFORE USING: Edit the configuration at the top of this script:"
            echo "  - APT_PROXY_SERVER (default: http://10.1.50.183:3142)"
            echo "  - SSH_USER (default: root)"
            echo "  - SSH_KEY_PATH (default: \$HOME/.ssh/id_rsa)"
            echo ""
            echo "Usage: $0 {lxc-single|lxc-all|vm|local|remove} [arguments]"
            echo ""
            echo "Commands:"
            echo "  lxc-single <CTID>           - Configure single LXC container"
            echo "  lxc-all                     - Configure all LXC containers"
            echo "  vm <IP_ADDRESS> [username]  - Configure VM via SSH"
            echo "  local                       - Configure local system"
            echo "  remove <type> <target>      - Remove proxy configuration"
            echo ""
            echo "Examples:"
            echo "  $0 lxc-single 100"
            echo "  $0 lxc-all"
            echo "  $0 vm 10.1.50.10"
            echo "  $0 vm 10.1.50.10 myuser"
            echo "  $0 local"
            echo "  $0 remove lxc 100"
            echo "  $0 remove vm root@10.1.50.10"
            echo "  $0 remove local"
            echo ""
            echo "Standalone command (run directly inside VM/LXC/Host):"
            echo "  echo 'Acquire::http::Proxy \"http://10.1.50.183:3142\";' | sudo tee /etc/apt/apt.conf.d/00aptproxy"
            exit 1
            ;;
    esac
}

main "$@"
