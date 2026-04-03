const jwt = require('jsonwebtoken');
const { pool } = require('./database');

function initializeSocket(io) {
  io.use((socket, next) => {
    const token = socket.handshake.auth.token;
    
    if (!token) {
      return next(new Error('Authentication error'));
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.userId;
      next();
    } catch (err) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔗 User ${socket.userId} connected`);

    socket.join(`user_${socket.userId}`);

    socket.on('join_pet_room', (petId) => {
      socket.join(`pet_${petId}`);
      console.log(`🐾 User ${socket.userId} joined pet room ${petId}`);
    });

    socket.on('leave_pet_room', (petId) => {
      socket.leave(`pet_${petId}`);
      console.log(`🚪 User ${socket.userId} left pet room ${petId}`);
    });

    socket.on('booking_update', async (data) => {
      try {
        const { bookingId, status } = data;
        
        const result = await pool.query(
          'UPDATE bookings SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
          [status, bookingId]
        );

        if (result.rows.length > 0) {
          const booking = result.rows[0];
          
          io.to(`user_${booking.user_id}`).emit('booking_updated', {
            bookingId: booking.id,
            status: booking.status,
            updatedAt: booking.updated_at
          });

          console.log(`📅 Booking ${bookingId} updated to ${status}`);
        }
      } catch (error) {
        console.error('❌ Error updating booking:', error);
        socket.emit('error', { message: 'Failed to update booking' });
      }
    });

    socket.on('pet_update', async (data) => {
      try {
        const { petId, updateData } = data;
        
        const setClause = Object.keys(updateData)
          .map((key, index) => `${key} = $${index + 2}`)
          .join(', ');
        
        const values = [petId, ...Object.values(updateData)];
        
        const result = await pool.query(
          `UPDATE pets SET ${setClause}, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *`,
          values
        );

        if (result.rows.length > 0) {
          const pet = result.rows[0];
          
          io.to(`pet_${petId}`).emit('pet_updated', {
            petId: pet.id,
            updateData: updateData,
            updatedAt: pet.updated_at
          });

          console.log(`🐕 Pet ${petId} updated`);
        }
      } catch (error) {
        console.error('❌ Error updating pet:', error);
        socket.emit('error', { message: 'Failed to update pet' });
      }
    });

    socket.on('vaccination_reminder', async (data) => {
      try {
        const { petId, vaccinationId } = data;
        
        const result = await pool.query(
          `SELECT v.*, p.name as pet_name, u.email as owner_email 
           FROM vaccinations v 
           JOIN pets p ON v.pet_id = p.id 
           JOIN users u ON p.user_id = u.id 
           WHERE v.id = $1 AND v.pet_id = $2`,
          [vaccinationId, petId]
        );

        if (result.rows.length > 0) {
          const vaccination = result.rows[0];
          
          io.to(`user_${socket.userId}`).emit('vaccination_reminder', {
            petName: vaccination.pet_name,
            vaccineName: vaccination.vaccine_name,
            nextDueDate: vaccination.next_due_date,
            vaccinationId: vaccination.id
          });

          console.log(`💉 Vaccination reminder sent for ${vaccination.pet_name}`);
        }
      } catch (error) {
        console.error('❌ Error sending vaccination reminder:', error);
        socket.emit('error', { message: 'Failed to send vaccination reminder' });
      }
    });

    socket.on('disconnect', () => {
      console.log(`🔌 User ${socket.userId} disconnected`);
    });
  });

  console.log('🔌 Socket.io initialized');
}

module.exports = { initializeSocket };
