const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'ma_base',
  user: 'postgres',
  password: '',
});

async function addLocationColumn() {
  try {
    const client = await pool.connect();
    console.log('✅ Connecté à la base de données');

    // Ajouter la colonne location si elle n'existe pas
    await client.query(`
      ALTER TABLE bookings 
      ADD COLUMN IF NOT EXISTS location VARCHAR(20) DEFAULT 'clinic'
    `);

    console.log('✅ Colonne location ajoutée avec succès!');

    await client.end();
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

addLocationColumn();
