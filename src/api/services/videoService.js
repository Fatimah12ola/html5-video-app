const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const blobService = require('./blobService');
const cosmosService = require('./cosmosService');
const config = require('../../config/default.json');

const dataDir = path.join(__dirname, '..', '..', 'data');
const dataFile = path.join(dataDir, 'videos.json');

function ensureData() {
    if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });
    if (!fs.existsSync(dataFile)) fs.writeFileSync(dataFile, '[]');
}

async function getAllVideos() {
    if (config && config.cosmosDb && config.cosmosDb.endpoint) {
        return await cosmosService.getVideos();
    }
    ensureData();
    return JSON.parse(fs.readFileSync(dataFile));
}

async function getVideoById(id) {
    const videos = await getAllVideos();
    return videos.find(v => v.id === id) || null;
}

async function uploadVideo(file) {
    const id = uuidv4();
    const createdAt = new Date().toISOString();
    const originalName = file.originalname || file.filename || 'video';
    let url;
    // if Azure storage configured via env var or real connection string
    const configuredConnectionString = process.env.AZURE_STORAGE_CONNECTION_STRING || (config.storage && config.storage.connectionString);
    if (configuredConnectionString) {
        url = await blobService.uploadVideo(`${id}-${originalName}`, file.buffer);
    } else {
        const uploadsDir = path.join(__dirname, '..', '..', 'uploads');
        if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
        const filename = `${id}-${originalName}`;
        const localPath = path.join(uploadsDir, filename);
        fs.writeFileSync(localPath, file.buffer);
        url = `/uploads/${filename}`;
    }

    const item = { id, originalName, url, mimeType: file.mimetype, size: file.size, createdAt };

    if (config && config.cosmosDb && config.cosmosDb.endpoint) {
        await cosmosService.createVideo(item);
        return item;
    }

    ensureData();
    const arr = JSON.parse(fs.readFileSync(dataFile));
    arr.unshift(item);
    fs.writeFileSync(dataFile, JSON.stringify(arr, null, 2));
    return item;
}

module.exports = { getAllVideos, uploadVideo, getVideoById };
