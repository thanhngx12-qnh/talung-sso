// dir: /talung-sso/frontend/src
import { UserManager } from 'oidc-client-ts';

const base = window.location.origin
const authority = import.meta.env.VITE_KEYCLOAK_URL
  ? `${import.meta.env.VITE_KEYCLOAK_URL}/realms/${import.meta.env.VITE_KEYCLOAK_REALM}`
  : 'http://localhost:18080/realms/talung';

const client_id = import.meta.env.VITE_KEYCLOAK_CLIENT_ID || 'task-frontend';
const redirect_uri = `${base}/callback`;
const post_logout_redirect_uri = `${base}/`;
const silent_redirect_uri = `${base}/silent-renew`;

export const userManager = new UserManager({
  authority,
  client_id,
  redirect_uri,
  post_logout_redirect_uri,
  response_type: 'code',
  scope: 'openid profile email',
  // Silent renew
  automaticSilentRenew: true,
  silent_redirect_uri,
  monitorSession: false
});
