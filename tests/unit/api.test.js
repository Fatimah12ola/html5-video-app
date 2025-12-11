const request = require('supertest');
const app = require('../../src/app');

describe('API basic tests', () => {
	it('GET /api/videos returns 200 and array', async () => {
		const res = await request(app).get('/api/videos');
		expect(res.statusCode).toBe(200);
		expect(Array.isArray(res.body)).toBe(true);
	});
});