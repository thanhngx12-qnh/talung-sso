// frontend/src/main.js - Main entry point for Vue.js application

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

// Bootstrap Vue 3
import BootstrapVue3 from 'bootstrap-vue-3'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue-3/dist/bootstrap-vue-3.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(BootstrapVue3)

app.mount('#app')