// Prevents additional console window on Windows in release builds
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod compress_zip;
mod decompress_zip;
mod rar_placeholder;

use compress_zip::compress_folder_with_password;
use decompress_zip::decompress_zip_with_password;
use rar_placeholder::{decompress_rar_with_password, is_rar_file};

/// Tauri command to compress a folder with password protection
///
/// # Arguments
/// * `src` - Source directory path
/// * `dst` - Destination ZIP file path
/// * `pwd` - Password for AES-256 encryption
///
/// # Returns
/// * `Ok(String)` - Success message
/// * `Err(String)` - Error message
#[tauri::command]
async fn compress_with_password(src: String, dst: String, pwd: String) -> Result<String, String> {
    compress_folder_with_password(src, dst, pwd)?;
    Ok("Compression completed successfully".to_string())
}

/// Tauri command to decompress a ZIP file with password
///
/// # Arguments
/// * `src` - Source ZIP file path
/// * `dst` - Destination directory path
/// * `pwd` - Password for decryption
///
/// # Returns
/// * `Ok(String)` - Success message
/// * `Err(String)` - Error message
#[tauri::command]
async fn decompress_with_password(src: String, dst: String, pwd: String) -> Result<String, String> {
    decompress_zip_with_password(src, dst, pwd)?;
    Ok("Decompression completed successfully".to_string())
}

/// Tauri command to decompress a RAR file (placeholder)
///
/// # Arguments
/// * `src` - Source RAR file path
/// * `dst` - Destination directory path
/// * `pwd` - Optional password for decryption
///
/// # Returns
/// * `Err(String)` - Currently not implemented
#[tauri::command]
async fn decompress_rar(src: String, dst: String, pwd: Option<String>) -> Result<String, String> {
    decompress_rar_with_password(src, dst, pwd)?;
    Ok("RAR decompression completed successfully".to_string())
}

/// Tauri command to check if a file is a RAR archive
///
/// # Arguments
/// * `path` - File path to check
///
/// # Returns
/// * `Ok(bool)` - true if RAR file, false otherwise
/// * `Err(String)` - Error message
#[tauri::command]
async fn check_is_rar(path: String) -> Result<bool, String> {
    is_rar_file(&path)
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            compress_with_password,
            decompress_with_password,
            decompress_rar,
            check_is_rar
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
