const uploadButton = document.getElementById('uploadButton');
const videoInput = document.getElementById('videoUpload');
const videoList = document.getElementById('videoList');
const commentInput = document.getElementById('commentInput');
const commentButton = document.getElementById('commentButton');
const commentsList = document.getElementById('commentsList');

// Handle video upload
uploadButton.addEventListener('click', async (event) => {
    event.preventDefault();
    if (!videoInput.files || videoInput.files.length === 0) return alert('Please select a video file to upload.');
    const formData = new FormData();
    formData.append('video', videoInput.files[0]);
    
    try {
        const response = await fetch('/api/videos', {
            method: 'POST',
            body: formData,
        });
        const result = await response.json();
        if (response.ok) {
            displayUploadedVideo(result);
        } else {
            alert(result.message);
        }
    } catch (error) {
        console.error('Error uploading video:', error);
    }
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