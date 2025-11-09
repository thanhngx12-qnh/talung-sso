// dir: /talung-sso/frontend/src
import { UserManager } from 'oidc-client-ts';

const authority = import.meta.env.VITE_KEYCLOAK_URL
  ? `${import.meta.env.VITE_KEYCLOAK_URL}/realms/${import.meta.env.VITE_KEYCLOAK_REALM}`
  : 'http://localhost:18080/realms/talung';

const client_id = import.meta.env.VITE_KEYCLOAK_CLIENT_ID || 'task-frontend';
const redirect_uri = `${window.location.origin}/callback`;
const post_logout_redirect_uri = `${window.location.origin}/`;

export const userManager = new UserManager({
  authority,
  client_id,
  redirect_uri,
  post_logout_redirect_uri,
  response_type: 'code',
  scope: 'openid profile email'
});