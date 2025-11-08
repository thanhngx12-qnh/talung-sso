<!-- frontend/src/views/UserManagement.vue - User management page -->
<template>
  <div class="user-management-container">
    <div class="container-fluid">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 d-md-block bg-dark sidebar collapse">
          <!-- Same sidebar as Dashboard -->
        </div>

        <!-- Main content -->
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
          <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <h1 class="h2">Quản lý người dùng</h1>
            <div class="btn-toolbar mb-2 mb-md-0">
              <button class="btn btn-primary" @click="showAddUserModal = true">
                <i class="bi bi-plus-circle me-1"></i>
                Thêm người dùng
              </button>
            </div>
          </div>

          <!-- Users Table -->
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Danh sách người dùng</h5>
            </div>
            <div class="card-body">
              <div class="table-responsive">
                <table class="table table-hover">
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Tên</th>
                      <th>Email</th>
                      <th>Username</th>
                      <th>Trạng thái</th>
                      <th>Hành động</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="user in users" :key="user.id">
                      <td><small class="text-muted">{{ user.id.slice(0, 8) }}...</small></td>
                      <td>{{ user.firstName }} {{ user.lastName }}</td>
                      <td>{{ user.email }}</td>
                      <td>{{ user.username }}</td>
                      <td>
                        <span class="badge" :class="user.enabled ? 'bg-success' : 'bg-danger'">
                          {{ user.enabled ? 'Active' : 'Inactive' }}
                        </span>
                      </td>
                      <td>
                        <button class="btn btn-sm btn-outline-primary me-1">
                          <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger">
                          <i class="bi bi-trash"></i>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
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
  name: 'UserManagement',
  data() {
    return {
      users: [],
      showAddUserModal: false
    }
  },
  async mounted() {
    await this.fetchUsers()
  },
  methods: {
    async fetchUsers() {
      try {
        // TODO: Integrate with actual API
        const response = await fetch('/api/v1/users')
        const data = await response.json()
        
        if (data.success) {
          this.users = data.data
        }
      } catch (error) {
        console.error('Failed to fetch users:', error)
      }
    }
  }
}
</script>