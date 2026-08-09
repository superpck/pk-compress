# Third-Party Licenses

PK Compress uses the following open-source libraries and dependencies. We are grateful to the maintainers and contributors of these projects.

## Direct Dependencies

### Rust Dependencies (Backend)

#### zip - v2.4.2
- **License**: MIT OR Apache-2.0
- **Repository**: https://github.com/zip-rs/zip2
- **Purpose**: Pure Rust ZIP compression and decompression with AES-256 encryption
- **License Compatibility**: ✅ Compatible with MIT License

#### walkdir - v2.5.0
- **License**: Unlicense OR MIT
- **Repository**: https://github.com/BurntSushi/walkdir
- **Purpose**: Recursive directory traversal
- **License Compatibility**: ✅ Compatible with MIT License

#### tauri - v2.11.5
- **License**: MIT OR Apache-2.0
- **Repository**: https://github.com/tauri-apps/tauri
- **Purpose**: Cross-platform application framework
- **License Compatibility**: ✅ Compatible with MIT License

#### serde - v1.0.229
- **License**: MIT OR Apache-2.0
- **Repository**: https://github.com/serde-rs/serde
- **Purpose**: Serialization/deserialization framework
- **License Compatibility**: ✅ Compatible with MIT License

#### serde_json - v1.0.151
- **License**: MIT OR Apache-2.0
- **Repository**: https://github.com/serde-rs/json
- **Purpose**: JSON serialization
- **License Compatibility**: ✅ Compatible with MIT License

### Development Dependencies

#### tempfile - v3.27.0
- **License**: MIT OR Apache-2.0
- **Repository**: https://github.com/Stebalien/tempfile
- **Purpose**: Temporary file management for testing
- **License Compatibility**: ✅ Compatible with MIT License

## License Summary

All dependencies used in PK Compress are licensed under permissive licenses (MIT, Apache-2.0, or Unlicense), which are fully compatible with the MIT License under which PK Compress is released.

### License Types Used

- **MIT License**: Permissive, allows commercial use, modification, distribution, and private use
- **Apache License 2.0**: Permissive, similar to MIT with additional patent grant
- **Unlicense**: Public domain dedication

## Important Notes

### RAR Format Support
PK Compress currently includes a **placeholder** for RAR decompression support. RAR is a proprietary format owned by Alexander Roshal/RARLAB.

**⚠️ Current Status**: 
- RAR decompression is **NOT implemented**
- If implemented in the future, it will require:
  - Using UnRAR library (with license restrictions)
  - Or using command-line tools (user-provided)
  - Compliance with RAR license terms

**License Consideration**: The UnRAR source code is available but has restrictive licensing terms that may not be compatible with free software licenses. Users who wish to add RAR support should review the UnRAR license carefully.

## Obtaining Full License Texts

Full license texts for all dependencies can be obtained from:
- Rust dependencies: Run `cargo license` in the `src-tauri` directory
- Or visit the respective repository URLs listed above

## Compliance

This project complies with all license requirements of its dependencies. All required copyright notices and license texts are preserved in the compiled binaries through Cargo's automatic license handling.

## Reporting License Issues

If you believe there is a license compliance issue with PK Compress, please open an issue at:
https://github.com/[your-username]/pk-compress/issues

---

*Last Updated: 2026-08-09*
