const { pool } = require('./config/database');
const bcrypt = require('bcryptjs');

async function createTestUser() {
  try {
    const email = 'testuser@example.com';
    const password = 'test123';
    const firstName = 'Test';
    const lastName = 'User';
    
    // Check if user exists
    const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existing.rows.length > 0) {
      console.log('User already exists, deleting...');
      await pool.query('DELETE FROM users WHERE email = $1', [email]);
    }
    
    // Create user
    const saltRounds = 12;
    const passwordHash = await bcrypt.hash(password, saltRounds);
    
    const result = await pool.query(
      'INSERT INTO users (email, password_hash, first_name, last_name) VALUES ($1, $2, $3, $4) RETURNING id, email',
      [email, passwordHash, firstName, lastName]
    );
    
    console.log('Created user:', result.rows[0]);
    console.log('You can now login with:', email, password);
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    process.exit(0);
  }
}

createTestUser();
