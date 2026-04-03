const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken, verifyPetOwnership } = require('../middleware/auth');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const upload = multer({ storage: multer.memoryStorage() });

const router = express.Router();

router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { species, page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT p.*, 
             (SELECT COUNT(*) FROM vaccinations v WHERE v.pet_id = p.id) as vaccination_count,
             (SELECT COUNT(*) FROM medical_records mr WHERE mr.pet_id = p.id) as medical_record_count
      FROM pets p 
      WHERE p.user_id = $1 AND p.is_active = true
    `;
    const params = [userId];

    if (species) {
      query += ` AND p.species = $2`;
      params.push(species);
    }

    query += ` ORDER BY p.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    const countQuery = species 
      ? 'SELECT COUNT(*) FROM pets WHERE user_id = $1 AND species = $2 AND is_active = true'
      : 'SELECT COUNT(*) FROM pets WHERE user_id = $1 AND is_active = true';
    
    const countParams = species ? [userId, species] : [userId];
    const countResult = await pool.query(countQuery, countParams);

    res.json({
      pets: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: parseInt(countResult.rows[0].count),
        pages: Math.ceil(countResult.rows[0].count / limit)
      }
    });
  } catch (error) {
    console.error('Get pets error:', error);
    res.status(500).json({ error: 'Failed to fetch pets' });
  }
});

router.get('/:petId', authenticateToken, verifyPetOwnership, async (req, res) => {
  try {
    const petId = req.params.petId;

    const petResult = await pool.query(
      'SELECT * FROM pets WHERE id = $1 AND is_active = true',
      [petId]
    );

    if (petResult.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found' });
    }

    const vaccinationsResult = await pool.query(
      'SELECT * FROM vaccinations WHERE pet_id = $1 ORDER BY administration_date DESC',
      [petId]
    );

    const medicalRecordsResult = await pool.query(
      'SELECT * FROM medical_records WHERE pet_id = $1 ORDER BY record_date DESC',
      [petId]
    );

    const pet = petResult.rows[0];
    pet.vaccinations = vaccinationsResult.rows;
    pet.medicalRecords = medicalRecordsResult.rows;

    res.json({ pet });
  } catch (error) {
    console.error('Get pet error:', error);
    res.status(500).json({ error: 'Failed to fetch pet' });
  }
});

router.post('/', authenticateToken, upload.single('photo'), async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, species, breed, birthDate, weight, specialNeeds } = req.body;

    if (!name || !species) {
      return res.status(400).json({ error: 'Name and species are required' });
    }

    let photoUrl = null;
    if (req.file) {
      try {
        const result = await cloudinary.uploader.upload_stream(
          { 
            folder: 'plutovets/pets',
            resource_type: 'image'
          },
          (error, result) => {
            if (error) throw error;
            return result;
          }
        ).end(req.file.buffer);
        
        photoUrl = result.secure_url;
      } catch (uploadError) {
        console.error('Photo upload error:', uploadError);
      }
    }

    const petResult = await pool.query(
      `INSERT INTO pets (user_id, name, species, breed, birth_date, weight, photo_url, special_needs)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [userId, name, species, breed, birthDate, weight, photoUrl, specialNeeds]
    );

    const pet = petResult.rows[0];

    res.status(201).json({
      message: 'Pet created successfully',
      pet
    });
  } catch (error) {
    console.error('Create pet error:', error);
    res.status(500).json({ error: 'Failed to create pet' });
  }
});

router.put('/:petId', authenticateToken, verifyPetOwnership, upload.single('photo'), async (req, res) => {
  try {
    const petId = req.params.petId;
    const { name, species, breed, birthDate, weight, specialNeeds } = req.body;

    let photoUrl = null;
    if (req.file) {
      try {
        const result = await cloudinary.uploader.upload_stream(
          { 
            folder: 'plutovets/pets',
            resource_type: 'image'
          },
          (error, result) => {
            if (error) throw error;
            return result;
          }
        ).end(req.file.buffer);
        
        photoUrl = result.secure_url;
      } catch (uploadError) {
        console.error('Photo upload error:', uploadError);
      }
    }

    const updateFields = [];
    const updateValues = [];
    let paramIndex = 1;

    if (name !== undefined) {
      updateFields.push(`name = $${paramIndex++}`);
      updateValues.push(name);
    }
    if (species !== undefined) {
      updateFields.push(`species = $${paramIndex++}`);
      updateValues.push(species);
    }
    if (breed !== undefined) {
      updateFields.push(`breed = $${paramIndex++}`);
      updateValues.push(breed);
    }
    if (birthDate !== undefined) {
      updateFields.push(`birth_date = $${paramIndex++}`);
      updateValues.push(birthDate);
    }
    if (weight !== undefined) {
      updateFields.push(`weight = $${paramIndex++}`);
      updateValues.push(weight);
    }
    if (specialNeeds !== undefined) {
      updateFields.push(`special_needs = $${paramIndex++}`);
      updateValues.push(specialNeeds);
    }
    if (photoUrl !== null) {
      updateFields.push(`photo_url = $${paramIndex++}`);
      updateValues.push(photoUrl);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    updateValues.push(petId);

    const query = `UPDATE pets SET ${updateFields.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    
    const result = await pool.query(query, updateValues);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found' });
    }

    res.json({
      message: 'Pet updated successfully',
      pet: result.rows[0]
    });
  } catch (error) {
    console.error('Update pet error:', error);
    res.status(500).json({ error: 'Failed to update pet' });
  }
});

