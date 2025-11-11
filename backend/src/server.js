// dir: /talung-sso/backend/src
import express from 'express';
import morgan from 'morgan';
import cors from 'cors';
import dotenv from 'dotenv';
import healthRoutes from './routes/health.js';
import userRoutes from './routes/users.js';
import secureRoutes from './routes/secure.js';
import meRoutes from './routes/me.js';

dotenv.config();

const app = express();
const PORT = process.env.API_PORT || 3001;

app.use(morgan('dev'));
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

app.use('/api/v1/health', healthRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/secure', secureRoutes);
app.use('/api/v1/me', meRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Talung SSO Backend', timestamp: new Date().toISOString() });
});

app.use((err, req, res, next) => {
  if (err.name === 'UnauthorizedError') {
    return res.status(401).json({ error: 'Unauthorized', detail: err.message });
  }
  console.error(err);
  res.status(500).json({ error: 'Internal server error', message: err.message });
});

app.listen(PORT, () => {
  console.log(`🚀 Talung SSO Backend listening on port ${PORT}`);
});
