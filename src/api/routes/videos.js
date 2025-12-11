const express = require('express');
const router = express.Router();
const videosController = require('../controllers/videosController');
const multer = require('multer');
const path = require('path');
const storage = multer.memoryStorage();
const upload = multer({ storage, limits: { fileSize: 1024 * 1024 * 1024 } });

// Route for uploading a video
router.post('/', upload.single('video'), videosController.uploadVideo);

// Route for retrieving all videos
router.get('/', videosController.getAllVideos);

// Route for retrieving a specific video by ID
router.get('/:id', videosController.getVideoById);

module.exports = router;