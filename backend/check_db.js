const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'ma_base',
  user: 'postgres',
  password: '', // Pas de mot de passe avec la configuration trust
});

async function checkUsers() {
  try {
    const client = await pool.connect();
    console.log('✅ Connecté à la base de données');
    
    const result = await client.query('SELECT id, email, first_name, last_name, is_active FROM users');
    console.log('📋 Utilisateurs trouvés:', result.rows.length);
    
    result.rows.forEach((user, index) => {
      console.log(`\n--- Utilisateur ${index + 1} ---`);
      console.log(`ID: ${user.id}`);
      console.log(`Email: ${user.email}`);
      console.log(`Nom: ${user.first_name} ${user.last_name}`);
      console.log(`Actif: ${user.is_active}`);
    });
    
    await client.end();
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

checkUsers();
