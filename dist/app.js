// Tauri API
const { invoke } = window.__TAURI__.core;
const { open } = window.__TAURI__.dialog;

// Global state
let selectedFiles = {
    compress: null,
    decompress: null
};

// Mode switching
document.querySelectorAll('.mode-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const mode = btn.dataset.mode;
        
        // Update active button
        document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        
        // Show/hide mode content
        document.querySelectorAll('.mode-content').forEach(content => {
            content.classList.add('hidden');
        });
        document.getElementById(`${mode}-mode`).classList.remove('hidden');
    });
});

// Drag and drop handlers
function setupDropZone(dropZoneId, mode) {
    const dropZone = document.getElementById(dropZoneId);
    
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, preventDefaults, false);
    });
    
    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }
    
    ['dragenter', 'dragover'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.add('drag-over');
        }, false);
    });
    
    ['dragleave', 'drop'].forEach(eventName => {
        dropZone.addEventListener(eventName, () => {
            dropZone.classList.remove('drag-over');
        }, false);
    });
    
    dropZone.addEventListener('drop', async (e) => {
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            handleFileSelect(files[0].path, mode, dropZone);
        }
    }, false);
}

function handleFileSelect(path, mode, dropZone) {
    selectedFiles[mode] = path;
    dropZone.classList.add('has-file');
    
    const fileName = path.split('/').pop() || path.split('\\').pop();
    dropZone.querySelector('h3').textContent = fileName;
    dropZone.querySelector('p').textContent = path;
}

// Initialize drop zones
setupDropZone('compress-drop-zone', 'compress');
setupDropZone('decompress-drop-zone', 'decompress');

// File/Folder selection
async function selectFolder(mode) {
    try {
        const selected = await open({
            directory: true,
            multiple: false,
            title: 'Select Folder'
        });
        
        if (selected) {
            const dropZone = document.getElementById(`${mode}-drop-zone`);
            handleFileSelect(selected, mode, dropZone);
        }
    } catch (error) {
        showToast('Failed to select folder: ' + error, 'error');
    }
}

async function selectFile(mode) {
    try {
        const selected = await open({
            multiple: false,
            title: 'Select ZIP File',
            filters: [{
                name: 'ZIP Files',
                extensions: ['zip']
            }]
        });
        
        if (selected) {
            const dropZone = document.getElementById(`${mode}-drop-zone`);
            handleFileSelect(selected, mode, dropZone);
        }
    } catch (error) {
        showToast('Failed to select file: ' + error, 'error');
    }
}

async function selectOutput() {
    try {
        const selected = await open({
            directory: false,
            multiple: false,
            title: 'Save As',
            filters: [{
                name: 'ZIP Files',
                extensions: ['zip']
            }]
        });
        
        if (selected) {
            document.getElementById('compress-output').value = selected;
        }
    } catch (error) {
        showToast('Failed to select output: ' + error, 'error');
    }
}

// Password visibility toggle
function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    input.type = input.type === 'password' ? 'text' : 'password';
}

// Compress function
async function compress() {
    const src = selectedFiles.compress;
    const password = document.getElementById('compress-password').value;
    let dst = document.getElementById('compress-output').value;
    
    // Validation
    if (!src) {
        showToast('Please select a folder or files to compress', 'warning');
        return;
    }
    
    if (!password) {
        showToast('Password is required for compression', 'warning');
        return;
    }
    
    if (password.length < 6) {
        showToast('Password should be at least 6 characters', 'warning');
        return;
    }
    
    // Auto-generate output filename if not set
    if (!dst) {
        const folderName = src.split('/').pop() || src.split('\\').pop();
        dst = src + '/' + folderName + '-compressed.zip';
        document.getElementById('compress-output').value = dst;
    }
    
    // Show progress
    showProgress('Compressing files...', 'Starting compression...');
    
    try {
        const result = await invoke('compress_with_password', {
            src: src,
            dst: dst,
            pwd: password
        });
        
        hideProgress();
        showToast('Files compressed successfully! 🎉', 'success');
        
        // Reset form
        setTimeout(() => {
            document.getElementById('compress-password').value = '';
            document.getElementById('compress-output').value = '';
            const dropZone = document.getElementById('compress-drop-zone');
            dropZone.classList.remove('has-file');
            dropZone.querySelector('h3').textContent = 'Drop folder or files here';
            dropZone.querySelector('p').textContent = 'or';
            selectedFiles.compress = null;
        }, 2000);
        
    } catch (error) {
        hideProgress();
        showToast('Compression failed: ' + error, 'error');
    }
}

