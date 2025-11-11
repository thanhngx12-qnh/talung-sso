<!-- dir: /talung-sso/frontend/src -->
<script setup>
import { userManager } from './oidc.js'

// Khi Keycloak redirect về trang này (ẩn trong iframe), xử lý token xong là kết thúc
userManager.signinSilentCallback().catch((e) => {
  console.error('Silent renew error:', e)
})
</script>

<template>
  <div>Silent renew...</div>
</template>
