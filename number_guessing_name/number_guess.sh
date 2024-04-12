#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -tc"

USERNAME_INPUT()
{
  echo -e "\nEnter your username:"
  read USERNAME
  if [[ ! $USERNAME =~ ^.{1,22}$ ]]
  then
  fi
}

USERNAME_INPUT

