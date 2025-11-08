<!-- frontend/src/views/Dashboard.vue - Dashboard page -->
<template>
  <div class="dashboard-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 d-md-block bg-dark sidebar collapse">
          <div class="position-sticky pt-3">
            <div class="sidebar-header p-3 border-bottom border-secondary">
              <h5 class="text-white mb-0">
                <i class="bi bi-shield-lock me-2"></i>
                SSO Admin
              </h5>
              <small class="text-muted">Tà Lùng Logistics</small>
            </div>
            
            <ul class="nav flex-column mb-2">
              <li class="nav-item">
                <router-link to="/dashboard" class="nav-link active text-white">
                  <i class="bi bi-speedometer2 me-2"></i>
                  Dashboard
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/users" class="nav-link text-white">
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
            </ul>
          </div>
        </div>

        <!-- Main content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
          <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <h1 class="h2">Dashboard</h1>
            <div class="btn-toolbar mb-2 mb-md-0">
              <button class="btn btn-outline-secondary" @click="logout">
                <i class="bi bi-box-arrow-right me-1"></i>
                Đăng xuất
              </button>
            </div>
          </div>

          <!-- Stats Cards -->
          <div class="row mb-4">
            <div class="col-md-3 mb-3">
              <div class="card bg-primary text-white">
                <div class="card-body">
                  <div class="d-flex justify-content-between">
                    <div>
                      <h5 class="card-title">Tổng người dùng</h5>
                      <h2 class="mb-0">{{ stats.totalUsers }}</h2>
                    </div>
                    <div class="align-self-center">
                      <i class="bi bi-people fs-1 opacity-50"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="col-md-3 mb-3">
              <div class="card bg-success text-white">
                <div class="card-body">
                  <div class="d-flex justify-content-between">
                    <div>
                      <h5 class="card-title">Active Sessions</h5>
                      <h2 class="mb-0">{{ stats.activeSessions }}</h2>
                    </div>
                    <div class="align-self-center">
                      <i class="bi bi-person-check fs-1 opacity-50"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="col-md-3 mb-3">
              <div class="card bg-warning text-dark">
                <div class="card-body">
                  <div class="d-flex justify-content-between">
                    <div>
                      <h5 class="card-title">Ứng dụng</h5>
                      <h2 class="mb-0">{{ stats.applications }}</h2>
                    </div>
                    <div class="align-self-center">
                      <i class="bi bi-app-indicator fs-1 opacity-50"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <div class="col-md-3 mb-3">
              <div class="card bg-info text-white">
                <div class="card-body">
                  <div class="d-flex justify-content-between">
                    <div>
                      <h5 class="card-title">Hôm nay</h5>
                      <h2 class="mb-0">{{ stats.todayLogins }}</h2>
                    </div>
                    <div class="align-self-center">
                      <i class="bi bi-graph-up fs-1 opacity-50"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Recent Activity -->
          <div class="row">
            <div class="col-12">
              <div class="card">
                <div class="card-header">
                  <h5 class="card-title mb-0">Hoạt động gần đây</h5>
                </div>
                <div class="card-body">
                  <div class="list-group list-group-flush">
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-person-plus text-success me-2"></i>
                        Người dùng mới được tạo
                      </div>
                      <small class="text-muted">2 phút trước</small>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-shield-check text-primary me-2"></i>
                        Role được cập nhật
                      </div>
                      <small class="text-muted">1 giờ trước</small>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-key text-warning me-2"></i>
                        Password reset
                      </div>
                      <small class="text-muted">2 giờ trước</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Dashboard',
  data() {
    return {
      stats: {
        totalUsers: 1,
        activeSessions: 1,
        applications: 2,
        todayLogins: 3
      }
    }
  },
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
}

.sidebar .nav-link {
  border-radius: 0.375rem;
  margin: 0.125rem 0.5rem;
}

.sidebar .nav-link.active {
  background-color: rgba(255, 255, 255, 0.1);
}

.sidebar .nav-link:hover {
  background-color: rgba(255, 255, 255, 0.05);
}
</style>