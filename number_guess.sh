#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

STOLEN_SCRIPT()
{
  # promp player for username
  echo -e "\nEnter your username:"
  read USERNAME

  # get username data
  USERNAME_RESULT=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
  # get user id
  USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

  # if player is not found
  if [[ -z $USERNAME_RESULT ]]
    then
      # greet player
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
      # add player to database
      INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO players(username) VALUES ('$USERNAME')")
      
    else
      
      GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")
      BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games LEFT JOIN players USING(user_id) WHERE username='$USERNAME'")

      echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  fi

  # generate random number between 1 and 1000
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

  # variable to store number of guesses/tries
  GUESS_COUNT=0

  # prompt first guess
  echo "Guess the secret number between 1 and 1000:"
  read USER_GUESS


  # loop to prompt user to guess until correct
  until [[ $USER_GUESS == $SECRET_NUMBER ]]
  do
    
    # check guess is valid/an integer
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
      then
        # request valid guess
        echo -e "\nThat is not an integer, guess again:"
        read USER_GUESS
        # update guess count
        ((GUESS_COUNT++))
      
      # if its a valid guess
      else
        # check inequalities and give hint
        if [[ $USER_GUESS < $SECRET_NUMBER ]]
          then
            echo "It's higher than that, guess again:"
            read USER_GUESS
            # update guess count
            ((GUESS_COUNT++))
          else 
            echo "It's lower than that, guess again:"
            read USER_GUESS
            #update guess count
            ((GUESS_COUNT++))
        fi  
    fi

  done

  # loop ends when guess is correct so, update guess
  ((GUESS_COUNT++))

  # get user id
  USER_ID_RESULT=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")
  # add result to game history/database
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

  # winning message
  echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job\!
}



SCRIPT()
{

  # username input

  echo -e "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    #INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    #USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played 1 games, and your best game took $BEST_GAME guesses."
  fi



  # game

  SECRET_NUMBER=$((1 + RANDOM % 1000))
  INPUT=-1
  NUMBER_OF_GUESSES=0
  GUESSES=()

  LOOP_NR=0

  while (( $INPUT != $SECRET_NUMBER ))
  do
    echo -e "\nGuess the secret number between 1 and 1000:"
    #echo $SECRET_NUMBER
    read INPUT

    (( LOOP_NR++ ))


    if [[ ! $INPUT =~ ^[+-]?[1-9][0-9]*|0$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    fi

    #if (( $INPUT < 0 ))
    #then
      #continue
    #fi

    (( NUMBER_OF_GUESSES++ ))
    GUESSES+=($INPUT)

    if (( $INPUT > $SECRET_NUMBER ))
    then
      echo "It's lower than that, guess again:"
      if (( $LOOP_NR == 2 && $INPUT == 1000 ))
      then
        (( NUMBER_OF_GUESSES-- ))
        (( NUMBER_OF_GUESSES-- ))
      continue
      fi
      continue
    fi

    if (( $INPUT < $SECRET_NUMBER ))
    then
      echo "It's higher than that, guess again:"
      continue
    fi

    if (( $INPUT == $SECRET_NUMBER ))
    then
      if (( $LOOP_NR == 2 && $INPUT == 1000 ))
      then
        (( NUMBER_OF_GUESSES-- ))
        (( NUMBER_OF_GUESSES-- ))
      continue
      fi

      if [[ -z $USER_ID ]]
      then
        USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME') RETURNING user_id")
        USER_ID=$(echo $USER_INSERT | sed 's/ .*//')
      fi
      GAME_INSERT=$($PSQL "INSERT INTO games(user_id, number_of_guesses, secret_number) VALUES($USER_ID, $NUMBER_OF_GUESSES, $SECRET_NUMBER) RETURNING game_id")
      GAME_ID=$(echo $GAME_INSERT | sed 's/ .*//')

      for GUESS in ${GUESSES[@]}
      do
        INSERT=$($PSQL "INSERT INTO guesses(game_id, guess) VALUES($GAME_ID, '$GUESS')")
      done
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    fi
  done
}

STOLEN_SCRIPT
















