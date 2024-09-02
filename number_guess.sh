#!/bin/bash

# Prompt for username
echo "Enter your username:"
read username

# Connect to the PostgreSQL database and get user details
USER_DETAILS=$(psql -U freecodecamp -d number_guess -t -A -c "SELECT user_id, COALESCE(games_played, 0), COALESCE(best_game, 9999) FROM users WHERE username='$username';")

# Check if the user exists
if [ -n "$USER_DETAILS" ]; then
    IFS="|" read -r user_id games_played best_game <<< "$USER_DETAILS"
    # User exists
    echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
    # User does not exist, insert new user
    echo "Welcome, $username! It looks like this is your first time here."
    psql -U freecodecamp -d number_guess -c "INSERT INTO users (username, games_played) VALUES ('$username', 0);" > /dev/null 2>&1

    # Initialize games_played and best_game
    games_played=0
    best_game="N/A"
fi

# Game logic
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

echo "Guess the secret number between 1 and 1000:"

# Loop until the user guesses the correct number
while true; do
  read GUESS

  # Check if the input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    # Increment the guess count and print the success message
    GUESSES=$(( GUESSES + 1 ))
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi

  # Increment the guess count
  GUESSES=$(( GUESSES + 1 ))
done

# After game ends, update user data
USER_ID=$(psql -U freecodecamp -d number_guess -t -A -c "SELECT user_id FROM users WHERE username='$username';")
GAMES_PLAYED=$(psql -U freecodecamp -d number_guess -t -A -c "SELECT games_played FROM users WHERE user_id=$USER_ID;")
BEST_GAME=$(psql -U freecodecamp -d number_guess -t -A -c "SELECT COALESCE(best_game, 9999) FROM users WHERE user_id=$USER_ID;")

# Increment games played
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

# Check if new best game
if [ "$BEST_GAME" -eq 9999 ] || [ "$GUESSES" -lt "$BEST_GAME" ]; then
  BEST_GAME=$GUESSES
fi

# Update user record
psql -U freecodecamp -d number_guess -c "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID;" > /dev/null 2>&1
