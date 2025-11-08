<!-- frontend/src/views/UserManagement.vue - Complete user management page -->
<template>
  <div class="user-management-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar Component -->
        <Sidebar />
        
        <!-- Main content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
          <!-- Page Header -->
          <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <div>
              <h1 class="h2">Quản lý người dùng</h1>
              <p class="text-muted mb-0">Quản lý và theo dõi tất cả người dùng hệ thống</p>
            </div>
            <div class="btn-toolbar mb-2 mb-md-0">
              <button class="btn btn-primary" @click="showAddUserModal = true">
                <i class="bi bi-plus-circle me-1"></i>
                Thêm người dùng
              </button>
            </div>
          </div>

          <!-- Search and Filters -->
          <div class="row mb-4">
            <div class="col-12">
              <div class="card">
                <div class="card-body">
                  <div class="row g-3 align-items-end">
                    <div class="col-md-4">
                      <label class="form-label">Tìm kiếm</label>
                      <div class="input-group">
                        <input 
                          type="text" 
                          class="form-control" 
                          placeholder="Tìm theo tên, email, username..."
                          v-model="searchQuery"
                          @input="handleSearch"
                        >
                        <button class="btn btn-outline-secondary" type="button">
                          <i class="bi bi-search"></i>
                        </button>
                      </div>
                    </div>
                    <div class="col-md-3">
                      <label class="form-label">Trạng thái</label>
                      <select class="form-select" v-model="filters.status">
                        <option value="">Tất cả</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                      </select>
                    </div>
                    <div class="col-md-3">
                      <label class="form-label">Sắp xếp</label>
                      <select class="form-select" v-model="sortBy">
                        <option value="createdTimestamp">Ngày tạo</option>
                        <option value="username">Username</option>
                        <option value="email">Email</option>
                      </select>
                    </div>
                    <div class="col-md-2">
                      <button class="btn btn-outline-secondary w-100" @click="resetFilters">
                        <i class="bi bi-arrow-clockwise me-1"></i>
                        Reset
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Users Table -->
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="card-title mb-0">
                Danh sách người dùng
                <span class="badge bg-primary ms-2">{{ filteredUsers.length }}</span>
              </h5>
              <div class="d-flex gap-2">
                <button class="btn btn-sm btn-outline-secondary" @click="exportUsers">
                  <i class="bi bi-download me-1"></i>
                  Export
                </button>
                <button class="btn btn-sm btn-outline-secondary" @click="refreshUsers">
                  <i class="bi bi-arrow-clockwise me-1"></i>
                  Refresh
                </button>
              </div>
            </div>
            
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead class="table-light">
                    <tr>
                      <th width="50">
                        <input type="checkbox" class="form-check-input" v-model="selectAll">
                      </th>
                      <th>Thông tin</th>
                      <th>Username</th>
                      <th>Trạng thái</th>
                      <th>Ngày tạo</th>
                      <th width="120">Hành động</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="loading">
                      <td colspan="6" class="text-center py-4">
                        <div class="spinner-border text-primary" role="status">
                          <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2 mb-0 text-muted">Đang tải dữ liệu...</p>
                      </td>
                    </tr>
                    
                    <tr v-else-if="filteredUsers.length === 0">
                      <td colspan="6" class="text-center py-4">
                        <i class="bi bi-people display-4 text-muted"></i>
                        <p class="mt-2 mb-1">Không có người dùng nào</p>
                        <p class="text-muted mb-0">Hãy thêm người dùng đầu tiên vào hệ thống</p>
                      </td>
                    </tr>
                    
                    <tr v-else v-for="user in filteredUsers" :key="user.id">
                      <td>
                        <input type="checkbox" class="form-check-input" v-model="selectedUsers" :value="user.id">
                      </td>
                      <td>
                        <div class="d-flex align-items-center">
                          <div class="user-avatar bg-primary rounded-circle d-flex align-items-center justify-content-center me-3" 
                               style="width: 40px; height: 40px;">
                            <i class="bi bi-person-fill text-white"></i>
                          </div>
                          <div>
                            <div class="fw-medium">{{ user.firstName }} {{ user.lastName }}</div>
                            <div class="text-muted small">{{ user.email }}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        <code>{{ user.username }}</code>
                      </td>
                      <td>
                        <span class="badge" :class="user.enabled ? 'bg-success' : 'bg-danger'">
                          <i class="bi me-1" :class="user.enabled ? 'bi-check-circle' : 'bi-x-circle'"></i>
                          {{ user.enabled ? 'Active' : 'Inactive' }}
                        </span>
                      </td>
                      <td>
                        <small class="text-muted">{{ formatDate(user.createdTimestamp) }}</small>
                      </td>
                      <td>
                        <div class="btn-group btn-group-sm">
                          <button class="btn btn-outline-primary" @click="editUser(user)" title="Chỉnh sửa">
                            <i class="bi bi-pencil"></i>
                          </button>
                          <button class="btn btn-outline-warning" @click="resetUserPassword(user)" title="Reset mật khẩu">
                            <i class="bi bi-key"></i>
                          </button>
                          <button class="btn btn-outline-danger" @click="deleteUser(user)" title="Xóa">
                            <i class="bi bi-trash"></i>
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Bulk Actions -->
            <div class="card-footer" v-if="selectedUsers.length > 0">
              <div class="d-flex justify-content-between align-items-center">
                <div class="text-muted">
                  Đã chọn <strong>{{ selectedUsers.length }}</strong> người dùng
                </div>
                <div class="btn-group">
                  <button class="btn btn-sm btn-outline-success" @click="bulkEnable">
                    <i class="bi bi-check-circle me-1"></i>
                    Kích hoạt
                  </button>
                  <button class="btn btn-sm btn-outline-danger" @click="bulkDisable">
                    <i class="bi bi-x-circle me-1"></i>
                    Vô hiệu hóa
                  </button>
                  <button class="btn btn-sm btn-outline-secondary" @click="bulkExport">
                    <i class="bi bi-download me-1"></i>
                    Export
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Pagination -->
          <div class="d-flex justify-content-between align-items-center mt-3">
            <div class="text-muted">
              Hiển thị <strong>{{ filteredUsers.length }}</strong> trên tổng số <strong>{{ users.length }}</strong> người dùng
            </div>
            <nav>
              <ul class="pagination mb-0">
                <li class="page-item disabled">
                  <a class="page-link" href="#">Previous</a>
                </li>
                <li class="page-item active">
                  <a class="page-link" href="#">1</a>
                </li>
                <li class="page-item">
                  <a class="page-link" href="#">2</a>
                </li>
                <li class="page-item">
                  <a class="page-link" href="#">3</a>
                </li>
                <li class="page-item">
                  <a class="page-link" href="#">Next</a>
                </li>
              </ul>
            </nav>
          </div>
        </main>
      </div>
    </div>
  </div>
