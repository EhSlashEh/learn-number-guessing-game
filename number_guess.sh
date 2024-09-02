echo "Enter your username:"
read USERNAME
USERNAME=${USERNAME:0:22}  # Truncate to 22 characters

USER_DATA=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_DATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0);")
else
  echo "$USER_DATA" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

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

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID;")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID;")

GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $BEST_GAME || $GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$GUESSES
fi

UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID;")
