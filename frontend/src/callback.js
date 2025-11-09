// dir: /talung-sso/frontend/src
import { userManager } from './oidc.js';

export default {
  template: `
    <div style="font-family: system-ui; padding: 16px">
      <h2>Callback</h2>
      <p>Đang xử lý đăng nhập...</p>
    </div>
  `,
  async mounted() {
    try {
      await userManager.signinRedirectCallback();
      window.location.replace('/');
    } catch (e) {
      console.error('Callback error:', e);
      alert('Đăng nhập thất bại: ' + (e?.message || e));
    }
  }
};