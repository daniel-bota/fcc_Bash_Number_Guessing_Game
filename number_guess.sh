#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# username input

echo -e "Enter your username:"
read USERNAME

EXISTING_USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME') RETURNING user_id")
    USER_ID=$(echo $INSERT_USERNAME_RESULT | sed 's/ .*//')
else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
    echo "Welcome back, $EXISTING_USERNAME_RESULT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# game

SECRET_NUMBER=$((1 + RANDOM % 1000))
NUMBER_OF_GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"
read INPUT
(( NUMBER_OF_GUESSES++ ))

while [[ $INPUT != $SECRET_NUMBER ]]
do
  if [[ ! $INPUT =~ ^[+-]?[1-9][0-9]*|0$ ]]
  then
      echo "That is not an integer, guess again:"
      read INPUT
      (( NUMBER_OF_GUESSES++ ))
  elif (( $INPUT > $SECRET_NUMBER ))
  then
      echo "It's lower than that, guess again:"
      read INPUT
      (( NUMBER_OF_GUESSES++ ))
  else
      echo "It's higher than that, guess again:"
      read INPUT
      (( NUMBER_OF_GUESSES++ ))
  fi
done

GAME_INSERT=$($PSQL "INSERT INTO games(user_id, number_of_guesses, secret_number) VALUES($USER_ID, $NUMBER_OF_GUESSES, $SECRET_NUMBER)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"