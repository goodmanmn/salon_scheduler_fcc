#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\nWelcome to The Salon!\n\nWhat service would you like to schedule?\n(Use the number to select)\n"

SALON_MENU() {
  if [[ $1 ]]
  then
    echo -e "$1\n"
  fi
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do 
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then
    SALON_MENU "\nPlease enter a number"
  else
    APPOINTMENT_MENU "$SERVICE_ID_SELECTED"
  fi

}

APPOINTMENT_MENU() {
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$1")
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    SALON_MENU "\nThat is not a service we offer"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat phone number would you like to book under? (***-***-****)"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]] 
    then
      echo -e "Thank you for choosing us!\nWhat name are you booking under?"
      read CUSTOMER_NAME
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      echo -e "What time would you like your appointment?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      ADJUSTED_SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g')
      ADJUSTED_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')
      echo -e "I have put you down for a $ADJUSTED_SERVICE_NAME at $SERVICE_TIME, $ADJUSTED_CUSTOMER_NAME."
      exit
    else
      echo -e "Thank you for booking again $CUSTOMER_NAME! What time would you like your appointment?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      ADJUSTED_SERVICE_NAME=$(echo "$SERVICE_NAME" | sed 's/^ *//')
      ADJUSTED_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^ *//')
      echo -e "\nI have put you down for a $ADJUSTED_SERVICE_NAME at $SERVICE_TIME, $ADJUSTED_CUSTOMER_NAME."
      exit
    fi
  fi
}

#I have put you down for a cut at 10:30, Fabio.
#I have put you down for a cut at 10:30, Fabio.

EXIT_MENU() {
  exit
}
SALON_MENU 