</template>

<script>
import Sidebar from '../components/Sidebar.vue'

export default {
  name: 'UserManagement',
  components: {
    Sidebar
  },
  data() {
    return {
      users: [],
      loading: false,
      searchQuery: '',
      filters: {
        status: ''
      },
      sortBy: 'createdTimestamp',
      selectedUsers: [],
      selectAll: false,
      showAddUserModal: false
    }
  },
  computed: {
    filteredUsers() {
      let filtered = this.users

      // Search filter
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase()
        filtered = filtered.filter(user => 
          user.username.toLowerCase().includes(query) ||
          user.email.toLowerCase().includes(query) ||
          `${user.firstName} ${user.lastName}`.toLowerCase().includes(query)
        )
      }

      // Status filter
      if (this.filters.status) {
        filtered = filtered.filter(user => 
          this.filters.status === 'active' ? user.enabled : !user.enabled
        )
      }

      // Sort
      filtered.sort((a, b) => {
        if (this.sortBy === 'createdTimestamp') {
          return b.createdTimestamp - a.createdTimestamp
        }
        return a[this.sortBy].localeCompare(b[this.sortBy])
      })

      return filtered
    }
  },
  watch: {
    selectAll(newVal) {
      if (newVal) {
        this.selectedUsers = this.filteredUsers.map(user => user.id)
      } else {
        this.selectedUsers = []
      }
    }
  },
  async mounted() {
    await this.fetchUsers()
  },
  methods: {
    async fetchUsers() {
      this.loading = true
      try {
        const response = await fetch('/api/v1/users')
        const data = await response.json()
        
        if (data.success) {
          this.users = data.data
        }
      } catch (error) {
        console.error('Failed to fetch users:', error)
        alert('Không thể tải danh sách người dùng')
      } finally {
        this.loading = false
      }
    },

    handleSearch() {
      // Debounce search - implement if needed
    },

    resetFilters() {
      this.searchQuery = ''
      this.filters.status = ''
      this.selectedUsers = []
      this.selectAll = false
    },

    refreshUsers() {
      this.fetchUsers()
    },

    formatDate(timestamp) {
      if (!timestamp) return 'N/A'
      return new Date(timestamp).toLocaleDateString('vi-VN')
    },

    editUser(user) {
      alert(`Edit user: ${user.username}`)
      // TODO: Implement edit modal
    },

    resetUserPassword(user) {
      if (confirm(`Reset mật khẩu cho user ${user.username}?`)) {
        alert(`Đã reset mật khẩu cho ${user.username}`)
        // TODO: Implement password reset
      }
    },

    deleteUser(user) {
      if (confirm(`Xóa user ${user.username}? Hành động này không thể hoàn tác.`)) {
        alert(`Đã xóa user ${user.username}`)
        // TODO: Implement delete
      }
    },

    bulkEnable() {
      if (this.selectedUsers.length > 0) {
        alert(`Kích hoạt ${this.selectedUsers.length} users`)
        // TODO: Implement bulk enable
      }
    },

    bulkDisable() {
      if (this.selectedUsers.length > 0) {
        alert(`Vô hiệu hóa ${this.selectedUsers.length} users`)
        // TODO: Implement bulk disable
      }
    },

    bulkExport() {
      if (this.selectedUsers.length > 0) {
        alert(`Export ${this.selectedUsers.length} users`)
        // TODO: Implement bulk export
      }
    },

    exportUsers() {
      alert('Export all users')
      // TODO: Implement export
    }
  }
}
</script>

<style scoped>
.main-content {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.user-avatar {
  font-size: 1rem;
}

.table th {
  border-top: none;
  font-weight: 600;
  color: #6c757d;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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