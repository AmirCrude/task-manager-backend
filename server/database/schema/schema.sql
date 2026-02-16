-- Create database
CREATE DATABASE eth_law
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Create user and grant privileges
CREATE USER 'eth_law'@'localhost'
IDENTIFIED BY 'eth_law1234';
GRANT ALL PRIVILEGES ON eth_law.* TO 'eth_law'@'localhost';
FLUSH PRIVILEGES;


USE eth_law;

-- Stores all system users with optional profile photo and national ID
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role ENUM('citizen','lawyer','government_official','super_admin') NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,

    -- Optional profile photo and Cloudinary public ID
    profile_photo_url VARCHAR(500) DEFAULT NULL,
    cloudinary_public_id VARCHAR(255) DEFAULT NULL,

    -- Optional national ID
    national_id VARCHAR(100) DEFAULT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE lawyer_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Links to users table where role = 'lawyer'
    lawyer_id INT NOT NULL, 

    -- Document info
    document_url VARCHAR(500) NOT NULL,
    cloudinary_public_id VARCHAR(255) DEFAULT NULL,
    document_type ENUM('license','education','other') NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Basic professional info
    specialization VARCHAR(150) NOT NULL,  -- e.g., "Civil Law", "Criminal Law"
    years_of_experience INT DEFAULT 0,     -- number of years practicing

    -- Foreign key
    CONSTRAINT fk_lawyer
        FOREIGN KEY (lawyer_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

  CREATE TABLE government_official_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,

    department VARCHAR(150) NOT NULL,
    position_title VARCHAR(150) NOT NULL,
    office_region VARCHAR(100) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB


-- SUPER ADMIN EXAMPLE
INSERT INTO users (user_id, email, password_hash, first_name, last_name, role, is_verified)
VALUES (1, 'admin@portal.gov.et', '$2b$10$H6rfPCLteCimDDC3ztzLV.ayQtRy1Kpd/LwZZwuv4RlU8trN9htJi', 'Super', 'Admin', 'super_admin', TRUE);

-- Constitution Contents table
CREATE TABLE constitution_contents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,

    -- Hard-coded chapter names
    chapter ENUM(
        'Fundamental Principles',
        'Human and Democratic Rights',
        'Federal Structure',
        'State and Religion',
        'The Legislature',
        'The Executive',
        'The Judiciary',
        'Finance',
        'Elections',
        'State of Emergency',
        'Miscellaneous Provisions'
    ) NOT NULL,

    -- Document type hard-coded
    type ENUM(
        'Constitution',
        'Proclamation',
        'Regulation',
        'Directive',
        'Circular',
        'Guideline',
        'Policy',
        'Decision / Order'
    ) NOT NULL,

    short_bio TEXT,

    -- File storage (Cloudinary)
    file_url VARCHAR(500) NOT NULL,
    cloudinary_public_id VARCHAR(255) NOT NULL,

    -- Track creators and editors
    created_by INT NOT NULL,
    updated_by INT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes for fast search
    INDEX idx_chapter (chapter),
    INDEX idx_created_by (created_by),
    INDEX idx_updated_by (updated_by),
    INDEX idx_title (title),
    INDEX idx_type (type),

    -- Foreign keys linking to users table
    CONSTRAINT fk_created_by
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE file_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Relationship
    file_id INT NOT NULL,
    user_id INT NOT NULL,

    -- Threading
    parent_comment_id INT NULL,

    -- Content
    comment_text TEXT NOT NULL,

    -- Moderation & lifecycle
    status ENUM('active','edited','deleted','hidden') DEFAULT 'active',
    is_pinned BOOLEAN DEFAULT FALSE,

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_file_id (file_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_comment (parent_comment_id),
    INDEX idx_status (status),

    -- Foreign keys
    CONSTRAINT fk_comment_file
        FOREIGN KEY (file_id)
        REFERENCES constitution_contents(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_comment_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_parent_comment
        FOREIGN KEY (parent_comment_id)
        REFERENCES file_comments(comment_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE citizen_verification_list (
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Citizen full name and national ID
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    national_id VARCHAR(50) NOT NULL UNIQUE,

    -- Optional additional info
    date_of_birth DATE DEFAULT NULL,
    region VARCHAR(100) DEFAULT NULL,

    -- Status
    is_active BOOLEAN DEFAULT TRUE, -- Only active citizens are considered valid

    -- Audit
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes for fast search
    INDEX idx_national_id (national_id),
    INDEX idx_name (first_name, last_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE citizen_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,

    -- Who reported
    citizen_id INT NOT NULL,  -- users.user_id where role = 'citizen'

    -- Report content
    category ENUM(
        'corruption',
        'human_rights',
        'public_service',
        'law_violation',
        'other'
    ) NOT NULL,

    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,

    -- Optional location info
    region VARCHAR(100) DEFAULT NULL,

    -- Timestamps
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_citizen_id (citizen_id),
    INDEX idx_category (category),

    -- Foreign key
    CONSTRAINT fk_report_citizen
        FOREIGN KEY (citizen_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
