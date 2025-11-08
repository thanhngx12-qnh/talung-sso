// backend/src/utils/keycloak-admin.js - Keycloak Admin Client utility

import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '../../.env.local') });

// Sử dụng REST API thay vì keycloak-admin package để tránh lỗi
class KeycloakAdmin {
  constructor() {
    this.baseUrl = process.env.KEYCLOAK_URL || 'http://localhost:8081';
    this.realm = 'talung';
    this.token = null;
    this.initialized = false;
  }

  async init() {
    if (this.initialized) return;

    try {
      // Get admin token
      const tokenResponse = await fetch(
        `${this.baseUrl}/realms/master/protocol/openid-connect/token`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: new URLSearchParams({
            username: process.env.KEYCLOAK_ADMIN || 'admin',
            password: process.env.KEYCLOAK_ADMIN_PASSWORD || 'admin',
            grant_type: 'password',
            client_id: 'admin-cli',
          }),
        }
      );

      if (!tokenResponse.ok) {
        throw new Error(`Failed to get token: ${tokenResponse.statusText}`);
      }

      const tokenData = await tokenResponse.json();
      this.token = tokenData.access_token;
      this.initialized = true;
      
      console.log('✅ Keycloak Admin Client initialized via REST API');
    } catch (error) {
      console.error('❌ Keycloak Admin Client initialization failed:', error);
      throw error;
    }
  }

  async makeRequest(endpoint, options = {}) {
    await this.init();
    
    const url = `${this.baseUrl}/admin/realms/${this.realm}${endpoint}`;
    const config = {
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Content-Type': 'application/json',
        ...options.headers,
      },
      ...options,
    };

    const response = await fetch(url, config);
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    // Nếu response có content, parse JSON
    const contentLength = response.headers.get('content-length');
    if (contentLength && parseInt(contentLength) > 0) {
      return await response.json();
    }
    
    return null;
  }

  async getUsers() {
    return this.makeRequest('/users');
  }

  async getUserById(id) {
    return this.makeRequest(`/users/${id}`);
  }

  async createUser(userData) {
    return this.makeRequest('/users', {
      method: 'POST',
      body: JSON.stringify({
        ...userData,
        enabled: true,
        credentials: [{
          type: 'password',
          value: 'TempPassword123!',
          temporary: true,
        }],
      }),
    });
  }

  async updateUser(id, userData) {
    return this.makeRequest(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(userData),
    });
  }

  async deleteUser(id) {
    return this.makeRequest(`/users/${id}`, {
      method: 'DELETE',
    });
  }
}

export default new KeycloakAdmin();