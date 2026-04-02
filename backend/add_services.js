const { Pool } = require('pg');

const pool = new Pool({
  host: 'localhost',
  port: 5433,
  database: 'ma_base',
  user: 'postgres',
  password: '',
});

async function addServices() {
  try {
    const client = await pool.connect();
    console.log('✅ Connecté à la base de données');
    
    const services = [
      { name: 'Dental care', description: 'Soins dentaires complets pour vos animaux', duration: 60, price: 80 },
      { name: 'Surgery', description: 'Interventions chirurgicales programmées', duration: 120, price: 250 },
      { name: 'X-ray', description: 'Radiographies diagnostiques', duration: 30, price: 60 },
      { name: 'Diagnostics', description: 'Consultations diagnostiques avancées', duration: 45, price: 90 },
      { name: 'Veterinary consultation', description: 'Consultation vétérinaire générale', duration: 30, price: 50 },
      { name: 'Vaccination', description: 'Vaccinations et rappels', duration: 20, price: 40 },
      { name: 'Blood sample', description: 'Prises de sang et analyses', duration: 25, price: 45 },
      { name: 'Killing', description: 'Euthanasie humaine et digne', duration: 60, price: 150 },
      { name: 'Inspection and chip marking', description: 'Inspections et pose de puces électroniques', duration: 30, price: 50 },
      { name: 'Chemical castration', description: 'Castration chimique', duration: 30, price: 120 },
      { name: 'Librela and Solensia', description: 'Traitements anti-douleur Librela et Solensia', duration: 40, price: 100 },
      { name: 'Medical visit', description: 'Visites médicales à domicile', duration: 45, price: 70 },
      { name: 'Dietary advice', description: 'Conseils nutritionnels personnalisés', duration: 30, price: 40 },
      { name: 'Before the trip', description: 'Consultations pré-voyage (certificats, etc.)', duration: 30, price: 55 }
    ];

    for (const service of services) {
      try {
        // D'abord essayer d'insérer
        const result = await client.query(
          'INSERT INTO services (name, description, duration_minutes, price, is_active) VALUES ($1, $2, $3, $4, $5) RETURNING id',
          [service.name, service.description, service.duration, service.price, true]
        );
        
        if (result.rows.length > 0) {
          console.log(`✅ Service ajouté: ${service.name}`);
        }
      } catch (error) {
        // Si le service existe déjà, le mettre à jour
        if (error.code === '23505') { // unique_violation
          const result = await client.query(
            'UPDATE services SET description = $1, duration_minutes = $2, price = $3, is_active = $4 WHERE name = $5 RETURNING id',
            [service.description, service.duration, service.price, true, service.name]
          );
          
          if (result.rows.length > 0) {
            console.log(`🔄 Service mis à jour: ${service.name}`);
          }
        } else {
          throw error;
        }
      }
    }
    
    await client.end();
    console.log('🎉 Tous les services ont été ajoutés avec succès!');
  } catch (error) {
    console.error('❌ Erreur:', error.message);
  }
}

addServices();
