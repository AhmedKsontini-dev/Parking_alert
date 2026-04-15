require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const connectDB = require('./config/db');

const app = express();

connectDB();

app.use(cors({
  origin: ['http://localhost:53311/'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// routes
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/alerts', require('./routes/alertRoutes'));

app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin.html'));
});

app.listen(3000, () => {
  console.log("🚀 Server running on port 3000");
});

module.exports = app;