const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'ma_base',
  user: 'postgres',
  password: '',
});

async function checkServices() {
  try {
    const client = await pool.connect();
    console.log('✅ Connecté à la base de données');
    
    const result = await client.query('SELECT id, name, duration_minutes, price FROM services WHERE is_active = true ORDER BY name');
    
    console.log(`\n📋 Services disponibles (${result.rows.length}):`);
    result.rows.forEach((service, index) => {
      console.log(`${index + 1}. ${service.name} - ${service.duration_minutes}min - ${service.price}€`);
    });
    
    await client.end();
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

checkServices();
