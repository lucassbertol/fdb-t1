CREATE DATABASE trabalho_final_fdb_normalizado;
USE trabalho_final_fdb_normalizado;

CREATE TABLE games (
    app_id BIGINT PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    release_date DATE NULL,
    estimated_owners_min INT NULL,
    estimated_owners_max INT NULL,
    peak_ccu INT DEFAULT 0,
    required_age INT DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0,
    discount INT DEFAULT 0,
    dlc_count INT DEFAULT 0,

    about_the_game TEXT,
    reviews TEXT,
    header_image TEXT,
    website TEXT,
    support_url TEXT,
    support_email VARCHAR(255),

    windows BOOLEAN DEFAULT FALSE,
    mac BOOLEAN DEFAULT FALSE,
    linux BOOLEAN DEFAULT FALSE,

    metacritic_score INT DEFAULT 0,
    metacritic_url TEXT,
    user_score INT DEFAULT 0,
    positive INT DEFAULT 0,
    negative INT DEFAULT 0,
    score_rank VARCHAR(100),
    achievements INT DEFAULT 0,
    recommendations INT DEFAULT 0,
    notes TEXT,

    average_playtime_forever INT DEFAULT 0,
    average_playtime_two_weeks INT DEFAULT 0,
    median_playtime_forever INT DEFAULT 0,
    median_playtime_two_weeks INT DEFAULT 0
);

CREATE TABLE developers (
    developer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE game_developers (
    app_id BIGINT NOT NULL,
    developer_id INT NOT NULL,

    PRIMARY KEY (app_id, developer_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (developer_id) REFERENCES developers(developer_id)
);

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE game_publishers (
    app_id BIGINT NOT NULL,
    publisher_id INT NOT NULL,

    PRIMARY KEY (app_id, publisher_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE game_genres (
    app_id BIGINT NOT NULL,
    genre_id INT NOT NULL,

    PRIMARY KEY (app_id, genre_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE game_categories (
    app_id BIGINT NOT NULL,
    category_id INT NOT NULL,

    PRIMARY KEY (app_id, category_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE game_tags (
    app_id BIGINT NOT NULL,
    tag_id INT NOT NULL,

    PRIMARY KEY (app_id, tag_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);

CREATE TABLE languages (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE game_supported_languages (
    app_id BIGINT NOT NULL,
    language_id INT NOT NULL,

    PRIMARY KEY (app_id, language_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (language_id) REFERENCES languages(language_id)
);

CREATE TABLE game_audio_languages (
    app_id BIGINT NOT NULL,
    language_id INT NOT NULL,

    PRIMARY KEY (app_id, language_id),

    FOREIGN KEY (app_id) REFERENCES games(app_id),
    FOREIGN KEY (language_id) REFERENCES languages(language_id)
);

CREATE TABLE screenshots (
    screenshot_id INT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    url TEXT NOT NULL,

    FOREIGN KEY (app_id) REFERENCES games(app_id)
);

CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    app_id BIGINT NOT NULL,
    url TEXT NOT NULL,

    FOREIGN KEY (app_id) REFERENCES games(app_id)
);
