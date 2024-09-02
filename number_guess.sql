-- PostgreSQL database setup for the number guessing game

-- Drop the database if it exists
DROP DATABASE IF EXISTS number_guess;

-- Create the database
CREATE DATABASE number_guess WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';

-- Connect to the database
\connect number_guess

-- Create the users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(22) UNIQUE NOT NULL,
    games_played INT NOT NULL DEFAULT 0,
    best_game INT
);

-- Insert initial user data (optional)
-- INSERT INTO users (username, games_played, best_game) VALUES ('example_user', 5, 3);
