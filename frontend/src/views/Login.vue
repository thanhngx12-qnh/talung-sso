<!-- frontend/src/views/Login.vue - Login page -->
<template>
  <div class="login-container">
    <div class="row vh-100 g-0">
      <!-- Left Side - Branding -->
      <div class="col-md-6 d-none d-md-flex brand-section">
        <div class="brand-content text-center text-white">
          <div class="brand-logo mb-4">
            <i class="bi bi-truck fs-1"></i>
          </div>
          <h1 class="brand-title fw-bold">Tà Lùng Logistics</h1>
          <p class="brand-subtitle fs-5">Kết nối vận chuyển - Phát triển bền vững</p>
          <div class="mt-5">
            <p class="mb-1">Hệ thống Single Sign-On</p>
            <small>Quản lý tập trung • Bảo mật cao • Dễ sử dụng</small>
          </div>
        </div>
      </div>

      <!-- Right Side - Login Form -->
      <div class="col-md-6 d-flex align-items-center justify-content-center bg-light">
        <div class="login-form-container w-100" style="max-width: 400px;">
          <div class="login-form bg-white rounded-3 shadow-lg p-4">
            <div class="text-center mb-4">
              <div class="login-icon bg-primary rounded-circle d-inline-flex align-items-center justify-content-center mb-3" 
                   style="width: 60px; height: 60px;">
                <i class="bi bi-shield-lock fs-4 text-white"></i>
              </div>
              <h2 class="login-title h4 fw-bold text-dark mb-2">Đăng nhập hệ thống</h2>
              <p class="text-muted mb-0">Vui lòng đăng nhập để tiếp tục</p>
            </div>

            <form @submit.prevent="handleLogin" class="needs-validation" novalidate>
              <div class="mb-3">
                <label for="email" class="form-label fw-medium">Email</label>
                <div class="input-group">
                  <span class="input-group-text bg-light border-end-0">
                    <i class="bi bi-envelope text-muted"></i>
                  </span>
                  <input
                    type="email"
                    class="form-control border-start-0"
                    id="email"
                    placeholder="nhap.email@talunglogistic.com"
                    v-model="loginForm.email"
                    required
                    :disabled="loading"
                  >
                </div>
                <div class="invalid-feedback">Vui lòng nhập email hợp lệ</div>
              </div>

              <div class="mb-3">
                <label for="password" class="form-label fw-medium">Mật khẩu</label>
                <div class="input-group">
                  <span class="input-group-text bg-light border-end-0">
                    <i class="bi bi-lock text-muted"></i>
                  </span>
                  <input
                    :type="showPassword ? 'text' : 'password'"
                    class="form-control border-start-0"
                    id="password"
                    placeholder="Mật khẩu"
                    v-model="loginForm.password"
                    required
                    :disabled="loading"
                  >
                  <button 
                    type="button" 
                    class="input-group-text bg-light border-start-0"
                    @click="showPassword = !showPassword"
                    :disabled="loading"
                  >
                    <i :class="showPassword ? 'bi bi-eye-slash' : 'bi bi-eye'"></i>
                  </button>
                </div>
                <div class="invalid-feedback">Vui lòng nhập mật khẩu</div>
              </div>

              <div class="mb-3 form-check">
                <input
                  type="checkbox"
                  class="form-check-input"
                  id="rememberMe"
                  v-model="loginForm.rememberMe"
                  :disabled="loading"
                >
                <label class="form-check-label text-muted" for="rememberMe">
                  Ghi nhớ đăng nhập
                </label>
              </div>

              <button
                type="submit"
                class="btn btn-primary w-100 py-2 fw-medium"
                :disabled="loading"
              >
                <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="bi bi-box-arrow-in-right me-2"></i>
                {{ loading ? 'Đang đăng nhập...' : 'Đăng nhập' }}
              </button>
            </form>

            <div class="text-center mt-3">
              <div class="d-flex justify-content-center gap-3">
                <a href="#" class="text-decoration-none text-muted small">
                  <i class="bi bi-question-circle me-1"></i>Trợ giúp
                </a>
                <span class="text-muted">|</span>
                <a href="#" class="text-decoration-none text-muted small">
                  <i class="bi bi-key me-1"></i>Quên mật khẩu?
                </a>
              </div>
            </div>

            <!-- Demo credentials for testing -->
            <div class="mt-4 p-3 bg-light rounded">
              <p class="small text-muted mb-2"><strong>Demo Credentials:</strong></p>
              <p class="small text-muted mb-1">Email: test.user@talunglogistic.com</p>
              <p class="small text-muted mb-0">Password: TestPassword123!</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Login',
  data() {
    return {
      loginForm: {
        email: '',
        password: '',
        rememberMe: false
      },
      showPassword: false,
      loading: false
    }
  },
  methods: {
    async handleLogin() {
      this.loading = true
      
      try {
        // TODO: Integrate with Keycloak authentication
        console.log('Login attempt:', this.loginForm)
        
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1500))
        
        // For demo purposes, accept any credentials
        if (this.loginForm.email && this.loginForm.password) {
          this.$router.push('/dashboard')
        } else {
          alert('Vui lòng nhập email và mật khẩu')
        }
      } catch (error) {
        console.error('Login failed:', error)
        alert('Đăng nhập thất bại. Vui lòng thử lại.')
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style scoped>
.login-container {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.brand-section {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  align-items: center;
  justify-content: center;
}

.brand-content {
  text-align: center;
}

.brand-logo i {
  font-size: 4rem;
  opacity: 0.9;
}

.brand-title {
  font-size: 2.5rem;
  font-weight: 300;
  margin-bottom: 0.5rem;
}

.brand-subtitle {
  font-size: 1.2rem;
  opacity: 0.9;
}

.login-form-container {
  padding: 2rem;
}

.login-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .login-container {
    background: #667eea;
  }
  
  .brand-section {
    display: none !important;
  }
}
</style>