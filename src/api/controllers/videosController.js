const videoService = require('../services/videoService');

exports.uploadVideo = async function (req, res) {
    try {
        const videoFile = req.file;
        if (!videoFile) {
            return res.status(400).json({ message: 'No video file uploaded.' });
        }
        const videoData = await videoService.uploadVideo(videoFile);
        return res.status(201).json(videoData);
    } catch (error) {
        return res.status(500).json({ message: 'Error uploading video.', error: error.message });
    }
};

exports.getAllVideos = async function (req, res) {
    try {
        const videos = await videoService.getAllVideos();
        return res.status(200).json(videos);
    } catch (error) {
        return res.status(500).json({ message: 'Error retrieving videos.', error: error.message });
    }
};

exports.getVideoById = async function (req, res) {
    try {
        const { id } = req.params;
        const video = await require('../services/videoService').getVideoById(id);
        if (!video) return res.status(404).json({ message: 'Video not found' });
        res.json(video);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving video', error: error.message });
    }
};