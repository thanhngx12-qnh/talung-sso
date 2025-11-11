// dir: /talung-sso/backend/src/routes
import express from 'express';
import { requireAuth } from '../middleware/auth.js';

const router = express.Router();

router.get('/', requireAuth, (req, res) => {
  const u = req.user || {};
  res.json({
    status: 'OK',
    subject: u.sub,
    preferred_username: u.preferred_username || u.email || u.sub,
    email: u.email,
    employee_id: u.employee_id,
    department: u.department,
    position: u.position,
    realm_roles: u?.realm_access?.roles || [],
    resource_access: u?.resource_access || {},
    raw: u
  });
});

export default router;
