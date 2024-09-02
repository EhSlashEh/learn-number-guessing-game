#!/bin/bash

# Define the PSQL variable for database interaction
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if the user exists in the database
USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")

# If the user doesn't exist
if [[ -z $USER_DATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert the new user into the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0);")
else
  # If the user exists, retrieve their data
  echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Generate the random secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESSES=0

# Prompt the user to guess the number
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

# Retrieve the user ID
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
# Retrieve the number of games played
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
# Retrieve the best game score
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")

# Increment the number of games played
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

# Update the best game score if the current game is better
if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$GUESSES
fi

# Update the user's data in the database
UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID;")
