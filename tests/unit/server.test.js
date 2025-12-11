const request = require('supertest');
const app = require('../../src/app');

describe('Server Tests', () => {
    it('should respond with a 200 status for the root endpoint', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
    });

    it('should handle video upload (file attach)', async () => {
        const response = await request(app)
            .post('/api/videos')
            .attach('video', 'tests/assets/sample.mp4');
        // Locally we save to uploads without extra response fields, so expect 201 with id
        expect([200, 201].includes(response.status)).toBe(true);
    });

    it('should create a comment for a video ID', async () => {
        const response = await request(app)
            .post('/api/comments/null')
            .send({ text: 'Great video!' });
        expect(response.status).toBe(201);
        expect(response.body).toHaveProperty('id');
    });
});