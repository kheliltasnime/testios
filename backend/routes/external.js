const express = require('express');
const axios = require('axios');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

router.get('/articles', authenticateToken, async (req, res) => {
  try {
    const { category, limit = 10 } = req.query;

    const mockArticles = [
      {
        id: '1',
        title: 'Conseils pour la santé de votre chien',
        summary: 'Découvrez les meilleurs conseils pour maintenir votre chien en bonne santé',
        content: 'Article complet sur la santé canine...',
        category: 'sante',
        species: ['chien'],
        imageUrl: 'https://example.com/dog-health.jpg',
        publishedAt: new Date().toISOString(),
        author: 'Dr. Vétérinaire',
        readTime: 5
      },
      {
        id: '2',
        title: 'L\'alimentation idéale pour votre chat',
        summary: 'Guide complet sur l\'alimentation féline',
        content: 'Article complet sur l\'alimentation du chat...',
        category: 'alimentation',
        species: ['chat'],
        imageUrl: 'https://example.com/cat-food.jpg',
        publishedAt: new Date().toISOString(),
        author: 'Nutritionniste Animal',
        readTime: 7
      },
      {
        id: '3',
        title: 'Soins de base pour les lapins',
        summary: 'Tout savoir sur les soins essentiels pour votre lapin',
        content: 'Article complet sur les soins du lapin...',
        category: 'soins',
        species: ['lapin'],
        imageUrl: 'https://example.com/rabbit-care.jpg',
        publishedAt: new Date().toISOString(),
        author: 'Spécialiste Petits Animaux',
        readTime: 6
      }
    ];

    let filteredArticles = mockArticles;

    if (category) {
      filteredArticles = filteredArticles.filter(article => 
        article.category === category
      );
    }

    res.json({
      articles: filteredArticles.slice(0, parseInt(limit)),
      total: filteredArticles.length
    });
  } catch (error) {
    console.error('Get articles error:', error);
    res.status(500).json({ error: 'Failed to fetch articles' });
  }
});

router.get('/campaigns', authenticateToken, async (req, res) => {
  try {
    const { species, active = true } = req.query;

    const mockCampaigns = [
      {
        id: '1',
        title: '-20% sur le toilettage canin',
        description: 'Profitez d\'une réduction de 20% sur tous les services de toilettage pour chiens',
        discount: 20,
        discountType: 'percentage',
        applicableServices: ['toilettage'],
        species: ['chien'],
        imageUrl: 'https://example.com/dog-grooming-promo.jpg',
        startDate: new Date().toISOString(),
        endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        isActive: true,
        code: 'DOG20'
      },
      {
        id: '2',
        title: 'Consultation féline à prix réduit',
        description: 'Consultation vétérinaire pour chats à -15%',
        discount: 15,
        discountType: 'percentage',
        applicableServices: ['consultation'],
        species: ['chat'],
        imageUrl: 'https://example.com/cat-consultation-promo.jpg',
        startDate: new Date().toISOString(),
        endDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toISOString(),
        isActive: true,
        code: 'CAT15'
      },
      {
        id: '3',
        title: 'Pack vaccination complet',
        description: 'Vaccination complète pour tous les animaux à tarif spécial',
        discount: 30,
        discountType: 'percentage',
        applicableServices: ['vaccination'],
        species: ['chien', 'chat', 'lapin'],
        imageUrl: 'https://example.com/vaccination-package.jpg',
        startDate: new Date().toISOString(),
        endDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000).toISOString(),
        isActive: true,
        code: 'VACC30'
      }
    ];

    let filteredCampaigns = mockCampaigns;

    if (active === 'true') {
      const now = new Date();
      filteredCampaigns = filteredCampaigns.filter(campaign => 
        campaign.isActive && 
        new Date(campaign.startDate) <= now && 
        new Date(campaign.endDate) >= now
      );
    }

    if (species) {
      filteredCampaigns = filteredCampaigns.filter(campaign => 
        campaign.species.includes(species)
      );
    }

    res.json({
      campaigns: filteredCampaigns,
      total: filteredCampaigns.length
    });
  } catch (error) {
    console.error('Get campaigns error:', error);
    res.status(500).json({ error: 'Failed to fetch campaigns' });
  }
});

