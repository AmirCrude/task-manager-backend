const Joi = require("joi");

// ---------------------
// Registration schema with lawyer fields
const registrationSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  first_name: Joi.string().max(100).required(),
  last_name: Joi.string().max(100).required(),
  phone_number: Joi.string().max(50).optional(),
  role: Joi.string().valid("citizen", "lawyer").required(),
  national_id: Joi.string().max(100).optional(), // for citizens

  // Lawyer-specific fields
  document_type: Joi.string()
    .valid("license", "education", "other")
    .when("role", {
      is: "lawyer",
      then: Joi.required(),
      otherwise: Joi.forbidden(),
    }),

  specialization: Joi.string().max(150).when("role", {
    is: "lawyer",
    then: Joi.required(),
    otherwise: Joi.forbidden(),
  }),

  years_of_experience: Joi.number().integer().min(0).when("role", {
    is: "lawyer",
    then: Joi.optional(),
    otherwise: Joi.forbidden(),
  }),
});

// ---------------------
// Middleware to validate registration
const validateRegistration = (req, res, next) => {
  const { error } = registrationSchema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }
  next();
};

module.exports = {
  validateRegistration,
};
