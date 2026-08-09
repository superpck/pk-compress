# PK Compress - Agent Instructions

## Project Overview

**PK Compress** is a **Tauri v2** application for file compression and decompression:
- **Frontend**: Angular with lazy loading (HTML/CSS/TypeScript)
- **Backend**: Rust for file processing
- **Target Platforms**: Cross-platform (Windows, macOS, iOS, Android)

See [request.txt](request.txt) for detailed task breakdown and implementation requirements.

## Critical Architectural Constraints

### 100% Pure Rust for ZIP Operations
- **No C dependencies or external bindings** for ZIP compression/decompression
- This ensures seamless cross-compilation to all target platforms (Windows, iOS, Android)
- Use `zip` crate with **pure Rust features only**

### Required Rust Dependencies

```toml
[dependencies]
zip = { version = "2.1", features = ["aes-crypto", "deflate"] }
walkdir = "2"
tauri = { version = "2.0", features = ["shell-open"] }
```

**Critical**: Do NOT enable features that introduce C dependencies (e.g., `bzip2`, `zstd` with system libs). Use `deflate` only.

## Module Structure

Organize Rust backend with clean separation:

```
src-tauri/src/
├── main.rs              # Tauri command bridge
├── compress_zip.rs      # ZIP compression logic
├── decompress_zip.rs    # ZIP decompression logic
└── rar_placeholder.rs   # Future RAR support (external bindings)
```

### Key Functions

#### compress_zip.rs
```rust
pub fn compress_folder_with_password(
    src_dir: String,
    dst_zip: String,
    password: String
) -> Result<(), String>
```
- Recursively read folders using `walkdir`
- Preserve relative path structures
- Use `with_aes_encryption` for AES-256 password protection

#### decompress_zip.rs
```rust
pub fn decompress_zip_with_password(
    src_zip: String,
    dst_dir: String,
    password: String
) -> Result<(), String>
```
- Verify password before extraction
- Reconstruct original folder layout
- Return clear errors for invalid passwords or corrupted archives

## Tauri Command Bridge Pattern

Bridge Angular frontend ↔ Rust backend using `#[tauri::command]`:

```rust
#[tauri::command]
async fn compress_with_password(
    src: String,
    dst: String,
    pwd: String
) -> Result<String, String> {
    compress_zip::compress_folder_with_password(src, dst, pwd)
        .map(|_| "Success".to_string())
}

// Register in main.rs
fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            compress_with_password,
            decompress_with_password
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
```

From Angular, invoke commands via:
```typescript
import { invoke } from '@tauri-apps/api/core';

await invoke('compress_with_password', {
  src: '/path/to/folder',
  dst: '/path/to/output.zip',
  pwd: 'password123'
});
```

## Security Requirements

### AES-256 Encryption
- All password-protected archives **must** use AES-256 encryption
- Use `zip::write::FileOptions::default().with_aes_encryption(zip::AesMode::Aes256, password)`
- Never store passwords in plaintext or logs

### Error Handling
- Return `Result<T, String>` from all backend functions
- Bubble errors cleanly to frontend with user-friendly messages
- Distinguish between:
  - Invalid password: "Incorrect password"
  - Corrupted archive: "Archive is corrupted or invalid"
  - File system errors: Include path context in error message

## RAR Support (Future)

RAR decompression requires external bindings due to licensing restrictions:
- Keep RAR logic in separate module (`rar_placeholder.rs`)
- Design interface compatible with future external bundle integration
- **Do NOT implement RAR support yet** — placeholder structure only

## Build & Development Commands

```bash
# Development mode (hot reload)
npm run tauri dev

# Production build
npm run tauri build

# Build Rust backend only (for testing)
cd src-tauri && cargo build
```

## Angular Best Practices

- Use **lazy loading** for routes to optimize bundle size
- TypeScript strict mode enabled
- Follow Angular style guide for component/service organization
- Handle Tauri command errors with proper user feedback (toast/snackbar)

## Common Pitfalls

1. **C Dependency Hell**: Never add `zip` features that require system libraries (`bzip2-sys`, `zstd-sys`, etc.) — breaks iOS/Android builds
2. **Path Separators**: Use `std::path::Path` and `PathBuf` for cross-platform path handling
3. **Relative Paths in Archives**: Always strip the source directory prefix to preserve relative structure
4. **Password Validation**: Validate password strength on frontend before calling backend
5. **Large File Handling**: Consider streaming for files > 100MB to avoid memory issues

## Testing Strategy

- Unit tests for compression/decompression functions
- Integration tests for Tauri commands
- Test password protection with various password strengths
- Verify folder structure preservation with nested directories
- Test error cases (invalid paths, corrupted archives, wrong passwords)

---

**Next Steps**: When scaffolding this project, start with Task 1 (Cargo.toml) from [request.txt](request.txt), then implement modules in order (compress → decompress → Tauri bridge).
