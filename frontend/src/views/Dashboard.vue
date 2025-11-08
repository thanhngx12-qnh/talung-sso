<!-- frontend/src/views/Dashboard.vue - Updated with Sidebar component -->
<template>
  <div class="dashboard-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar Component -->
        <Sidebar />
        
        <!-- Main content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
          <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <h1 class="h2">Dashboard</h1>
            <div class="btn-toolbar mb-2 mb-md-0">
              <div class="btn-group me-2">
                <button type="button" class="btn btn-sm btn-outline-secondary">
                  <i class="bi bi-download me-1"></i>
                  Export
                </button>
                <button type="button" class="btn btn-sm btn-outline-secondary">
                  <i class="bi bi-filter me-1"></i>
                  Filter
                </button>
              </div>
              <button class="btn btn-sm btn-outline-secondary dropdown-toggle">
                <i class="bi bi-calendar me-1"></i>
                This week
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
                      <small class="opacity-75">+2 từ tuần trước</small>
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
                      <small class="opacity-75">Đang hoạt động</small>
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
                      <small class="opacity-75">Đã tích hợp</small>
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
                      <small class="opacity-75">Lượt đăng nhập</small>
                    </div>
                    <div class="align-self-center">
                      <i class="bi bi-graph-up fs-1 opacity-50"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Charts and Recent Activity -->
          <div class="row">
            <!-- Recent Activity -->
            <div class="col-lg-6 mb-4">
              <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                  <h5 class="card-title mb-0">Hoạt động gần đây</h5>
                  <button class="btn btn-sm btn-outline-primary">Xem tất cả</button>
                </div>
                <div class="card-body">
                  <div class="list-group list-group-flush">
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div class="d-flex align-items-center">
                        <div class="activity-icon bg-success rounded-circle d-flex align-items-center justify-content-center me-3" 
                             style="width: 32px; height: 32px;">
                          <i class="bi bi-person-plus text-white"></i>
                        </div>
                        <div>
                          <div class="fw-medium">Người dùng mới được tạo</div>
                          <small class="text-muted">test.user@talunglogistic.com</small>
                        </div>
                      </div>
                      <small class="text-muted">2 phút trước</small>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div class="d-flex align-items-center">
                        <div class="activity-icon bg-primary rounded-circle d-flex align-items-center justify-content-center me-3" 
                             style="width: 32px; height: 32px;">
                          <i class="bi bi-shield-check text-white"></i>
                        </div>
                        <div>
                          <div class="fw-medium">Role được cập nhật</div>
                          <small class="text-muted">Thêm quyền admin</small>
                        </div>
                      </div>
                      <small class="text-muted">1 giờ trước</small>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div class="d-flex align-items-center">
                        <div class="activity-icon bg-warning rounded-circle d-flex align-items-center justify-content-center me-3" 
                             style="width: 32px; height: 32px;">
                          <i class="bi bi-key text-white"></i>
                        </div>
                        <div>
                          <div class="fw-medium">Password reset</div>
                          <small class="text-muted">User: admin</small>
                        </div>
                      </div>
                      <small class="text-muted">2 giờ trước</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- System Health -->
            <div class="col-lg-6 mb-4">
              <div class="card h-100">
                <div class="card-header">
                  <h5 class="card-title mb-0">Tình trạng hệ thống</h5>
                </div>
                <div class="card-body">
                  <div class="list-group list-group-flush">
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-check-circle-fill text-success me-2"></i>
                        Keycloak Server
                      </div>
                      <span class="badge bg-success">Online</span>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-check-circle-fill text-success me-2"></i>
                        Database
                      </div>
                      <span class="badge bg-success">Healthy</span>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-check-circle-fill text-success me-2"></i>
                        Admin API
                      </div>
                      <span class="badge bg-success">Running</span>
                    </div>
                    <div class="list-group-item d-flex justify-content-between align-items-center">
                      <div>
                        <i class="bi bi-clock-history text-info me-2"></i>
                        Last Backup
                      </div>
                      <span class="text-muted">2 giờ trước</span>
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
import Sidebar from '../components/Sidebar.vue'

export default {
  name: 'Dashboard',
  components: {
    Sidebar
  },
  data() {
    return {
      stats: {
        totalUsers: 1,
        activeSessions: 1,
        applications: 2,
        todayLogins: 3
      }
    }
  }
}
</script>

<style scoped>
.main-content {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.activity-icon {
  width: 32px;
  height: 32px;
  flex-shrink: 0;
}

.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.card-header {
  background-color: white;
  border-bottom: 1px solid #dee2e6;
}
</style>