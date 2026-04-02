const { pool } = require('./config/database');

async function createVeterinaryServices() {
  try {
    const services = [
      {
        name: 'Dental care',
        description: 'Soins dentaires complets pour vos animaux',
        duration_minutes: 45,
        price: 80.00,
        species_restrictions: ['chien', 'chat']
      },
      {
        name: 'Surgery',
        description: 'Interventions chirurgicales programmées',
        duration_minutes: 120,
        price: 250.00,
        species_restrictions: ['chien', 'chat', 'lapin']
      },
      {
        name: 'X-ray',
        description: 'Radiographies diagnostiques',
        duration_minutes: 30,
        price: 60.00,
        species_restrictions: ['chien', 'chat', 'lapin', 'oiseau']
      },
      {
        name: 'Diagnostics',
        description: 'Consultation diagnostique complète',
        duration_minutes: 60,
        price: 90.00,
        species_restrictions: ['chien', 'chat', 'lapin', 'oiseau', 'rongeur']
      },
      {
        name: 'Veterinary consultation',
        description: 'Consultation générale de routine',
        duration_minutes: 30,
        price: 50.00,
        species_restrictions: ['chien', 'chat', 'lapin', 'oiseau', 'rongeur']
      },
      {
        name: 'Vaccination',
        description: 'Vaccins de routine et rappels',
        duration_minutes: 20,
        price: 35.00,
        species_restrictions: ['chien', 'chat', 'lapin']
      },
      {
        name: 'Blood sample',
        description: 'Prises de sang et analyses',
        duration_minutes: 25,
        price: 45.00,
        species_restrictions: ['chien', 'chat', 'lapin']
      },
      {
        name: 'Killing',
        description: 'Euthanasie humane et accompagnement',
        duration_minutes: 60,
        price: 150.00,
        species_restrictions: ['chien', 'chat', 'lapin', 'oiseau', 'rongeur']
      },
      {
        name: 'Inspection and chip marking',
        description: 'Pose de puces électroniques et certificats',
        duration_minutes: 20,
        price: 40.00,
        species_restrictions: ['chien', 'chat', 'lapin']
      },
      {
        name: 'Chemical castration',
        description: 'Stérilisation chimique non chirurgicale',
        duration_minutes: 30,
        price: 120.00,
        species_restrictions: ['chien', 'chat']
      },
      {
        name: 'Librela and Solensia',
        description: 'Traitements contre l\'arthrite et douleurs chroniques',
        duration_minutes: 25,
        price: 85.00,
        species_restrictions: ['chien', 'chat']
      }
    ];

    // Supprimer les services existants
    await pool.query('DELETE FROM services');
    console.log('Anciens services supprimés');

    // Insérer les nouveaux services
    for (const service of services) {
      const result = await pool.query(
        `INSERT INTO services (name, description, duration_minutes, price, species_restrictions, is_active) 
         VALUES ($1, $2, $3, $4, $5, true) 
         RETURNING id, name, price`,
        [service.name, service.description, service.duration_minutes, service.price, service.species_restrictions]
      );
      
      console.log(`✅ Service créé: ${result.rows[0].name} - ${result.rows[0].price}€`);
    }

    console.log('\n🎉 Tous les services vétérinaires ont été créés avec succès!');
    
  } catch (error) {
    console.error('❌ Erreur lors de la création des services:', error.message);
  } finally {
    process.exit(0);
  }
}

createVeterinaryServices();
