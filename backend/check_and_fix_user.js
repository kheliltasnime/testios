const { pool } = require('./config/database');
const bcrypt = require('bcryptjs');

async function checkAndFixUser() {
  try {
    const email = 'testuser@example.com';
    const password = 'test123';
    
    // Check if user exists
    const existing = await pool.query('SELECT id, password_hash FROM users WHERE email = $1', [email]);
    
    if (existing.rows.length > 0) {
      console.log('User found:', existing.rows[0].id);
      
      // Test password
      const isValid = await bcrypt.compare(password, existing.rows[0].password_hash);
      console.log('Password valid:', isValid);
      
      if (!isValid) {
        console.log('Updating password...');
        const saltRounds = 12;
        const passwordHash = await bcrypt.hash(password, saltRounds);
        
        await pool.query(
          'UPDATE users SET password_hash = $1 WHERE email = $2',
          [passwordHash, email]
        );
        console.log('Password updated successfully');
      }
    } else {
      console.log('User not found, creating...');
      const saltRounds = 12;
      const passwordHash = await bcrypt.hash(password, saltRounds);
      
      const result = await pool.query(
        'INSERT INTO users (email, password_hash, first_name, last_name) VALUES ($1, $2, $3, $4) RETURNING id, email',
        [email, passwordHash, 'Test', 'User']
      );
      
      console.log('Created user:', result.rows[0]);
    }
    
    console.log('You can now login with:', email, password);
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    process.exit(0);
  }
}

checkAndFixUser();
