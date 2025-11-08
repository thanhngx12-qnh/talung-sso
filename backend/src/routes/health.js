# dir: /talung-sso/backend/src/routes
import express from 'express';
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    status: 'OK',
    service: 'Talung SSO Backend',
    timestamp: new Date().toISOString()
  });
});

export default router;
