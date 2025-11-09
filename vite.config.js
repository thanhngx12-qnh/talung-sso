// dir: /talung-sso/frontend
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    // bạn có thể đổi port nếu muốn 5174
    port: 5173,
    strictPort: false
  }
})
