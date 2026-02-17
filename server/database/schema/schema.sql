-- ==============================
-- Create Database
-- ==============================
CREATE DATABASE task_manager_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- ==============================
-- Create MySQL User and Grant Privileges
-- ==============================
CREATE USER 'amir_task_manager'@'localhost'
IDENTIFIED BY 'Amir&TaskManager_2026';

GRANT ALL PRIVILEGES ON task_manager_db.* 
TO 'amir_task_manager'@'localhost';

FLUSH PRIVILEGES;

USE task_manager_db;

-- Stores all registered users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,

    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_name (name)

) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci;

-- User-defined task categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_user_id (user_id),
    INDEX idx_category_name (name),

    CONSTRAINT fk_category_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci;

-- Core task table
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    category_id INT NULL,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    due_date DATETIME NULL,

    priority ENUM('high','medium','low') DEFAULT 'medium',

    status ENUM('todo','in_progress','done') DEFAULT 'todo',

    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern VARCHAR(255) NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes
    INDEX idx_user_id (user_id),
    INDEX idx_category_id (category_id),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status),
    INDEX idx_priority (priority),

    -- Foreign Keys
    CONSTRAINT fk_task_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_task_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE

) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci;

-- Break large tasks into smaller steps
CREATE TABLE subtasks (
    subtask_id INT AUTO_INCREMENT PRIMARY KEY,

    task_id INT NOT NULL,

    title VARCHAR(255) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_task_id (task_id),

    CONSTRAINT fk_subtask_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(task_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci;

-- Stores reminders for tasks
CREATE TABLE reminders (
    reminder_id INT AUTO_INCREMENT PRIMARY KEY,

    task_id INT NOT NULL,

    remind_at DATETIME NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_task_id (task_id),
    INDEX idx_remind_at (remind_at),

    CONSTRAINT fk_reminder_task
        FOREIGN KEY (task_id)
        REFERENCES tasks(task_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE

) ENGINE=InnoDB 
DEFAULT CHARSET=utf8mb4 
COLLATE=utf8mb4_unicode_ci;
