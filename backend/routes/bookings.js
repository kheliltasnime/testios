const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken, verifyPetOwnership } = require('../middleware/auth');
const { sendPushNotification } = require('../config/firebase');

const router = express.Router();

router.get('/availability/:serviceId', async (req, res) => {
  try {
    const { serviceId } = req.params;
    const { date } = req.query;
    
    // Si aucune date n'est fournie, utiliser la date du jour
    const targetDate = date ? new Date(date) : new Date();
    const dayOfWeek = targetDate.getDay(); // 0 = Dimanche, 6 = Samedi
    
    // Heures d'ouverture (9h-18h, du lundi au samedi)
    const openingHours = {
      0: [], // Dimanche fermé
      1: [9, 10, 11, 14, 15, 16, 17], // Lundi
      2: [9, 10, 11, 14, 15, 16, 17], // Mardi
      3: [9, 10, 11, 14, 15, 16, 17], // Mercredi
      4: [9, 10, 11, 14, 15, 16, 17], // Jeudi
      5: [9, 10, 11, 14, 15, 16, 17], // Vendredi
      6: [9, 10, 11, 14, 15, 16], // Samedi (ferme à 17h)
    };
    
    const availableHours = openingHours[dayOfWeek] || [];
    
    if (availableHours.length === 0) {
      return res.json({ 
        availableSlots: [],
        message: 'Clinique fermée ce jour'
      });
    }
    
    // Récupérer les rendez-vous existants pour ce service à cette date
    const existingBookings = await pool.query(
      `SELECT booking_date 
       FROM bookings 
       WHERE service_id = $1 
       AND DATE(booking_date) = $2
       AND status NOT IN ('cancelled', 'completed')`,
      [serviceId, targetDate.toISOString().split('T')[0]]
    );
    
    // Filtrer les heures déjà réservées
    const bookedHours = existingBookings.rows.map(booking => {
      const bookingDate = new Date(booking.booking_date);
      return bookingDate.getHours();
    });
    
    const availableSlots = availableHours.filter(hour => !bookedHours.includes(hour));
    
    res.json({ 
      availableSlots: availableSlots.map(hour => ({
        hour: hour,
        time: `${hour.toString().padStart(2, '0')}:00`,
        available: true
      })),
      date: targetDate.toISOString().split('T')[0],
      serviceId
    });
  } catch (error) {
    console.error('❌ Error checking availability:', error);
    res.status(500).json({ error: 'Failed to check availability' });
  }
});

router.get('/services', async (req, res) => { // Temporairement sans auth pour les tests
  try {
    const { species } = req.query;
    
    let query = 'SELECT * FROM services WHERE is_active = true';
    const params = [];

    if (species) {
      query += ' AND species_restrictions ILIKE $1';
      params.push(`%${species}%`);
    }

    const result = await pool.query(query, params);
    res.json({ services: result.rows });
  } catch (error) {
    console.error('❌ Error fetching services:', error);
    res.status(500).json({ error: 'Failed to fetch services' });
  }
});

