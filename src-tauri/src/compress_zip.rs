use std::fs::File;
use std::io;
use std::path::Path;
use walkdir::WalkDir;
use zip::write::{FileOptions, ZipWriter};
use zip::CompressionMethod;

/// Compress a folder with password protection using AES-256 encryption
///
/// # Arguments
/// * `src_dir` - Source directory path to compress
/// * `dst_zip` - Destination ZIP file path
/// * `password` - Password for AES-256 encryption
///
/// # Returns
/// * `Ok(())` on success
/// * `Err(String)` with error message on failure
pub fn compress_folder_with_password(
    src_dir: String,
    dst_zip: String,
    password: String,
) -> Result<(), String> {
    let src_path = Path::new(&src_dir);
    
    // Validate source directory
    if !src_path.exists() {
        return Err(format!("Source directory does not exist: {}", src_dir));
    }
    if !src_path.is_dir() {
        return Err(format!("Source path is not a directory: {}", src_dir));
    }

    // Create destination file
    let dst_file = File::create(&dst_zip)
        .map_err(|e| format!("Failed to create ZIP file {}: {}", dst_zip, e))?;
    
    let mut zip = ZipWriter::new(dst_file);
    
    // Configure compression with AES-256 encryption
    let options = FileOptions::<()>::default()
        .compression_method(CompressionMethod::Deflated)
        .with_aes_encryption(zip::AesMode::Aes256, &password);

    // Recursively walk through source directory
    let walker = WalkDir::new(src_path).into_iter();
    
    for entry in walker.filter_map(|e| e.ok()) {
        let path = entry.path();
        let name = path.strip_prefix(src_path)
            .map_err(|e| format!("Failed to strip prefix: {}", e))?;
        
        // Skip the root directory itself
        if name.as_os_str().is_empty() {
            continue;
        }

        // Convert to forward slashes for ZIP compatibility
        let name_str = name.to_string_lossy().replace('\\', "/");

        if path.is_file() {
            // Add file to archive
            zip.start_file(&name_str, options)
                .map_err(|e| format!("Failed to start file {}: {}", name_str, e))?;
            
            let mut file = File::open(path)
                .map_err(|e| format!("Failed to open file {}: {}", path.display(), e))?;
            
            io::copy(&mut file, &mut zip)
                .map_err(|e| format!("Failed to write file {} to archive: {}", name_str, e))?;
        } else if path.is_dir() {
            // Add directory to archive (preserve folder structure)
            zip.add_directory(&name_str, options)
                .map_err(|e| format!("Failed to add directory {}: {}", name_str, e))?;
        }
    }

    // Finalize the archive
    zip.finish()
        .map_err(|e| format!("Failed to finalize ZIP archive: {}", e))?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    #[test]
    fn test_compress_folder_with_password() {
        let temp_dir = TempDir::new().unwrap();
        let src_dir = temp_dir.path().join("source");
        fs::create_dir(&src_dir).unwrap();
        
        // Create test files
        fs::write(src_dir.join("test.txt"), "Hello, World!").unwrap();
        fs::create_dir(src_dir.join("subdir")).unwrap();
        fs::write(src_dir.join("subdir").join("nested.txt"), "Nested content").unwrap();

        let dst_zip = temp_dir.path().join("output.zip");
        
        let result = compress_folder_with_password(
            src_dir.to_string_lossy().to_string(),
            dst_zip.to_string_lossy().to_string(),
            "test_password".to_string(),
        );

        assert!(result.is_ok());
        assert!(dst_zip.exists());
    }

    #[test]
    fn test_compress_nonexistent_directory() {
        let result = compress_folder_with_password(
            "/nonexistent/path".to_string(),
            "/tmp/output.zip".to_string(),
            "password".to_string(),
        );

        assert!(result.is_err());
        assert!(result.unwrap_err().contains("does not exist"));
    }
}
