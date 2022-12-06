#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RAND=$(( ( $RANDOM % 1000 ) + 1 ))
GAMES_PLAYED=-1
BEST_GAME=-1

echo Enter your username:
read USERNAME

DOES_USER_EXIST=$($PSQL "SELECT user_id FROM user_information WHERE username = '$USERNAME'")
if [[ ! -z $DOES_USER_EXIST ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_information WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM user_information WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

echo Guess the secret number between 1 and 1000:
read USER_GUESS

GUESSES=1
while [[ $RAND != $USER_GUESS ]]
do
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    if [[ $RAND -lt $USER_GUESS ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  read USER_GUESS
  GUESSES=$((GUESSES+1))
done

echo "You guessed it in $GUESSES tries. The secret number was $RAND. Nice job!"

# Update if user exists
if [[ ! -z $DOES_USER_EXIST ]]
then
  GAMES_PLAYED=$((GAMES_PLAYED+1))
  if [[ $GUESSES -lt $BEST_GAME ]]
  then
    BEST_GAME=$GUESSES
  fi
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_information SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")
  UPDATE_BEST_GAME=$($PSQL "UPDATE user_information SET best_game = $BEST_GAME WHERE username = '$USERNAME'")
# If user doesn't exist, create new row
else
  ADD_USER=$($PSQL "INSERT INTO user_information(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESSES)")
fi
