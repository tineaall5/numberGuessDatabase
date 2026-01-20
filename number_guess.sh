#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read user_name

user_data=$($PSQL "SELECT user_id,games_played,best_game FROM users WHERE username='$user_name'")

if [[ -z $user_data ]]
then
  echo "Welcome, $user_name! It looks like this is your first time here."
  add_user=$($PSQL "INSERT INTO users(username) VALUES('$user_name')")
else
  IFS="|" read uid total_games best_score <<< "$user_data"
  echo "Welcome back, $user_name! You have played $total_games games, and your best game took $best_score guesses."
fi

secret_value=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
guess_total=0

while true
do
  read user_guess

  if [[ ! $user_guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((guess_total++))

  if [[ $user_guess -gt $secret_value ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $user_guess -lt $secret_value ]]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $guess_total tries. The secret number was $secret_value. Nice job!"

if [[ -z $user_data ]]
then
  save_stats=$($PSQL "UPDATE users SET games_played=1, best_game=$guess_total WHERE username='$user_name'")
else
  if [[ -z $best_score || $guess_total -lt $best_score ]]
  then
    best_score=$guess_total
  fi
  ((total_games++))
  save_stats=$($PSQL "UPDATE users SET games_played=$total_games, best_game=$best_score WHERE username='$user_name'")
fi

#Testing Done, All Good