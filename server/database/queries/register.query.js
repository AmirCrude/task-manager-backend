const { query } = require("../../utils/connection/connections");

// Single query module for registration
// Supports inserting a user or lawyer documents
const register = async (data) => {
  // Case 1: Insert a user
  if (data.email) {
    const sql = `
      INSERT INTO users
      (email, password_hash, first_name, last_name, phone_number, role, is_verified, profile_photo_url, cloudinary_public_id, national_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.email,
      data.password_hash || null,
      data.first_name,
      data.last_name,
      data.phone_number || null,
      data.role,
      data.is_verified || false,
      data.profile_photo_url || null,
      data.cloudinary_public_id || null,
      data.national_id || null,
    ];

    const result = await query(sql, params);
    // return the newly inserted user
    const [user] = await query("SELECT * FROM users WHERE user_id = ?", [
      result.insertId,
    ]);
    return user;
  }

  // Case 2: Insert lawyer documents / professional info
  if (data.lawyer_id) {
    const sql = `
      INSERT INTO lawyer_documents
      (lawyer_id, document_url, cloudinary_public_id, document_type, specialization, years_of_experience)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      data.lawyer_id,
      data.document_url || null,
      data.cloudinary_public_id || null,
      data.document_type || null,
      data.specialization || null,
      data.years_of_experience || 0,
    ];

    const result = await query(sql, params);
    // return the inserted document/profile
    const [doc] = await query(
      "SELECT * FROM lawyer_documents WHERE document_id = ?",
      [result.insertId]
    );
    return doc;
  }

  throw new Error("Invalid data for register query");
};

const addLawyerDocument = async ({
  lawyer_id,
  document_type,
  document_url,
  cloudinary_public_id,
  specialization,
  years_of_experience,
}) => {
  const sql = `
    INSERT INTO lawyer_documents (
      lawyer_id,
      document_type,
      document_url,
      cloudinary_public_id,
      specialization,
      years_of_experience
    )
    VALUES (?, ?, ?, ?, ?, ?)
  `;

  const values = [
    lawyer_id,
    document_type, // REQUIRED (ENUM)
    document_url, // REQUIRED
    cloudinary_public_id || null, // optional
    specialization, // REQUIRED
    years_of_experience ?? 0, // default to 0
  ];

  const result = await query(sql, values);
  return result.insertId;
};

module.exports = { register, addLawyerDocument };
