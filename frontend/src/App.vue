<!-- dir: /talung-sso/frontend/src -->
<script setup>
import { onMounted, ref, computed } from 'vue'
import { userManager } from './oidc.js'
import Callback from './callback.js'
import SilentRenew from './SilentRenew.vue'

const user = ref(null)
const apiBase = import.meta.env.VITE_API_URL || 'http://localhost:3001'
const secureData = ref(null)
const meData = ref(null)
const error = ref(null)
const path = () => window.location.pathname
const isCallback = computed(() => path().startsWith('/callback'))
const isSilentRenew = computed(() => path().startsWith('/silent-renew'))

onMounted(async () => {
  if (isCallback.value || isSilentRenew.value) return
  try {
    user.value = await userManager.getUser()
  } catch (e) {
    console.warn('getUser error', e)
  }
})

async function login() { await userManager.signinRedirect() }
async function logout() { await userManager.signoutRedirect() }

async function callSecureApi() {
  error.value = null
  secureData.value = null
  try {
    const u = user.value || await userManager.getUser()
    if (!u) { error.value = 'Chưa đăng nhập'; return }
    const res = await fetch(`${apiBase}/api/v1/secure`, {
      headers: { Authorization: `Bearer ${u.access_token}` }
    })
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`)
    secureData.value = await res.json()
  } catch (e) {
    error.value = e.message || String(e)
  }
}

async function callMe() {
  error.value = null
  meData.value = null
  try {
    const u = user.value || await userManager.getUser()
    if (!u) { error.value = 'Chưa đăng nhập'; return }
    const res = await fetch(`${apiBase}/api/v1/me`, {
      headers: { Authorization: `Bearer ${u.access_token}` }
    })
    if (!res.ok) throw new Error(`HTTP ${res.status}: ${await res.text()}`)
    meData.value = await res.json()
  } catch (e) {
    error.value = e.message || String(e)
  }
}
</script>

<template>
  <div style="font-family: system-ui; padding: 16px; line-height: 1.5">
    <h1>Talung SSO Frontend (Vue SFC)</h1>

    <SilentRenew v-if="isSilentRenew" />
    <Callback v-else-if="isCallback" />

    <div v-else>
      <p v-if="!user">Chưa đăng nhập.</p>
      <p v-else>Đã đăng nhập: <strong>{{ user?.profile?.preferred_username || user?.profile?.email }}</strong></p>

      <div style="display:flex; gap:8px; margin: 12px 0;">
        <button @click="login">Đăng nhập</button>
        <button v-if="user" @click="logout">Đăng xuất</button>
        <button v-if="user" @click="callSecureApi">Gọi API bảo vệ</button>
        <button v-if="user" @click="callMe">Xem claims (/me)</button>
      </div>

      <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
        <div>
          <h3>/secure</h3>
          <pre v-if="secureData" style="background:#f7f7f7; padding:12px; border-radius:8px;">
{{ JSON.stringify(secureData, null, 2) }}
          </pre>
        </div>
        <div>
          <h3>/me (claims)</h3>
          <pre v-if="meData" style="background:#f7f7f7; padding:12px; border-radius:8px;">
{{ JSON.stringify(meData, null, 2) }}
          </pre>
        </div>
      </div>

      <p v-if="error" style="color:#c00">{{ error }}</p>
    </div>
  </div>
</template>