router.get('/veterinary-data/:petId', authenticateToken, async (req, res) => {
  try {
    const petId = req.params.petId;
    const userId = req.user.id;

    const petCheck = await pool.query(
      'SELECT id, name, species, breed, birth_date FROM pets WHERE id = $1 AND user_id = $1 AND is_active = true',
      [petId, userId]
    );

    if (petCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found or not owned by user' });
    }

    const pet = petCheck.rows[0];

    const mockVetData = {
      petId: pet.id,
      petName: pet.name,
      species: pet.species,
      breed: pet.breed,
      age: calculateAge(pet.birth_date),
      recommendedVaccinations: getRecommendedVaccinations(pet.species),
      healthTips: getHealthTips(pet.species),
      breedSpecificInfo: getBreedSpecificInfo(pet.species, pet.breed),
      lastSync: new Date().toISOString()
    };

    function calculateAge(birthDate) {
      const birth = new Date(birthDate);
      const now = new Date();
      const years = Math.floor((now - birth) / (365.25 * 24 * 60 * 60 * 1000));
      const months = Math.floor(((now - birth) % (365.25 * 24 * 60 * 60 * 1000)) / (30.44 * 24 * 60 * 60 * 1000));
      return { years, months };
    }

    function getRecommendedVaccinations(species) {
      const vaccinations = {
        chien: [
          { name: 'DHPP', description: 'Distemper, Hepatitis, Parainfluenza, Parvovirus', frequency: 'Annuel' },
          { name: 'Rage', description: 'Vaccination antirabique', frequency: 'Tous les 3 ans' },
          { name: 'Leptospirose', description: 'Protection contre la leptospirose', frequency: 'Annuel' }
        ],
        chat: [
          { name: 'FVRCP', description: 'Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia', frequency: 'Annuel' },
          { name: 'Rage', description: 'Vaccination antirabique', frequency: 'Tous les 3 ans' },
          { name: 'Leucose féline', description: 'Vaccination contre la leucose', frequency: 'Annuel' }
        ],
        lapin: [
          { name: 'VHD', description: 'Viral Hemorrhagic Disease', frequency: 'Annuel' },
          { name: 'Myxomatose', description: 'Vaccination contre la myxomatose', frequency: 'Semestriel' }
        ]
      };
      return vaccinations[species] || [];
    }

    function getHealthTips(species) {
      const tips = {
        chien: [
          'Brossez les dents de votre chien régulièrement',
          'Assurez-vous de faire de l\'exercice quotidien',
          'Surveillez le poids et ajustez l\'alimentation',
          'Faites des contrôles vétérinaires annuels'
        ],
        chat: [
          'Maintenez la litière propre',
          'Fournissez des griffoirs pour l\'hygiène des griffes',
          'Surveillez l\'hydratation et l\'alimentation',
          'Faites stériliser pour prévenir certaines maladies'
        ],
        lapin: [
          'Fournissez du foin de qualité en permanence',
          'Maintenez une température stable',
          'Surveillez la santé dentaire régulièrement',
          'Assurez un espace suffisant pour l\'exercice'
        ]
      };
      return tips[species] || [];
    }

    function getBreedSpecificInfo(species, breed) {
      const breedInfo = {
        chien: {
          'Golden Retriever': { temperament: 'Amical, intelligent', commonIssues: ['Dysplasie de la hanche', 'Problèmes cardiaques'] },
          'Berger Allemand': { temperament: 'Loyal, protecteur', commonIssues: ['Dysplasie', 'Problèmes digestifs'] },
          'Caniche': { temperament: 'Intelligent, actif', commonIssues: ['Problèmes oculaires', 'Allergies cutanées'] }
        },
        chat: {
          'Siamois': { temperament: 'Vocal, social', commonIssues: ['Problèmes respiratoires', 'Maladies dentaires'] },
          'Persan': { temperament: 'Calme, affectueux', commonIssues: ['Problèmes respiratoires', 'Maladies rénales'] },
          'European': { temperament: 'Indépendant, chasseur', commonIssues: ['Obésité', 'Problèmes dentaires'] }
        }
      };
      return breedInfo[species]?.[breed] || { temperament: 'Standard', commonIssues: ['Aucun spécifique connu'] };
    }

    res.json({ veterinaryData: mockVetData });
  } catch (error) {
    console.error('Get veterinary data error:', error);
    res.status(500).json({ error: 'Failed to fetch veterinary data' });
  }
});