router.delete('/:petId', authenticateToken, verifyPetOwnership, async (req, res) => {
  try {
    const petId = req.params.petId;

    const result = await pool.query(
      'UPDATE pets SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *',
      [petId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pet not found' });
    }

    res.json({
      message: 'Pet deleted successfully'
    });
  } catch (error) {
    console.error('Delete pet error:', error);
    res.status(500).json({ error: 'Failed to delete pet' });
  }
});

router.post('/:petId/vaccinations', authenticateToken, verifyPetOwnership, upload.single('certificate'), async (req, res) => {
  try {
    const petId = req.params.petId;
    const { vaccineName, administrationDate, nextDueDate, veterinarianName, notes } = req.body;

    if (!vaccineName || !administrationDate) {
      return res.status(400).json({ error: 'Vaccine name and administration date are required' });
    }

    let certificateUrl = null;
    if (req.file) {
      try {
        const result = await cloudinary.uploader.upload_stream(
          { 
            folder: 'plutovets/vaccinations',
            resource_type: 'auto'
          },
          (error, result) => {
            if (error) throw error;
            return result;
          }
        ).end(req.file.buffer);
        
        certificateUrl = result.secure_url;
      } catch (uploadError) {
        console.error('Certificate upload error:', uploadError);
      }
    }

    const vaccinationResult = await pool.query(
      `INSERT INTO vaccinations (pet_id, vaccine_name, administration_date, next_due_date, veterinarian_name, certificate_url, notes)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [petId, vaccineName, administrationDate, nextDueDate, veterinarianName, certificateUrl, notes]
    );

    const vaccination = vaccinationResult.rows[0];

    res.status(201).json({
      message: 'Vaccination record created successfully',
      vaccination
    });
  } catch (error) {
    console.error('Create vaccination error:', error);
    res.status(500).json({ error: 'Failed to create vaccination record' });
  }
});

router.get('/:petId/vaccinations', authenticateToken, verifyPetOwnership, async (req, res) => {
  try {
    const petId = req.params.petId;

    const result = await pool.query(
      'SELECT * FROM vaccinations WHERE pet_id = $1 ORDER BY administration_date DESC',
      [petId]
    );

    res.json({ vaccinations: result.rows });
  } catch (error) {
    console.error('Get vaccinations error:', error);
    res.status(500).json({ error: 'Failed to fetch vaccinations' });
  }
});

router.post('/:petId/medical-records', authenticateToken, verifyPetOwnership, async (req, res) => {
  try {
    const petId = req.params.petId;
    const { recordDate, weight, temperature, behavior, veterinarianNotes, diagnosis, treatment } = req.body;

    if (!recordDate) {
      return res.status(400).json({ error: 'Record date is required' });
    }

    const medicalRecordResult = await pool.query(
      `INSERT INTO medical_records (pet_id, record_date, weight, temperature, behavior, veterinarian_notes, diagnosis, treatment)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [petId, recordDate, weight, temperature, behavior, veterinarianNotes, diagnosis, treatment]
    );

    const medicalRecord = medicalRecordResult.rows[0];

    res.status(201).json({
      message: 'Medical record created successfully',
      medicalRecord
    });
  } catch (error) {
    console.error('Create medical record error:', error);
    res.status(500).json({ error: 'Failed to create medical record' });
  }
});

router.get('/:petId/medical-records', authenticateToken, verifyPetOwnership, async (req, res) => {
  try {
    const petId = req.params.petId;

    const result = await pool.query(
      'SELECT * FROM medical_records WHERE pet_id = $1 ORDER BY record_date DESC',
      [petId]
    );

    res.json({ medicalRecords: result.rows });
  } catch (error) {
    console.error('Get medical records error:', error);
    res.status(500).json({ error: 'Failed to fetch medical records' });
  }
});

module.exports = router;
