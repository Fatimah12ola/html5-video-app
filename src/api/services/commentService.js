const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const cosmosService = require('./cosmosService');
const config = require('../../config/default.json');

const dataDir = path.join(__dirname, '..', '..', 'data');
const commentsFile = path.join(dataDir, 'comments.json');

function ensureData() {
    if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });
    if (!fs.existsSync(commentsFile)) fs.writeFileSync(commentsFile, '[]');
}

async function getCommentsByVideoId(videoId) {
    if (config && config.cosmosDb && config.cosmosDb.endpoint) {
        return await cosmosService.getComments(videoId);
    }
    ensureData();
    const arr = JSON.parse(fs.readFileSync(commentsFile));
    return arr.filter(c => c.videoId === videoId);
}

async function createComment(videoId, text) {
    const newItem = { id: uuidv4(), videoId, text, createdAt: new Date().toISOString() };
    if (config && config.cosmosDb && config.cosmosDb.endpoint) {
        return await cosmosService.createComment(newItem);
    }
    ensureData();
    const arr = JSON.parse(fs.readFileSync(commentsFile));
    arr.unshift(newItem);
    fs.writeFileSync(commentsFile, JSON.stringify(arr, null, 2));
    return newItem;
}

module.exports = { getCommentsByVideoId, createComment };
