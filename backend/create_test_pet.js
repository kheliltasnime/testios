const { pool } = require('./config/database');

async function createTestPet() {
  try {
    // Récupérer l'utilisateur de test
    const userResult = await pool.query('SELECT id FROM users WHERE email = $1', ['testuser@example.com']);
    
    if (userResult.rows.length === 0) {
      console.log('Utilisateur de test non trouvé');
      return;
    }
    
    const userId = userResult.rows[0].id;
    
    // Supprimer les animaux de test existants
    await pool.query('DELETE FROM pets WHERE user_id = $1 AND name ILIKE $2', [userId, 'test%']);
    
    // Créer plusieurs animaux de test
    const pets = [
      {
        name: 'Rex',
        species: 'chien',
        breed: 'Golden Retriever',
        weight: 25.5,
        birth_date: '2022-05-15',
        special_needs: 'Aucun'
      },
      {
        name: 'Mia',
        species: 'chat',
        breed: 'Siamois',
        weight: 4.2,
        birth_date: '2021-08-20',
        special_needs: 'Allergie au poulet'
      },
      {
        name: 'Lucky',
        species: 'lapin',
        breed: 'Lop',
        weight: 2.1,
        birth_date: '2023-01-10',
        special_needs: 'Régime spécial'
      }
    ];
    
    for (const pet of pets) {
      const result = await pool.query(
        `INSERT INTO pets (user_id, name, species, breed, weight, birth_date, special_needs) 
         VALUES ($1, $2, $3, $4, $5, $6, $7) 
         RETURNING id, name, species`,
        [userId, pet.name, pet.species, pet.breed, pet.weight, pet.birth_date, pet.special_needs]
      );
      
      console.log(`✅ Animal créé: ${result.rows[0].name} (${result.rows[0].species})`);
    }
    
    console.log('\n🎉 Animaux de test créés avec succès!');
    console.log('Vous pouvez maintenant tester la réservation avec ces animaux.');
    
  } catch (error) {
    console.error('❌ Erreur lors de la création des animaux:', error.message);
  } finally {
    process.exit(0);
  }
}

createTestPet();