router.get('/test-bookings', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT b.*, s.name as service_name, p.name as pet_name
      FROM bookings b
      LEFT JOIN services s ON b.service_id = s.id
      LEFT JOIN pets p ON b.pet_id = p.id
      ORDER BY b.created_at DESC
    `);
    
    res.json({ bookings: result.rows });
  } catch (error) {
    console.error('❌ Error fetching test bookings:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { status, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT b.*, s.name as service_name, s.duration_minutes, s.price,
             p.name as pet_name, p.species as pet_species
      FROM bookings b
      JOIN services s ON b.service_id = s.id
      JOIN pets p ON b.pet_id = p.id
      WHERE b.user_id = $1
    `;
    const params = [userId];

    if (status) {
      query += ` AND b.status = $2`;
      params.push(status);
    }

    query += ` ORDER BY b.booking_date DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = status 
      ? 'SELECT COUNT(*) FROM bookings WHERE user_id = $1 AND status = $2'
      : 'SELECT COUNT(*) FROM bookings WHERE user_id = $1';
    
    const countParams = status ? [userId, status] : [userId];
    const countResult = await pool.query(countQuery, countParams);

    res.json({
      bookings: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: parseInt(countResult.rows[0].count),
        pages: Math.ceil(countResult.rows[0].count / limit)
      }
    });
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

router.get('/:bookingId', authenticateToken, async (req, res) => {
  try {
    const bookingId = req.params.bookingId;
    const userId = req.user.id;

    const result = await pool.query(
      `SELECT b.*, s.name as service_name, s.duration_minutes, s.price, s.description,
              p.name as pet_name, p.species as pet_species, p.breed as pet_breed,
              u.first_name, u.last_name, u.email, u.phone
       FROM bookings b
       JOIN services s ON b.service_id = s.id
       JOIN pets p ON b.pet_id = p.id
       JOIN users u ON b.user_id = u.id
       WHERE b.id = $1 AND b.user_id = $2`,
      [bookingId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({ booking: result.rows[0] });
  } catch (error) {
    console.error('Get booking error:', error);
    res.status(500).json({ error: 'Failed to fetch booking' });
  }
});

router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log('📝 Raw request body:', req.body);
    console.log('📝 Content-Type:', req.headers['content-type']);
    
    const userId = req.user.id; // Utiliser l'ID utilisateur réel depuis le token
    
    let petId, serviceId, bookingDate, notes, location;
    
    try {
      ({ petId, serviceId, bookingDate, notes, location } = req.body);
    } catch (parseError) {
      console.error('❌ JSON parsing error:', parseError);
      return res.status(400).json({ error: 'Invalid JSON format' });
    }

    console.log('🔍 Parsed data:', { userId, petId, serviceId, bookingDate, notes, location });

    if (!petId || !serviceId || !bookingDate) {
      return res.status(400).json({ error: 'Pet ID, service ID, and booking date are required' });
    }

    const petCheck = await pool.query(
      'SELECT id, name, species FROM pets WHERE id = $1 AND user_id = $2 AND is_active = true',
      [petId, userId]
    );

    if (petCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found or not owned by user' });
    }

    const serviceCheck = await pool.query(
      'SELECT * FROM services WHERE id = $1 AND is_active = true',
      [serviceId]
    );

    if (serviceCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    const service = serviceCheck.rows[0];
    const pet = petCheck.rows[0];

    if (service.species_restrictions && service.species_restrictions.length > 0) {
      if (!service.species_restrictions.includes(pet.species)) {
        return res.status(400).json({ 
          error: `Service not available for ${pet.species}. Available for: ${service.species_restrictions.join(', ')}`
        });
      }
    }

    // Temporairement désactivé pour les tests
    // const vaccinationCheck = await pool.query(
    //   `SELECT COUNT(*) as required_vaccinations_missing
    //    FROM vaccinations v
    //    WHERE v.pet_id = $1 
    //    AND v.vaccine_name IN ('Rabies', 'DHPP', 'FVRCP')
    //    AND (v.next_due_date IS NULL OR v.next_due_date > CURRENT_DATE)`,
    //   [petId]
    // );

    // const missingVaccinations = parseInt(vaccinationCheck.rows[0].required_vaccinations_missing);
    // if (missingVaccinations > 0) {
    //   return res.status(400).json({ 
    //     error: 'Pet requires updated vaccinations before booking this service',
    //     requiresVaccinations: true
    //   });
    // }

    const existingBooking = await pool.query(
      'SELECT id FROM bookings WHERE pet_id = $1 AND booking_date = $2 AND status IN ($3, $4)',
      [petId, bookingDate, 'pending', 'confirmed']
    );

    if (existingBooking.rows.length > 0) {
      return res.status(409).json({ error: 'Pet already has a booking at this time' });
    }

    const bookingResult = await pool.query(
      `INSERT INTO bookings (user_id, pet_id, service_id, booking_date, notes, status, location)
       VALUES ($1, $2, $3, $4, $5, 'pending', $6)
       RETURNING *`,
      [userId, petId, serviceId, bookingDate, notes, location]
    );

    const booking = bookingResult.rows[0];

    // Temporairement désactivé pour les tests
    // try {
    //   await sendPushNotification(
    //     req.headers['fcm-token'],
    //     'Booking Confirmed',
    //     `${pet.name}\'s appointment confirmed for ${new Date(bookingDate).toLocaleDateString()}`,
    //     { bookingId: booking.id, type: 'booking' }
    //   );
    // } catch (notificationError) {
    //   console.error('Push notification error:', notificationError);
    // }

    res.status(201).json({
      message: 'Booking created successfully',
      booking: {
        ...booking,
        service_name: service.name,
        pet_name: pet.name
      }
    });
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ error: 'Failed to create booking' });
  }
});

