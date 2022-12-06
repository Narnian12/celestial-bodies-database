PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

OUTPUT() {
  ATOMIC_NUMBER=$1
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = '$ATOMIC_NUMBER'")
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = '$ATOMIC_NUMBER'")
  TYPE_ID=$(echo $($PSQL "SELECT type_id FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'") | sed -r 's/^ *$//g')
  TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$TYPE_ID'")
  MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
  MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
  BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
  # trim spaces around queries when outputting
  echo "The element with atomic number $(echo $ATOMIC_NUMBER | sed -r 's/^ *$//g') is $(echo $NAME | sed -r 's/^ *$//g') ($(echo $SYMBOL | sed -r 's/^ *$//g')). It's a $(echo $TYPE | sed -r 's/^ *$//g'), with a mass of $(echo $MASS | sed -r 's/^ *$//g') amu. $(echo $NAME | sed -r 's/^ *$//g') has a melting point of $(echo $MELTING | sed -r 's/^ *$//g') celsius and a boiling point of $(echo $BOILING | sed -r 's/^ *$//g') celsius."
}

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  # if the argument is a number
  if [[ "$1" =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM properties WHERE atomic_number = '$1'")
    if [[ ! -z $ATOMIC_NUMBER ]]
    then
      OUTPUT $ATOMIC_NUMBER
    else
      echo "I could not find that element in the database."
    fi
  # otherwise try as either symbol or name
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
    if [[ ! -z $ATOMIC_NUMBER ]]
    then
        OUTPUT $ATOMIC_NUMBER
    else
      echo "I could not find that element in the database."
    fi
  fi
fi
