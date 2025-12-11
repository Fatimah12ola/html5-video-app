const express = require('express');
const router = express.Router();
const commentsController = require('../controllers/commentsController');

// Route to get all comments for a specific video
router.get('/:videoId', commentsController.getComments);

// Route to add a new comment to a specific video
router.post('/:videoId', commentsController.addComment);

module.exports = router;