router.put('/:bookingId', authenticateToken, async (req, res) => {
  try {
    const bookingId = req.params.bookingId;
    const userId = req.user.id;
    const { bookingDate, notes, status } = req.body;

    const ownershipCheck = await pool.query(
      `SELECT b.id FROM bookings b
       JOIN pets p ON b.pet_id = p.id
       WHERE b.id = $1 AND p.user_id = $2`,
      [bookingId, userId]
    );

    if (ownershipCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied: Booking not found or not owned by user' });
    }

    const updateFields = [];
    const updateValues = [];
    let paramIndex = 1;

    if (bookingDate !== undefined) {
      updateFields.push(`booking_date = $${paramIndex++}`);
      updateValues.push(bookingDate);
    }
    if (notes !== undefined) {
      updateFields.push(`notes = $${paramIndex++}`);
      updateValues.push(notes);
    }
    if (status !== undefined) {
      const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
      }
      updateFields.push(`status = $${paramIndex++}`);
      updateValues.push(status);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    updateValues.push(bookingId);

    const query = `UPDATE bookings SET ${updateFields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    
    const result = await pool.query(query, updateValues);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({
      message: 'Booking updated successfully',
      booking: result.rows[0]
    });
  } catch (error) {
    console.error('Update booking error:', error);
    res.status(500).json({ error: 'Failed to update booking' });
  }
});

router.delete('/:bookingId', authenticateToken, async (req, res) => {
  try {
    const bookingId = req.params.bookingId;
    const userId = req.user.id;

    const ownershipCheck = await pool.query(
      `SELECT b.id, b.booking_date FROM bookings b
       JOIN pets p ON b.pet_id = p.id
       WHERE b.id = $1 AND p.user_id = $2`,
      [bookingId, userId]
    );

    if (ownershipCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied: Booking not found or not owned by user' });
    }

    const bookingDate = new Date(ownershipCheck.rows[0].booking_date);
    const now = new Date();
    const hoursDifference = (bookingDate - now) / (1000 * 60 * 60);

    if (hoursDifference < 24) {
      return res.status(400).json({ 
        error: 'Bookings can only be cancelled at least 24 hours in advance' 
      });
    }

    const result = await pool.query(
      'UPDATE bookings SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      ['cancelled', bookingId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json({
      message: 'Booking cancelled successfully'
    });
  } catch (error) {
    console.error('Cancel booking error:', error);
    res.status(500).json({ error: 'Failed to cancel booking' });
  }
});

router.get('/availability/:serviceId', authenticateToken, async (req, res) => {
  try {
    const { serviceId } = req.params;
    const { date, petId } = req.query;

    if (!date) {
      return res.status(400).json({ error: 'Date is required' });
    }

    const serviceCheck = await pool.query(
      'SELECT duration_minutes FROM services WHERE id = $1 AND is_active = true',
      [serviceId]
    );

    if (serviceCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Service not found' });
    }

    const service = serviceCheck.rows[0];
    const duration = service.duration_minutes;

    const bookedSlots = await pool.query(
      `SELECT booking_date, status 
       FROM bookings 
       WHERE service_id = $1 
       AND DATE(booking_date) = $2 
       AND status IN ('pending', 'confirmed')`,
      [serviceId, date]
    );

    const workingHours = {
      start: 9,
      end: 17
    };

    const availableSlots = [];
    const currentTime = new Date(`${date}T${String(workingHours.start).padStart(2, '0')}:00:00`);
    const endTime = new Date(`${date}T${String(workingHours.end).padStart(2, '0')}:00:00`);

    while (currentTime < endTime) {
      const slotEnd = new Date(currentTime.getTime() + duration * 60000);
      
      if (slotEnd <= endTime) {
        const isBooked = bookedSlots.rows.some(booking => {
          const bookingStart = new Date(booking.booking_date);
          const bookingEnd = new Date(bookingStart.getTime() + duration * 60000);
          
          return (currentTime < bookingEnd && slotEnd > bookingStart);
        });

        if (!isBooked) {
          availableSlots.push({
            startTime: currentTime.toISOString(),
            endTime: slotEnd.toISOString(),
            available: true
          });
        }
      }

      currentTime.setHours(currentTime.getHours() + 1);
    }

    res.json({
      serviceId,
      date,
      availableSlots,
      duration
    });
  } catch (error) {
    console.error('Get availability error:', error);
    res.status(500).json({ error: 'Failed to fetch availability' });
  }
});

module.exports = router;
