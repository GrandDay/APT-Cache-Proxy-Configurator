# Release Checklist - v0.1.0

## Pre-Release Testing

### Local Testing

- [ ] Test proxy URL validation with valid input (<http://10.1.50.183:3142>)
- [ ] Test proxy URL validation with invalid input (malformed URLs)
- [ ] Test IP validation with valid IPs
- [ ] Test IP validation with invalid IPs (999.999.999.999, abc.def.ghi.jkl)
- [ ] Test port validation (1-65535 valid, 0 or 65536+ invalid)
- [ ] Test with undefined variables (should fail with set -u)
- [ ] Verify all functions properly quote variables

### Functional Testing

- [ ] `connect-to-apt-cache.sh local` - Configure local system successfully
- [ ] `connect-to-apt-cache.sh lxc-single <CTID>` - Configure single LXC
- [ ] `connect-to-apt-cache.sh lxc-all` - Configure all LXCs with summary
- [ ] `connect-to-apt-cache.sh vm <IP>` - Configure VM via SSH
- [ ] `connect-to-apt-cache.sh remove local` - Remove local config
- [ ] `connect-to-apt-cache.sh remove lxc <CTID>` - Remove LXC config
- [ ] `connect-to-apt-cache.sh remove vm <user@IP>` - Remove VM config

### Idempotency Testing

- [ ] Run `local` twice - Should prompt for reconfiguration on 2nd run
- [ ] Run `lxc-single` twice - Should prompt for reconfiguration on 2nd run
- [ ] Run `vm` twice - Should prompt for reconfiguration on 2nd run
- [ ] Verify `/etc/apt/apt.conf.d/00aptproxy` contains only our config

### Interactive Installer Testing

- [ ] Download and run interactive installer with defaults
- [ ] Download and run interactive installer with custom values
- [ ] Verify input validation catches bad IPs
- [ ] Verify input validation catches bad ports
- [ ] Verify custom SSH key option works
- [ ] Test cancellation at confirmation prompt

### Environment Variable Override Testing

- [ ] `APT_PROXY_SERVER=http://192.168.1.1:3142 connect-to-apt-cache.sh local`
- [ ] `SSH_USER=ubuntu connect-to-apt-cache.sh vm <IP>`
- [ ] Verify overrides work correctly

### Error Handling Testing

- [ ] Test with non-existent LXC container (should fail gracefully)
- [ ] Test with stopped LXC container (should fail with clear message)
- [ ] Test with unreachable VM IP (should timeout and fail)
- [ ] Test SSH key copy failure (wrong password)
- [ ] Test apt update failure (bad proxy config)

## Documentation Review

- [ ] README.md has correct installation instructions
- [ ] README.md includes security warnings for curl|bash
- [ ] README.md has "How It Works" section
- [ ] README.md documents HTTPS PassThroughPattern requirement
- [ ] GUIDE.md has comprehensive troubleshooting section
- [ ] SECURITY_HARDENING.md documents all changes
- [ ] All code examples in docs are accurate
- [ ] All URLs point to correct repository (GrandDay/apt-cache-config)
- [ ] License information is correct (MIT)

## Code Quality

- [ ] All scripts have `set -euo pipefail`
- [ ] All variables properly quoted
- [ ] All functions have consistent error handling
- [ ] All log messages use color-coded functions
- [ ] No bare `exit` calls (all use proper exit codes)
- [ ] No unchecked command execution
- [ ] ShellCheck workflow configured
- [ ] Run ShellCheck locally: `shellcheck src/connect-to-apt-cache.sh install-interactive.sh install.sh`

## Git Preparation

- [ ] Stage all changes: `git add -A`
- [ ] Commit with message: `git commit -m "v0.1.0: Security hardening and improvements"`
- [ ] Create annotated tag: `git tag -a v0.1.0 -m "Version 0.1.0 - Security Hardening Release"`
- [ ] Push changes: `git push origin main`
- [ ] Push tag: `git push origin v0.1.0`

## GitHub Release

- [ ] Create release from v0.1.0 tag
- [ ] Use title: "v0.1.0 - Security Hardening Release"
- [ ] Copy release notes from template below
- [ ] Attach `src/connect-to-apt-cache.sh` as release asset
- [ ] Attach `install-interactive.sh` as release asset
- [ ] Mark as "Latest Release"

## Post-Release

- [ ] Test installation from release tag:

  ```bash
  curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/v0.1.0/install-interactive.sh | bash
  ```

- [ ] Verify ShellCheck workflow runs on GitHub Actions
- [ ] Update any external documentation linking to the repo
- [ ] Announce release (if applicable)

## Rollback Plan

If critical issues are discovered:

1. Delete the tag:

   ```bash
   git tag -d v0.1.0
   git push origin :refs/tags/v0.1.0
   ```

2. Fix issues and create v0.1.1

3. Document what went wrong in issues

---

## Release Notes Template

Copy this for the GitHub release:

```markdown
# v0.1.0 - Security Hardening Release

This release focuses on security improvements, input validation, and comprehensive documentation.

## 🔒 Security Improvements

- **Strict error handling:** Added `set -euo pipefail` to all scripts
- **Input validation:** Proxy URLs, IP addresses, and ports now validated
- **Variable quoting:** Comprehensive quoting to prevent injection
- **Safe installation:** Added security warnings and 2-step installation method

## ✨ Features

- **Environment variable overrides:** Configure via environment variables
- **Enhanced logging:** Color-coded output with contextual messages
- **Configuration display:** Shows active configuration on startup
- **GitHub Actions CI:** ShellCheck workflow for automated quality checks

## 📚 Documentation

- **How It Works section:** Explains single-file approach and idempotency
- **HTTPS requirements:** Documents apt-cacher-ng PassThroughPattern setup
- **Comprehensive troubleshooting:** 6 major troubleshooting sections added
- **Security hardening guide:** Complete documentation of security changes

## 🐛 Bug Fixes

- Fixed variable expansion in interactive installer
- Standardized configuration file path consistently
- Improved exit code handling throughout

## 🔄 Compatibility

Fully backward compatible with previous manual installations.

## 📥 Installation

**Interactive (recommended):**
```bash
# Review first, then run:
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/v0.1.0/install-interactive.sh -o /tmp/install.sh
less /tmp/install.sh
bash /tmp/install.sh
```

**One-liner (at your own risk):**

```bash
curl -fsSL https://raw.githubusercontent.com/GrandDay/apt-cache-config/v0.1.0/install-interactive.sh | bash
```

## 🔗 Resources

- [Security Hardening Details](SECURITY_HARDENING-10-21-25.md)
- [User Guide](docs/GUIDE.md)
- [Report Issues](https://github.com/GrandDay/apt-cache-config/issues)

## ⚠️ Known Limitations

- No dry-run mode (planned for v0.2.0)
- No automatic rollback on failure
- Only supports unauthenticated proxies

Full changelog: <https://github.com/GrandDay/apt-cache-config/compare/initial...v0.1.0>

```bash

---

## Testing Notes

Record test results here:

**Date:** _____________  
**Tester:** _____________  
**Environment:** _____________  

### Test Results
- [ ] Local configuration: PASS / FAIL
- [ ] LXC configuration: PASS / FAIL
- [ ] VM configuration: PASS / FAIL
- [ ] Remove operations: PASS / FAIL
- [ ] Interactive installer: PASS / FAIL
- [ ] Input validation: PASS / FAIL

**Notes:**
```
