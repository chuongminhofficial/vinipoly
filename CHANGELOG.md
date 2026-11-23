# Changelog

## [v3.0.0] - 2026-11-24

### Added
- Precompiled native `vinipoly.so` Zend extensions for **PHP 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4, and 8.5** under `release-so/`.
- Precompiled Linux x86_64 `bin/vinipoly-encoder`, `bin/vinipoly-decoder`, and `installer_vinipoly` binaries with direct GitHub Raw download support and `SHA256SUMS.txt` verification.
- Native Zend `zend_resolve_path` and `file_exists()` / `is_file()` / `is_readable()` hooks for zero-touch PSR-4 & multi-file PHP compatibility.
- Token-safe PHP AST scanner with Heredoc/Nowdoc, PHP 8 Attribute/Enum, and static asset preservation.
- Frameless Midnight Horizon Closed Shadow DOM F12 shield with 11 built-in languages and native Right-to-Left (RTL) support.
- Cookie-independent `X-VP-TK` session transport header and CSP `nonce` propagation.

### Changed
- Upgraded container format to `CM_ENC v3` with per-file isolated runtime, constant, and owner recovery keys.
- Removed legacy plaintext installer script in favor of the compiled `installer_vinipoly` binary.
