// dir: /talung-sso/backend/src/routes
import express from 'express';
import { requireAuth } from '../middleware/auth.js';

const router = express.Router();

// Protected endpoint
router.get('/', requireAuth, (req, res) => {
  res.json({
    status: 'OK',
    message: 'Secure data from Talung SSO Backend',
    user: req.user, // payload đã verify
    timestamp: new Date().toISOString()
  });
});

export default router;