router.post('/sync-vaccinations/:petId', authenticateToken, async (req, res) => {
  try {
    const petId = req.params.petId;
    const userId = req.user.id;
    const { externalSource } = req.body;

    const petCheck = await pool.query(
      'SELECT id, name, species FROM pets WHERE id = $1 AND user_id = $2 AND is_active = true',
      [petId, userId]
    );

    if (petCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found or not owned by user' });
    }

    const mockExternalVaccinations = [
      {
        vaccineName: 'DHPP',
        administrationDate: '2024-01-15',
        nextDueDate: '2025-01-15',
        veterinarianName: 'Dr. Martin',
        externalId: 'ext_123456',
        source: externalSource || 'AnimalData'
      },
      {
        vaccineName: 'Rage',
        administrationDate: '2024-02-20',
        nextDueDate: '2027-02-20',
        veterinarianName: 'Dr. Dupont',
        externalId: 'ext_789012',
        source: externalSource || 'AnimalData'
      }
    ];

    const syncedVaccinations = [];

    for (const vacc of mockExternalVaccinations) {
      const existingVacc = await pool.query(
        'SELECT id FROM vaccinations WHERE pet_id = $1 AND vaccine_name = $2 AND external_id = $3',
        [petId, vacc.vaccineName, vacc.externalId]
      );

      if (existingVacc.rows.length === 0) {
        const result = await pool.query(
          `INSERT INTO vaccinations (pet_id, vaccine_name, administration_date, next_due_date, veterinarian_name, external_id, notes)
           VALUES ($1, $2, $3, $4, $5, $6, $7)
           RETURNING *`,
          [petId, vacc.vaccineName, vacc.administrationDate, vacc.nextDueDate, vacc.veterinarianName, vacc.externalId, `Synchronisé depuis ${vacc.source}`]
        );

        syncedVaccinations.push(result.rows[0]);
      }
    }

    res.json({
      message: 'Vaccinations synchronized successfully',
      synchronizedVaccinations: syncedVaccinations,
      totalSynced: syncedVaccinations.length
    });
  } catch (error) {
    console.error('Sync vaccinations error:', error);
    res.status(500).json({ error: 'Failed to synchronize vaccinations' });
  }
});

router.get('/emergency-contacts', authenticateToken, async (req, res) => {
  try {
    const emergencyContacts = [
      {
        id: '1',
        name: 'Urgence Vétérinaire 24/7',
        phone: '01 23 45 67 89',
        address: '123 Rue de la Santé, 75001 Paris',
        services: ['Urgences 24/7', 'Chirurgie', 'Hospitalisation'],
        coordinates: { lat: 48.8566, lng: 2.3522 },
        isAvailable: true
      },
      {
        id: '2',
        name: 'Clinique Vétérinaire Central',
        phone: '01 98 76 54 32',
        address: '456 Avenue des Animaux, 75002 Paris',
        services: ['Consultations', 'Vaccinations', 'Toilettage'],
        coordinates: { lat: 48.8600, lng: 2.3500 },
        isAvailable: true
      },
      {
        id: '3',
        name: 'Hôpital Vétérinaire Universitaire',
        phone: '01 11 22 33 44',
        address: '789 Boulevard des Spécialistes, 75005 Paris',
        services: ['Médecine spécialisée', 'Imagerie', 'Oncologie'],
        coordinates: { lat: 48.8400, lng: 2.3400 },
        isAvailable: true
      }
    ];

    res.json({ emergencyContacts });
  } catch (error) {
    console.error('Get emergency contacts error:', error);
    res.status(500).json({ error: 'Failed to fetch emergency contacts' });
  }
});

module.exports = router;
