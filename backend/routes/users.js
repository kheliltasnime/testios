const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/dashboard', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const petsResult = await pool.query(
      'SELECT COUNT(*) as total_pets FROM pets WHERE user_id = $1 AND is_active = true',
      [userId]
    );

    const upcomingBookingsResult = await pool.query(
      `SELECT COUNT(*) as upcoming_bookings 
       FROM bookings b
       JOIN pets p ON b.pet_id = p.id
       WHERE b.user_id = $1 AND b.booking_date > CURRENT_TIMESTAMP AND b.status IN ('pending', 'confirmed')`,
      [userId]
    );

    const vaccinationRemindersResult = await pool.query(
      `SELECT COUNT(*) as vaccination_reminders
       FROM vaccinations v
       JOIN pets p ON v.pet_id = p.id
       WHERE p.user_id = $1 
       AND v.next_due_date <= CURRENT_DATE + INTERVAL '30 days'
       AND v.next_due_date >= CURRENT_DATE`,
      [userId]
    );

    const recentPetsResult = await pool.query(
      `SELECT id, name, species, photo_url FROM pets 
       WHERE user_id = $1 AND is_active = true 
       ORDER BY created_at DESC LIMIT 3`,
      [userId]
    );

    const upcomingAppointmentsResult = await pool.query(
      `SELECT b.id, b.booking_date, s.name as service_name, p.name as pet_name, p.photo_url as pet_photo
       FROM bookings b
       JOIN services s ON b.service_id = s.id
       JOIN pets p ON b.pet_id = p.id
       WHERE b.user_id = $1 AND b.booking_date > CURRENT_TIMESTAMP AND b.status IN ('pending', 'confirmed')
       ORDER BY b.booking_date ASC LIMIT 3`,
      [userId]
    );

    const dashboardData = {
      stats: {
        totalPets: parseInt(petsResult.rows[0].total_pets),
        upcomingBookings: parseInt(upcomingBookingsResult.rows[0].upcoming_bookings),
        vaccinationReminders: parseInt(vaccinationRemindersResult.rows[0].vaccination_reminders)
      },
      recentPets: recentPetsResult.rows,
      upcomingAppointments: upcomingAppointmentsResult.rows
    };

    res.json({ dashboard: dashboardData });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard data' });
  }
});

