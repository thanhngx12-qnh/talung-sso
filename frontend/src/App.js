// dir: /talung-sso/frontend/src
import { userManager } from './oidc.js';
import Callback from './callback.js';

function isCallbackRoute() {
  return window.location.pathname.startsWith('/callback');
}

export default {
  components: { Callback },
  data() {
    return {
      user: null,
      secureData: null,
      error: null,
      apiBase: import.meta.env.VITE_API_URL || 'http://localhost:3001'
    };
  },
  async created() {
    if (isCallbackRoute()) return; // để component Callback xử lý

    // Thử lấy user đã đăng nhập (nếu có)
    try {
      this.user = await userManager.getUser();
    } catch (e) {
      console.warn('getUser error', e);
    }
  },
  methods: {
    async login() {
      await userManager.signinRedirect();
    },
    async logout() {
      await userManager.signoutRedirect();
    },
    async callSecureApi() {
      this.error = null;
      this.secureData = null;
      try {
        const u = this.user || await userManager.getUser();
        if (!u) {
          this.error = 'Chưa đăng nhập';
          return;
        }
        const res = await fetch(`${this.apiBase}/api/v1/secure`, {
          headers: { Authorization: `Bearer ${u.access_token}` }
        });
        if (!res.ok) {
          const txt = await res.text();
          throw new Error(`HTTP ${res.status}: ${txt}`);
        }
        this.secureData = await res.json();
      } catch (e) {
        this.error = e.message || String(e);
      }
    }
  },
  template: `
    <div style="font-family: system-ui; padding: 16px">
      <h1>Talung SSO Frontend (Demo)</h1>

      <div v-if="isCallback">
        <Callback />
      </div>

      <div v-else>
        <p v-if="!user">Chưa đăng nhập.</p>
        <p v-else>
          Đã đăng nhập: <strong>{{ user?.profile?.preferred_username || user?.profile?.email }}</strong>
        </p>

        <div style="display:flex; gap:8px; margin: 12px 0;">
          <button @click="login">Đăng nhập</button>
          <button @click="logout" v-if="user">Đăng xuất</button>
          <button @click="callSecureApi" v-if="user">Gọi API bảo vệ</button>
        </div>

        <pre v-if="secureData" style="background:#f7f7f7; padding:12px; border-radius:8px;">
{{ JSON.stringify(secureData, null, 2) }}
        </pre>
        <p v-if="error" style="color:#c00">{{ error }}</p>
      </div>
    </div>
  `,
  computed: {
    isCallback() {
      return isCallbackRoute();
    }
  }
};
