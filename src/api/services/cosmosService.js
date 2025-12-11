const config = require('../../config/default.json');

const cosmosEndpoint = process.env.AZURE_COSMOS_ENDPOINT || (config.cosmosDb && config.cosmosDb.endpoint);
const cosmosKey = process.env.AZURE_COSMOS_KEY || (config.cosmosDb && config.cosmosDb.key);
let client;
let databaseId;
let containerIdVideos;
let containerIdComments;
function getCosmosClient() {
    if (!cosmosEndpoint || !cosmosKey) return null;
    if (!client) {
        const { CosmosClient } = require('@azure/cosmos');
        client = new CosmosClient({ endpoint: cosmosEndpoint, key: cosmosKey });
        databaseId = process.env.AZURE_COSMOS_DATABASE || (config.cosmosDb && config.cosmosDb.databaseName);
        containerIdVideos = process.env.AZURE_COSMOS_CONTAINER_VIDEOS || (config.cosmosDb && config.cosmosDb.containerIdVideos);
        containerIdComments = process.env.AZURE_COSMOS_CONTAINER_COMMENTS || (config.cosmosDb && config.cosmosDb.containerIdComments);
    }
    return client;
}

async function createVideo(videoData) {
    const c = getCosmosClient();
    if (!c) throw new Error('Cosmos DB is not configured');
    const { resource: createdItem } = await client
        .database(databaseId)
        .container(containerIdVideos)
        .items.create(videoData);
    return createdItem;
}

async function getVideos() {
    const c = getCosmosClient();
    if (!c) throw new Error('Cosmos DB is not configured');
    const { resources: videos } = await client
        .database(databaseId)
        .container(containerIdVideos)
        .items.readAll()
        .fetchAll();
    return videos;
}

async function createComment(commentData) {
    const c = getCosmosClient();
    if (!c) throw new Error('Cosmos DB is not configured');
    const { resource: createdItem } = await client
        .database(databaseId)
        .container(containerIdComments)
        .items.create(commentData);
    return createdItem;
}

async function getComments(videoId) {
    const query = `SELECT * FROM c WHERE c.videoId = @videoId`;
    const parameters = [{ name: '@videoId', value: videoId }];
    const c = getCosmosClient();
    if (!c) throw new Error('Cosmos DB is not configured');
    const { resources: comments } = await client
        .database(databaseId)
        .container(containerIdComments)
        .items.query({ query, parameters })
        .fetchAll();
    return comments;
}

module.exports = {
    createVideo,
    getVideos,
    createComment,
    getComments,
};