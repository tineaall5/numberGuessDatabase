#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT user_id,games_played,best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
else
  IFS="|" read USER_ID GAMES BEST <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi

SECRET=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if [[ $GUESS -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET ]]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET. Nice job!"

if [[ -z $USER_INFO ]]
then
  UPDATE=$($PSQL "UPDATE users SET games_played=1, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
else
  if [[ -z $BEST || $NUMBER_OF_GUESSES -lt $BEST ]]
  then
    BEST=$NUMBER_OF_GUESSES
  fi
  ((GAMES++))
  UPDATE=$($PSQL "UPDATE users SET games_played=$GAMES, best_game=$BEST WHERE username='$USERNAME'")
fi

#Testing Done, All Good