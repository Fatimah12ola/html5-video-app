const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const videosRoutes = require('./api/routes/videos');
const commentsRoutes = require('./api/routes/comments');
const config = require('config');

const app = express();

// Middleware
app.use(bodyParser.json());
app.use('/videos', videosRoutes);
app.use('/comments', commentsRoutes);

// Connect to MongoDB
mongoose.connect(config.get('db.uri'), { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => {
        console.log('Connected to MongoDB');
        const PORT = process.env.PORT || 5000;
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('Could not connect to MongoDB', err);
    });