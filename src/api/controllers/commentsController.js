const commentService = require('../services/commentService');

exports.addComment = async function (req, res) {
    try {
        const { videoId } = req.params;
        const { text } = req.body;
        if (!text) return res.status(400).json({ error: 'Text is required' });
        const newComment = await commentService.createComment(videoId, text);
        res.status(201).json(newComment);
    } catch (error) {
        res.status(500).json({ message: 'Error adding comment', error: error.message });
    }
};

exports.getComments = async function (req, res) {
    try {
        const { videoId } = req.params;
        const comments = await commentService.getCommentsByVideoId(videoId);
        res.status(200).json(comments);
    } catch (error) {
        res.status(500).json({ message: 'Error retrieving comments', error: error.message });
    }
};