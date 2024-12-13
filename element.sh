#!/bin/bash

# Define the psql command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if the user provided an argument
if [ -z "$1" ]; then
  # If no argument is provided, ask the user to provide one
  echo "Please provide an element as an argument."
else
  # Store the input argument
  arg="$1"

  # Check if the input is numeric (atomic number)
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    # If the input is a number, use it as atomic number
    result=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
                    FROM elements e
                    JOIN properties p ON e.atomic_number = p.atomic_number
                    JOIN types t ON p.type_id = t.type_id
                    WHERE e.atomic_number = $arg;")
  else
    # If the input is a symbol or name, use it as symbol or name
    result=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
                    FROM elements e
                    JOIN properties p ON e.atomic_number = p.atomic_number
                    JOIN types t ON p.type_id = t.type_id
                    WHERE e.symbol = '$arg' OR e.name = '$arg';")
  fi

  # Check if the query returned any result
  if [ -z "$result" ]; then
    # If no result, output an error message
    echo "I could not find that element in the database."
  else
    # If a result was found, format and display the output
    echo "$result" | while IFS="|" read atomic_number name symbol type atomic_mass melting_point_celsius boiling_point_celsius
    do
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu."
      echo "$name has a melting point of $melting_point_celsius Celsius and a boiling point of $boiling_point_celsius Celsius."
    done
  fi
fi
