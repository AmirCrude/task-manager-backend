const express = require("express");

// Import route modules

const authRouter = require("./auth.route");
const registerRouter = require("./register.route");
const router = express.Router();

// API routes

router.use("/auth", authRouter);
router.use(registerRouter);

module.exports = router;