router.get('/notifications', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 20, unreadOnly = false } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT * FROM notifications 
      WHERE user_id = $1
    `;
    const params = [userId];

    if (unreadOnly === 'true') {
      query += ' AND is_read = false';
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = unreadOnly === 'true'
      ? 'SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = false'
      : 'SELECT COUNT(*) FROM notifications WHERE user_id = $1';
    
    const countResult = await pool.query(countQuery, [userId]);

    res.json({
      notifications: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: parseInt(countResult.rows[0].count),
        pages: Math.ceil(countResult.rows[0].count / limit)
      }
    });
  } catch (error) {
    console.error('Get notifications error:', error);
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

router.put('/notifications/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const notificationId = req.params.notificationId;
    const userId = req.user.id;

    const result = await pool.query(
      'UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2 RETURNING *',
      [notificationId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.json({
      message: 'Notification marked as read',
      notification: result.rows[0]
    });
  } catch (error) {
    console.error('Mark notification read error:', error);
    res.status(500).json({ error: 'Failed to mark notification as read' });
  }
});

router.put('/notifications/read-all', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    await pool.query(
      'UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false',
      [userId]
    );

    res.json({
      message: 'All notifications marked as read'
    });
  } catch (error) {
    console.error('Mark all notifications read error:', error);
    res.status(500).json({ error: 'Failed to mark all notifications as read' });
  }
});

router.delete('/notifications/:notificationId', authenticateToken, async (req, res) => {
  try {
    const notificationId = req.params.notificationId;
    const userId = req.user.id;

    const result = await pool.query(
      'DELETE FROM notifications WHERE id = $1 AND user_id = $2 RETURNING *',
      [notificationId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    res.json({
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    console.error('Delete notification error:', error);
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});

router.get('/search', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { q: query, type } = req.query;

    if (!query) {
      return res.status(400).json({ error: 'Search query is required' });
    }

    let results = {};

    if (!type || type === 'pets') {
      const petsResult = await pool.query(
        `SELECT id, name, species, breed, photo_url FROM pets 
         WHERE user_id = $1 AND is_active = true 
         AND (name ILIKE $2 OR breed ILIKE $2 OR species ILIKE $2)
         ORDER BY name ASC LIMIT 10`,
        [userId, `%${query}%`]
      );
      results.pets = petsResult.rows;
    }

    if (!type || type === 'bookings') {
      const bookingsResult = await pool.query(
        `SELECT b.id, b.booking_date, b.status, s.name as service_name, p.name as pet_name
         FROM bookings b
         JOIN services s ON b.service_id = s.id
         JOIN pets p ON b.pet_id = p.id
         WHERE b.user_id = $1
         AND (s.name ILIKE $2 OR p.name ILIKE $2 OR b.notes ILIKE $2)
         ORDER BY b.booking_date DESC LIMIT 10`,
        [userId, `%${query}%`]
      );
      results.bookings = bookingsResult.rows;
    }

    if (!type || type === 'medical') {
      const medicalResult = await pool.query(
        `SELECT mr.id, mr.record_date, mr.diagnosis, mr.treatment, p.name as pet_name
         FROM medical_records mr
         JOIN pets p ON mr.pet_id = p.id
         WHERE p.user_id = $1
         AND (mr.diagnosis ILIKE $2 OR mr.treatment ILIKE $2 OR p.name ILIKE $2)
         ORDER BY mr.record_date DESC LIMIT 10`,
        [userId, `%${query}%`]
      );
      results.medicalRecords = medicalResult.rows;
    }

    res.json({ results });
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Search failed' });
  }
});

router.post('/fcm-token', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    await pool.query(
      `INSERT INTO user_fcm_tokens (user_id, token, created_at)
       VALUES ($1, $2, CURRENT_TIMESTAMP)
       ON CONFLICT (user_id, token) DO UPDATE SET
       last_used = CURRENT_TIMESTAMP`,
      [userId, token]
    );

    res.json({
      message: 'FCM token registered successfully'
    });
  } catch (error) {
    console.error('FCM token registration error:', error);
    res.status(500).json({ error: 'Failed to register FCM token' });
  }
});

router.delete('/fcm-token', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    await pool.query(
      'DELETE FROM user_fcm_tokens WHERE user_id = $1 AND token = $2',
      [userId, token]
    );

    res.json({
      message: 'FCM token removed successfully'
    });
  } catch (error) {
    console.error('FCM token removal error:', error);
    res.status(500).json({ error: 'Failed to remove FCM token' });
  }
});

router.put('/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { firstName, lastName, phone } = req.body;

    console.log('📝 Updating profile for user:', userId);
    console.log('📝 Profile data:', { firstName, lastName, phone });

    // Validation des données
    if (!firstName || !lastName || !phone) {
      return res.status(400).json({ 
        error: 'First name, last name, and phone are required' 
      });
    }

    // Mise à jour du profil utilisateur
    const updateQuery = `
      UPDATE users 
      SET first_name = $1, last_name = $2, phone = $3, updated_at = CURRENT_TIMESTAMP 
      WHERE id = $4 
      RETURNING id, first_name, last_name, email, phone, created_at, updated_at
    `;

    const result = await pool.query(updateQuery, [firstName, lastName, phone, userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const updatedUser = result.rows[0];

    console.log('✅ Profile updated successfully for user:', userId);

    res.json({
      message: 'Profile updated successfully',
      user: {
        id: updatedUser.id,
        firstName: updatedUser.first_name,
        lastName: updatedUser.last_name,
        email: updatedUser.email,
        phone: updatedUser.phone,
        createdAt: updatedUser.created_at,
        updatedAt: updatedUser.updated_at
      }
    });
  } catch (error) {
    console.error('❌ Profile update error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
