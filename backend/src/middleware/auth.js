// dir: /talung-sso/backend/src/middleware
import { expressjwt as ejwt } from 'express-jwt';
import jwksRsa from 'jwks-rsa';

const realmUrl = process.env.KEYCLOAK_REALM_URL || 'http://localhost:18080/realms/talung';

// Gán decoded JWT vào req.user (mặc định express-jwt v7 là req.auth)
export const requireAuth = ejwt({
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: `${realmUrl}/protocol/openid-connect/certs`,
  }),
  issuer: realmUrl,
  algorithms: ['RS256'],
  requestProperty: 'user', // 👈 QUAN TRỌNG: để /me lấy từ req.user
});
