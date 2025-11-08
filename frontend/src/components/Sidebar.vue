<!-- frontend/src/components/Sidebar.vue - Reusable sidebar component -->
<template>
  <div class="col-md-3 col-lg-2 d-md-block bg-dark sidebar">
    <div class="position-sticky pt-3">
      <!-- Sidebar Header -->
      <div class="sidebar-header p-3 border-bottom border-secondary">
        <h5 class="text-white mb-0">
          <i class="bi bi-shield-lock me-2"></i>
          SSO Admin
        </h5>
        <small class="text-muted">Tà Lùng Logistics</small>
      </div>
      
      <!-- Navigation Menu -->
      <ul class="nav flex-column mb-2">
        <li class="nav-item">
          <router-link to="/dashboard" class="nav-link text-white" :class="{ 'active': $route.path === '/dashboard' }">
            <i class="bi bi-speedometer2 me-2"></i>
            Dashboard
          </router-link>
        </li>
        <li class="nav-item">
          <router-link to="/users" class="nav-link text-white" :class="{ 'active': $route.path === '/users' }">
            <i class="bi bi-people me-2"></i>
            Quản lý người dùng
          </router-link>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white" href="#">
            <i class="bi bi-building me-2"></i>
            Quản lý nhóm
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white" href="#">
            <i class="bi bi-shield-check me-2"></i>
            Quản lý vai trò
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white" href="#">
            <i class="bi bi-app-indicator me-2"></i>
            Quản lý ứng dụng
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white" href="#">
            <i class="bi bi-clock-history me-2"></i>
            Audit Logs
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link text-white" href="#">
            <i class="bi bi-gear me-2"></i>
            Cài đặt hệ thống
          </a>
        </li>
      </ul>

      <!-- User Info & Logout -->
      <div class="sidebar-footer p-3 border-top border-secondary mt-auto">
        <div class="d-flex align-items-center text-white mb-2">
          <div class="user-avatar bg-primary rounded-circle d-flex align-items-center justify-content-center me-2" 
               style="width: 32px; height: 32px;">
            <i class="bi bi-person-fill text-white"></i>
          </div>
          <div>
            <div class="small fw-bold">Admin User</div>
            <div class="small text-muted">Quản trị viên</div>
          </div>
        </div>
        <button class="btn btn-outline-light btn-sm w-100" @click="logout">
          <i class="bi bi-box-arrow-right me-1"></i>
          Đăng xuất
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Sidebar',
  methods: {
    logout() {
      this.$router.push('/')
    }
  }
}
</script>

<style scoped>
.sidebar {
  min-height: 100vh;
  box-shadow: inset -1px 0 0 rgba(0, 0, 0, .1);
  display: flex;
  flex-direction: column;
}

.sidebar .nav-link {
  border-radius: 0.375rem;
  margin: 0.125rem 0.5rem;
  transition: all 0.2s ease;
}

.sidebar .nav-link.active {
  background-color: rgba(255, 255, 255, 0.1);
  font-weight: 500;
}

.sidebar .nav-link:hover:not(.active) {
  background-color: rgba(255, 255, 255, 0.05);
}

.sidebar-footer {
  margin-top: auto;
}

.user-avatar {
  font-size: 0.875rem;
}
</style>