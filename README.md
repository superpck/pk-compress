# PK Compress

**A cross-platform file compression/decompression application built with Tauri v2, Angular, and Rust.**

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Rust](https://img.shields.io/badge/rust-%23000000.svg?style=flat&logo=rust&logoColor=white)](https://www.rust-lang.org/)
[![Tauri](https://img.shields.io/badge/tauri-%2324C8DB.svg?style=flat&logo=tauri&logoColor=%23FFFFFF)](https://tauri.app/)

## Project Structure

```
compress_app/
├── src-tauri/              # Rust backend
│   ├── src/
│   │   ├── main.rs         # Tauri command bridge
│   │   ├── compress_zip.rs # ZIP compression with AES-256
│   │   ├── decompress_zip.rs # ZIP decompression
│   │   └── rar_placeholder.rs # Future RAR support
│   ├── Cargo.toml          # Rust dependencies
│   └── tauri.conf.json     # Tauri configuration
├── AGENTS.md               # AI agent instructions
└── request.txt             # Original requirements
```

## Features

✅ **ZIP Compression**
- Recursive folder compression
- AES-256 password protection
- Preserves folder structure
- 100% Pure Rust (no C dependencies)

✅ **ZIP Decompression**
- Password verification
- Folder structure reconstruction
- Clear error messages for invalid passwords or corrupted archives

🔄 **RAR Support** (Placeholder)
- Structure ready for future external binding integration

## Technology Stack

- **Frontend**: Angular with TypeScript
- **Backend**: Rust with Tauri v2
- **Compression**: `zip` crate (Pure Rust, AES-256 support)
- **File Walking**: `walkdir` crate
- **Cross-Platform**: Windows, macOS, iOS, Android

## Backend API

### Tauri Commands

#### 1. Compress Folder with Password

```typescript
import { invoke } from '@tauri-apps/api/core';

try {
  const result = await invoke<string>('compress_with_password', {
    src: '/path/to/source/folder',
    dst: '/path/to/output.zip',
    pwd: 'your-password-here'
  });
  console.log(result); // "Compression completed successfully"
} catch (error) {
  console.error('Compression failed:', error);
}
```

#### 2. Decompress ZIP with Password

```typescript
import { invoke } from '@tauri-apps/api/core';

try {
  const result = await invoke<string>('decompress_with_password', {
    src: '/path/to/archive.zip',
    dst: '/path/to/extract/folder',
    pwd: 'your-password-here'
  });
  console.log(result); // "Decompression completed successfully"
} catch (error) {
  console.error('Decompression failed:', error);
  // Error messages:
  // - "Incorrect password"
  // - "Archive is corrupted or invalid"
  // - "ZIP file does not exist: ..."
}
```

#### 3. Check if File is RAR Archive

```typescript
import { invoke } from '@tauri-apps/api/core';

try {
  const isRar = await invoke<boolean>('check_is_rar', {
    path: '/path/to/file'
  });
  if (isRar) {
    console.log('This is a RAR archive');
  }
} catch (error) {
  console.error('Failed to check file:', error);
}
```

#### 4. Decompress RAR (Not Yet Implemented)

```typescript
import { invoke } from '@tauri-apps/api/core';

try {
  await invoke('decompress_rar', {
    src: '/path/to/archive.rar',
    dst: '/path/to/extract',
    pwd: 'optional-password'
  });
} catch (error) {
  // Returns: "RAR decompression is not yet implemented..."
  console.error('RAR support coming soon:', error);
}
```

## Angular Service Example

```typescript
// compression.service.ts
import { Injectable } from '@angular/core';
import { invoke } from '@tauri-apps/api/core';

@Injectable({
  providedIn: 'root'
})
export class CompressionService {
  
  async compressFolder(
    sourcePath: string,
    destinationPath: string,
    password: string
  ): Promise<string> {
    return await invoke<string>('compress_with_password', {
      src: sourcePath,
      dst: destinationPath,
      pwd: password
    });
  }

  async decompressZip(
    zipPath: string,
    extractPath: string,
    password: string
  ): Promise<string> {
    return await invoke<string>('decompress_with_password', {
      src: zipPath,
      dst: extractPath,
      pwd: password
    });
  }

  async isRarFile(filePath: string): Promise<boolean> {
    return await invoke<boolean>('check_is_rar', {
      path: filePath
    });
  }
}
```

## Component Example

```typescript
// compression.component.ts
import { Component } from '@angular/core';
import { CompressionService } from './compression.service';

@Component({
  selector: 'app-compression',
  template: `
    <div class="compression-panel">
      <h2>Compress Folder</h2>
      <input [(ngModel)]="sourcePath" placeholder="Source folder path">
      <input [(ngModel)]="outputPath" placeholder="Output ZIP path">
      <input type="password" [(ngModel)]="password" placeholder="Password">
      <button (click)="compress()">Compress</button>
      
      <h2>Decompress ZIP</h2>
      <input [(ngModel)]="zipPath" placeholder="ZIP file path">
      <input [(ngModel)]="extractPath" placeholder="Extract to folder">
      <input type="password" [(ngModel)]="password" placeholder="Password">
      <button (click)="decompress()">Decompress</button>
      
      <div *ngIf="message" class="message">{{ message }}</div>
      <div *ngIf="error" class="error">{{ error }}</div>
    </div>
  `
})
export class CompressionComponent {
  sourcePath = '';
  outputPath = '';
  zipPath = '';
  extractPath = '';
  password = '';
  message = '';
  error = '';

  constructor(private compressionService: CompressionService) {}

  async compress() {
    try {
      this.error = '';
      this.message = 'Compressing...';
      const result = await this.compressionService.compressFolder(
        this.sourcePath,
        this.outputPath,
        this.password
      );
      this.message = result;
    } catch (err) {
      this.message = '';
      this.error = `Error: ${err}`;
    }
  }

  async decompress() {
    try {
      this.error = '';
      this.message = 'Decompressing...';
      const result = await this.compressionService.decompressZip(
        this.zipPath,
        this.extractPath,
        this.password
      );
      this.message = result;
    } catch (err) {
      this.message = '';
      this.error = `Error: ${err}`;
    }
  }
}
```

## Development

### Prerequisites

- Node.js (v18+)
- Rust (latest stable)
- npm or pnpm

### Quick Start

#### Build และ Test บน macOS (แนะนำ)

```bash
# Build และ test บน macOS ในคำสั่งเดียว
./build-macos-test.sh
```

#### Build แยกตาม Platform

```bash
# Build เฉพาะ macOS (ARM64 + x86_64)
./build.sh macos

# Build เฉพาะ Windows (ต้องติดตั้ง toolchain ก่อน)
./build.sh windows

# Build เฉพาะ Linux (ต้องติดตั้ง toolchain ก่อน)
./build.sh linux

# Build ทุก platform
./build.sh all

# รัน tests เท่านั้น
./build.sh test
```

#### Setup Cross-Compilation (สำหรับ Windows/Linux)

```bash
# ติดตั้ง cross-compilation tools
./setup-cross-compile.sh
```

📖 **คู่มือการใช้งานแบบละเอียด**: ดูที่ [BUILD_GUIDE.md](BUILD_GUIDE.md)

### Setup

```bash
# Install dependencies
npm install

# Run in development mode (with hot reload)
npm run tauri dev

# Build for production
npm run tauri build
```

### Testing the Rust Backend

```bash
cd src-tauri
cargo test        # Run all tests
cargo check       # Check for compilation errors
cargo build       # Build debug version
cargo build --release  # Build optimized release version
```

## Security Considerations

1. **Password Protection**: All archives use AES-256 encryption
2. **Password Validation**: Backend validates password strength (implement in frontend)
3. **Error Handling**: Clear error messages without exposing sensitive information
4. **Path Validation**: Always validate and sanitize file paths in frontend
5. **Large Files**: Consider implementing progress callbacks for files > 100MB

## Common Issues

### C Dependency Errors

**Problem**: Build fails with C library linking errors

**Solution**: Ensure `Cargo.toml` only uses Pure Rust features:
```toml
zip = { version = "2.1", features = ["aes-crypto", "deflate"], default-features = false }
```

Never add: `bzip2`, `zstd` with system libs, or other C-dependent features.

### Path Separator Issues

**Problem**: Archive structure broken on different platforms

**Solution**: Always use `std::path::Path` and convert to forward slashes for ZIP:
```rust
let name_str = name.to_string_lossy().replace('\\', "/");
```

### Memory Issues with Large Files

**Problem**: Application crashes with large files

**Solution**: Implement streaming and progress callbacks (future enhancement)

## Implementation Status

- [x] Task 1: Cargo.toml Configuration
- [x] Task 2: ZIP Compression Module (compress_zip.rs)
- [x] Task 3: ZIP Decompression Module (decompress_zip.rs)
- [x] Task 4: Tauri Command Bridge (main.rs)
- [x] Clean Architecture & Error Handling
- [x] Unit Tests (6 tests passing)
- [ ] RAR Support (placeholder ready)
- [ ] Angular Frontend UI
- [ ] File picker dialogs
- [ ] Progress indicators
- [ ] Mobile platform support (iOS/Android)

## 📄 License

PK Compress is licensed under the [MIT License](LICENSE).

### Third-Party Licenses

This project uses various open-source libraries. See [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) for details on all dependencies and their licenses.

**Key Points:**
- ✅ All dependencies use permissive licenses (MIT, Apache-2.0, Unlicense)
- ✅ Safe for commercial and personal use
- ⚠️ RAR support placeholder only - implementing RAR decompression requires careful license review

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- [Tauri](https://tauri.app/) - Application framework
- [zip-rs](https://github.com/zip-rs/zip2) - Pure Rust ZIP library
- All open-source contributors

## License

See LICENSE file for details.

## Contributing

See [AGENTS.md](AGENTS.md) for AI agent instructions and contribution guidelines.

---

**Author**: SuperPCK
**License**: MIT  
**Version**: 0.1.0
