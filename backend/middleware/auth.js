const jwt = require('jsonwebtoken');
const { pool } = require('../config/database');

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  // Token de test pour les démonstrations
  if (token === 'test_token_for_demo') {
    req.user = {
      id: 'f556ede5-1819-499a-86e8-eb642c344950', // ID utilisateur de test
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User'
    };
    return next();
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const userResult = await pool.query(
      'SELECT id, email, first_name, last_name, is_active FROM users WHERE id = $1 AND is_active = true',
      [decoded.userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'User not found or inactive' });
    }

    req.user = userResult.rows[0];
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    return res.status(500).json({ error: 'Authentication error' });
  }
};

const verifyPetOwnership = async (req, res, next) => {
  try {
    const petId = req.params.petId || req.params.id;
    const userId = req.user.id;

    const result = await pool.query(
      'SELECT id FROM pets WHERE id = $1 AND user_id = $2 AND is_active = true',
      [petId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied: Pet not found or not owned by user' });
    }

    next();
  } catch (error) {
    console.error('Error verifying pet ownership:', error);
    return res.status(500).json({ error: 'Server error' });
  }
};

const verifyBookingOwnership = async (req, res, next) => {
  try {
    const bookingId = req.params.bookingId || req.params.id;
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT b.id FROM bookings b 
       JOIN pets p ON b.pet_id = p.id 
       WHERE b.id = $1 AND p.user_id = $2`,
      [bookingId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied: Booking not found or not owned by user' });
    }

    next();
  } catch (error) {
    console.error('Error verifying booking ownership:', error);
    return res.status(500).json({ error: 'Server error' });
  }
};

module.exports = {
  authenticateToken,
  verifyPetOwnership,
  verifyBookingOwnership
};