// Decompress function
async function decompress() {
    const src = selectedFiles.decompress;
    const password = document.getElementById('decompress-password').value;
    let dst = document.getElementById('decompress-output').value;
    
    // Validation
    if (!src) {
        showToast('Please select a ZIP file to decompress', 'warning');
        return;
    }
    
    // Auto-generate output folder if not set
    if (!dst) {
        const fileName = src.split('/').pop() || src.split('\\').pop();
        const baseName = fileName.replace('.zip', '');
        dst = src.replace(fileName, '') + baseName + '-extracted';
        document.getElementById('decompress-output').value = dst;
    }
    
    // Show progress
    showProgress('Decompressing files...', 'Starting extraction...');
    
    try {
        const result = await invoke('decompress_with_password', {
            src: src,
            dst: dst,
            pwd: password || ''
        });
        
        hideProgress();
        showToast('Files extracted successfully! 🎉', 'success');
        
        // Reset form
        setTimeout(() => {
            document.getElementById('decompress-password').value = '';
            document.getElementById('decompress-output').value = '';
            const dropZone = document.getElementById('decompress-drop-zone');
            dropZone.classList.remove('has-file');
            dropZone.querySelector('h3').textContent = 'Drop ZIP file here';
            dropZone.querySelector('p').textContent = 'or';
            selectedFiles.decompress = null;
        }, 2000);
        
    } catch (error) {
        hideProgress();
        if (error.includes('Incorrect password')) {
            showToast('Incorrect password! Please try again.', 'error');
        } else {
            showToast('Extraction failed: ' + error, 'error');
        }
    }
}

// Progress UI
function showProgress(title, text) {
    document.getElementById('progress-container').classList.remove('hidden');
    document.getElementById('progress-title').textContent = title;
    document.getElementById('progress-text').textContent = text;
    
    // Simulate progress animation
    let progress = 0;
    const interval = setInterval(() => {
        progress += Math.random() * 15;
        if (progress > 90) progress = 90;
        document.getElementById('progress-fill').style.width = progress + '%';
    }, 300);
    
    // Store interval ID for cleanup
    window.progressInterval = interval;
}

function hideProgress() {
    if (window.progressInterval) {
        clearInterval(window.progressInterval);
    }
    
    // Complete the progress bar
    document.getElementById('progress-fill').style.width = '100%';
    
    setTimeout(() => {
        document.getElementById('progress-container').classList.add('hidden');
        document.getElementById('progress-fill').style.width = '0%';
    }, 500);
}

// Toast notifications
function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.textContent = message;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideIn 0.3s ease reverse';
        setTimeout(() => {
            document.body.removeChild(toast);
        }, 300);
    }, 3000);
}

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Ctrl/Cmd + O to select files
    if ((e.ctrlKey || e.metaKey) && e.key === 'o') {
        e.preventDefault();
        const activeMode = document.querySelector('.mode-btn.active').dataset.mode;
        if (activeMode === 'compress') {
            selectFolder('compress');
        } else {
            selectFile('decompress');
        }
    }
    
    // Ctrl/Cmd + Enter to process
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        const activeMode = document.querySelector('.mode-btn.active').dataset.mode;
        if (activeMode === 'compress') {
            compress();
        } else {
            decompress();
        }
    }
});

// Initialize
console.log('PK Compress initialized');
showToast('Welcome to PK Compress! 👋', 'success');
