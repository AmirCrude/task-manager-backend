const { hashedPassword } = require("../utils/password/password.manager");
const registerQuery = require("../database/queries/register.query");
const { sendRegistrationEmail } = require("../utils/template/email.template");
const { getUserByEmail } = require("../database/queries/auth.query");

const registerUser = async (userData) => {
  const {
    email,
    password,
    name
  } = userData;

  // Check if email is already registered
  const existingUser = await getUserByEmail(email);
  if (existingUser) {
    throw new Error("User already exists");
  }

  // Hash the password
  const password_hash = await hashedPassword(password);

  // Create the user in the database
  const newUser = await registerQuery.register({
    email,
    password_hash,
    name,
  });
  // Send registration email
  await sendRegistrationEmail(email, name);

  return newUser;
};

module.exports = { registerUser };
