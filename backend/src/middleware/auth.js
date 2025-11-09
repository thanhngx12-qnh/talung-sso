// dir: /talung-sso/backend/src/middleware
import { expressjwt as ejwt } from 'express-jwt';
import jwksRsa from 'jwks-rsa';

const realmUrl = process.env.KEYCLOAK_REALM_URL || 'http://localhost:18080/realms/talung';

// Middleware yêu cầu JWT hợp lệ phát hành bởi Keycloak (RS256)
export const requireAuth = ejwt({
  secret: jwksRsa.expressJwtSecret({
    cache: true,
    rateLimit: true,
    jwksRequestsPerMinute: 5,
    jwksUri: `${realmUrl}/protocol/openid-connect/certs`,
  }),
  issuer: realmUrl,
  algorithms: ['RS256'],
  // audience: 'task-backend', // bật nếu bạn cấu hình aud cho client backend
});
