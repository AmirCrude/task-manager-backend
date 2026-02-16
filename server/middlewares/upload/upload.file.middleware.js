const multer = require("multer");

// Memory storage for uploaded files
const storage = multer.memoryStorage();

// Allowed file MIME types
const allowedMimeTypes = [
  "image/jpeg",
  "image/png",
  "image/gif",
  "image/webp",
  "application/pdf",
  "application/msword",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
  "text/plain",
  "application/json",
  "text/csv",
  "application/vnd.ms-excel",
];

// Multer configuration for a SINGLE file upload
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    // If no file, pass
    if (!file) return cb(null, true);

    // Validate MIME type if file exists
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("This file type is not allowed"), false);
    }
  },
}).single("file");

// Middleware
function uploadFileMiddleware(req, res, next) {
  upload(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      let message = err.message;
      if (err.code === "LIMIT_FILE_SIZE") {
        message = "File size exceeds 5MB";
      }
      return res.status(400).json({ status: "error", message });
    } else if (err) {
      return res.status(400).json({ status: "error", message: err.message });
    }

    // Pass even if no file is provided
    next();
  });
}

module.exports = {
  uploadFileMiddleware,
};
