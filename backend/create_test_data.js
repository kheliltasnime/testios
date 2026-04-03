const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'ma_base',
  user: 'postgres',
  password: '',
});

async function createTestData() {
  try {
    const client = await pool.connect();
    console.log('✅ Connecté à la base de données');

    // Créer un utilisateur de test
    const userResult = await client.query(`
      INSERT INTO users (email, password_hash, first_name, last_name, is_active) 
      VALUES ($1, $2, $3, $4, $5) 
      ON CONFLICT (email) DO NOTHING 
      RETURNING id
    `, ['test@example.com', 'hashed_password', 'Test', 'User', true]);

    let userId;
    if (userResult.rows.length > 0) {
      userId = userResult.rows[0].id;
      console.log('✅ Utilisateur de test créé');
    } else {
      // Récupérer l'utilisateur existant
      const existingUser = await client.query(
        'SELECT id FROM users WHERE email = $1',
        ['test@example.com']
      );
      userId = existingUser.rows[0].id;
      console.log('🔄 Utilisateur de test existant récupéré');
    }

    // Créer un animal de test
    const petResult = await client.query(`
      INSERT INTO pets (user_id, name, species, breed, birth_date, weight, is_active) 
      VALUES ($1, $2, $3, $4, $5, $6, $7) 
      ON CONFLICT DO NOTHING 
      RETURNING id
    `, [userId, 'Medor', 'chien', 'Golden Retriever', '2021-01-15', 25.5, true]);

    let petId;
    if (petResult.rows.length > 0) {
      petId = petResult.rows[0].id;
      console.log('✅ Animal de test créé');
    } else {
      // Récupérer un animal existant
      const existingPet = await client.query(
        'SELECT id FROM pets WHERE user_id = $1 LIMIT 1',
        [userId]
      );
      if (existingPet.rows.length > 0) {
        petId = existingPet.rows[0].id;
        console.log('🔄 Animal de test existant récupéré');
      }
    }

    console.log('🎉 Données de test créées avec succès!');
    console.log(`📧 Email: test@example.com`);
    console.log(`🆔 User ID: ${userId}`);
    console.log(`🐕 Pet ID: ${petId || 'Non disponible'}`);

    await client.end();
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

createTestData();
