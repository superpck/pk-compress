use std::fs::{self, File};
use std::io;
use std::path::Path;
use zip::ZipArchive;

/// Decompress a password-protected ZIP file
///
/// # Arguments
/// * `src_zip` - Source ZIP file path
/// * `dst_dir` - Destination directory path for extraction
/// * `password` - Password for decryption
///
/// # Returns
/// * `Ok(())` on success
/// * `Err(String)` with error message on failure
pub fn decompress_zip_with_password(
    src_zip: String,
    dst_dir: String,
    password: String,
) -> Result<(), String> {
    let src_path = Path::new(&src_zip);
    
    // Validate source ZIP file
    if !src_path.exists() {
        return Err(format!("ZIP file does not exist: {}", src_zip));
    }
    if !src_path.is_file() {
        return Err(format!("Path is not a file: {}", src_zip));
    }

    // Open ZIP archive
    let file = File::open(src_path)
        .map_err(|e| format!("Failed to open ZIP file {}: {}", src_zip, e))?;
    
    let mut archive = ZipArchive::new(file)
        .map_err(|e| format!("Failed to read ZIP archive: {}. Archive may be corrupted or invalid.", e))?;

    // Create destination directory if it doesn't exist
    let dst_path = Path::new(&dst_dir);
    fs::create_dir_all(dst_path)
        .map_err(|e| format!("Failed to create destination directory {}: {}", dst_dir, e))?;

    // Extract all files
    for i in 0..archive.len() {
        let mut file = match archive.by_index_decrypt(i, password.as_bytes()) {
            Ok(f) => f,
            Err(e) => {
                let err_msg = format!("{:?}", e);
                if err_msg.contains("InvalidPassword") || err_msg.contains("password") {
                    return Err("Incorrect password".to_string());
                }
                return Err(format!("Failed to access file at index {}: {}. Archive may be corrupted or invalid.", i, e));
            }
        };

        let outpath = match file.enclosed_name() {
            Some(path) => dst_path.join(path),
            None => {
                return Err(format!("Invalid file path in archive at index {}", i));
            }
        };

        if file.name().ends_with('/') {
            // Directory entry
            fs::create_dir_all(&outpath)
                .map_err(|e| format!("Failed to create directory {}: {}", outpath.display(), e))?;
        } else {
            // File entry
            // Ensure parent directory exists
            if let Some(parent) = outpath.parent() {
                fs::create_dir_all(parent)
                    .map_err(|e| format!("Failed to create parent directory {}: {}", parent.display(), e))?;
            }

            // Extract file
            let mut outfile = File::create(&outpath)
                .map_err(|e| format!("Failed to create file {}: {}", outpath.display(), e))?;
            
            io::copy(&mut file, &mut outfile)
                .map_err(|e| format!("Failed to extract file {}: {}", outpath.display(), e))?;
        }

        // Set file permissions on Unix-like systems
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            if let Some(mode) = file.unix_mode() {
                fs::set_permissions(&outpath, fs::Permissions::from_mode(mode))
                    .map_err(|e| format!("Failed to set permissions for {}: {}", outpath.display(), e))?;
            }
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::compress_zip::compress_folder_with_password;
    use std::fs;
    use tempfile::TempDir;

    #[test]
    fn test_decompress_zip_with_password() {
        let temp_dir = TempDir::new().unwrap();
        let src_dir = temp_dir.path().join("source");
        let dst_dir = temp_dir.path().join("extracted");
        let zip_path = temp_dir.path().join("test.zip");

        // Create test data and compress
        fs::create_dir(&src_dir).unwrap();
        fs::write(src_dir.join("test.txt"), "Hello, World!").unwrap();
        fs::create_dir(src_dir.join("subdir")).unwrap();
        fs::write(src_dir.join("subdir").join("nested.txt"), "Nested content").unwrap();

        compress_folder_with_password(
            src_dir.to_string_lossy().to_string(),
            zip_path.to_string_lossy().to_string(),
            "test_password".to_string(),
        )
        .unwrap();

        // Decompress
        let result = decompress_zip_with_password(
            zip_path.to_string_lossy().to_string(),
            dst_dir.to_string_lossy().to_string(),
            "test_password".to_string(),
        );

        assert!(result.is_ok());
        assert!(dst_dir.join("test.txt").exists());
        assert!(dst_dir.join("subdir").join("nested.txt").exists());
        
        let content = fs::read_to_string(dst_dir.join("test.txt")).unwrap();
        assert_eq!(content, "Hello, World!");
    }

    #[test]
    fn test_decompress_with_wrong_password() {
        let temp_dir = TempDir::new().unwrap();
        let src_dir = temp_dir.path().join("source");
        let dst_dir = temp_dir.path().join("extracted");
        let zip_path = temp_dir.path().join("test.zip");

        // Create and compress
        fs::create_dir(&src_dir).unwrap();
        fs::write(src_dir.join("test.txt"), "Secret data").unwrap();

        compress_folder_with_password(
            src_dir.to_string_lossy().to_string(),
            zip_path.to_string_lossy().to_string(),
            "correct_password".to_string(),
        )
        .unwrap();

        // Try to decompress with wrong password
        let result = decompress_zip_with_password(
            zip_path.to_string_lossy().to_string(),
            dst_dir.to_string_lossy().to_string(),
            "wrong_password".to_string(),
        );

        assert!(result.is_err());
        assert!(result.unwrap_err().contains("password"));
    }

    #[test]
    fn test_decompress_nonexistent_file() {
        let result = decompress_zip_with_password(
            "/nonexistent/file.zip".to_string(),
            "/tmp/output".to_string(),
            "password".to_string(),
        );

        assert!(result.is_err());
        assert!(result.unwrap_err().contains("does not exist"));
    }
}
