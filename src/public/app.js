const uploadButton = document.getElementById('uploadButton');
const videoInput = document.getElementById('videoUpload');
const videoList = document.getElementById('videoList');
const commentInput = document.getElementById('commentInput');
const commentButton = document.getElementById('commentButton');
const commentsList = document.getElementById('commentsList');

// Thumbnail preview generation
const thumbPreviewImage = document.getElementById('thumbPreviewImage');
const uploadProgress = document.getElementById('uploadProgressBar');

videoInput.addEventListener('change', async (e) => {
    if (!videoInput.files || videoInput.files.length === 0) { thumbPreviewImage.src = ''; return; }
    const file = videoInput.files[0];
    // Generate a thumbnail using an offscreen video + canvas
    const url = URL.createObjectURL(file);
    const v = document.createElement('video');
    v.src = url;
    v.muted = true;
    v.playsInline = true;
    v.addEventListener('loadeddata', () => {
        v.currentTime = 0.1;
    });
    v.addEventListener('seeked', () => {
        const canvas = document.createElement('canvas');
        canvas.width = v.videoWidth;
        canvas.height = v.videoHeight;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(v, 0, 0, canvas.width, canvas.height);
        try {
            thumbPreviewImage.src = canvas.toDataURL('image/png');
        } catch (err) {
            console.warn('Could not create thumbnail', err);
            thumbPreviewImage.src = '';
        }
        URL.revokeObjectURL(url);
    });
});

// Handle video upload with progress
uploadButton.addEventListener('click', (event) => {
    event.preventDefault();
    if (!videoInput.files || videoInput.files.length === 0) return alert('Please select a video file to upload.');
    const formData = new FormData();
    formData.append('video', videoInput.files[0]);
    uploadButton.disabled = true;
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/videos');
    xhr.upload.onprogress = (e) => {
        if (e.lengthComputable) {
            const pct = Math.round((e.loaded / e.total) * 100);
            uploadProgress.style.width = pct + '%';
        }
    };
    xhr.onload = () => {
        uploadButton.disabled = false;
        uploadProgress.style.width = '0%';
        if (xhr.status === 201 || xhr.status === 200) {
            try {
                const result = JSON.parse(xhr.responseText);
                displayUploadedVideo(result);
                // clear preview & input
                thumbPreviewImage.src = '';
                videoInput.value = '';
            } catch (err) { console.error('Invalid response', err); }
        } else {
            alert('Upload failed: ' + xhr.status + ' ' + xhr.statusText);
        }
    };
    xhr.onerror = () => {
        uploadButton.disabled = false;
        uploadProgress.style.width = '0%';
        alert('Upload failed due to network error');
    };
    xhr.send(formData);
});

// Display uploaded video
function displayUploadedVideo(video) {
    const videoElement = document.createElement('video');
    videoElement.src = video.url;
    videoElement.controls = true;
    videoElement.width = 400;
    videoList.appendChild(videoElement);
}

// Handle comment submission
commentButton.addEventListener('click', async (event) => {
    event.preventDefault();
    const commentText = commentInput.value;
    
    try {
        // Submit a comment without associating with a video (simple demo)
        const response = await fetch('/api/comments/null', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: commentText }),
        });
        const result = await response.json();
        if (response.ok) {
            displayComment(result);
            commentInput.value = '';
        } else {
            alert(result.message);
        }
    } catch (error) {
        console.error('Error submitting comment:', error);
    }
});

// Display comment
function displayComment(comment) {
    const commentElement = document.createElement('li');
    commentElement.textContent = comment.text;
    commentList.appendChild(commentElement);
}

// Fetch existing videos and comments on page load
async function fetchExistingData() {
    try {
        const videosResponse = await fetch('/api/videos');
        const videos = await videosResponse.json();
        videos.forEach(displayUploadedVideo);
        // Load comments globally for demo
        const commentsResponse = await fetch('/api/comments/null');
        const comments = await commentsResponse.json();
        comments.forEach(displayComment);
    } catch (error) {
        console.error('Error fetching existing data:', error);
    }
}

fetchExistingData();