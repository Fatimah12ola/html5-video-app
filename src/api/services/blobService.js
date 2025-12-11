const config = require('../../config/default.json');

const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING || (config.storage && config.storage.connectionString);
const containerName = process.env.AZURE_BLOB_CONTAINER || (config.storage && config.storage.containerName) || 'videos';
let blobServiceClient;
function getBlobServiceClient() {
    if (!connectionString) return null;
    if (!blobServiceClient) {
        const { BlobServiceClient } = require('@azure/storage-blob');
        blobServiceClient = BlobServiceClient.fromConnectionString(connectionString);
    }
    return blobServiceClient;
}

async function uploadVideo(fileName, buffer) {
    const client = getBlobServiceClient();
    if (!client) throw new Error('Azure Blob Storage connection string not configured.');
    const containerClient = client.getContainerClient(containerName);
    await containerClient.createIfNotExists();
    const blockBlobClient = containerClient.getBlockBlobClient(fileName);
    await blockBlobClient.upload(buffer, buffer.length);
    return blockBlobClient.url;
}

async function listVideos() {
    const client = getBlobServiceClient();
    if (!client) throw new Error('Azure Blob Storage connection string not configured.');
    const containerClient = client.getContainerClient(containerName);
    const videoUrls = [];
    for await (const blob of containerClient.listBlobsFlat()) {
        videoUrls.push(blob.name);
    }
    return videoUrls;
}

module.exports = {
    uploadVideo,
    listVideos
};