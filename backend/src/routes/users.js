// backend/src/routes/users.js - User management routes with Keycloak REST API

import express from 'express';
import keycloakAdmin from '../utils/keycloak-admin.js';

const router = express.Router();

// Get all users
router.get('/', async (req, res) => {
  try {
    const users = await keycloakAdmin.getUsers();
    
    // Format response để frontend dễ sử dụng
    const formattedUsers = users.map(user => ({
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      enabled: user.enabled,
      createdTimestamp: user.createdTimestamp,
      // Thêm các attributes custom nếu có
      attributes: user.attributes || {},
    }));

    res.json({
      success: true,
      data: formattedUsers,
      count: formattedUsers.length,
      message: 'Users fetched successfully'
    });
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch users',
      message: error.message
    });
  }
});

// Get user by ID
router.get('/:id', async (req, res) => {
  try {
    const user = await keycloakAdmin.getUserById(req.params.id);
    
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user',
      message: error.message
    });
  }
});

// Create new user
router.post('/', async (req, res) => {
  try {
    const { email, firstName, lastName, username, attributes } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: 'Email is required'
      });
    }

    const userData = {
      email,
      firstName: firstName || '',
      lastName: lastName || '',
      username: username || email,
      enabled: true,
    };

    // Thêm attributes nếu có
    if (attributes) {
      userData.attributes = attributes;
    }

    const user = await keycloakAdmin.createUser(userData);

    res.status(201).json({
      success: true,
      data: user,
      message: 'User created successfully'
    });
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create user',
      message: error.message
    });
  }
});

// Update user
router.put('/:id', async (req, res) => {
  try {
    const { email, firstName, lastName, enabled, attributes } = req.body;

    const userData = {};
    if (email) userData.email = email;
    if (firstName !== undefined) userData.firstName = firstName;
    if (lastName !== undefined) userData.lastName = lastName;
    if (enabled !== undefined) userData.enabled = enabled;
    if (attributes) userData.attributes = attributes;

    await keycloakAdmin.updateUser(req.params.id, userData);

    res.json({
      success: true,
      message: 'User updated successfully'
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update user',
      message: error.message
    });
  }
});

// Delete user
router.delete('/:id', async (req, res) => {
  try {
    await keycloakAdmin.deleteUser(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete user',
      message: error.message
    });
  }
});

export default router;