#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  
  echo -e "Welcome to My Salon, how can I help you?\n" 
  
  GET_SERVICES
  
  while true
  do
    read SERVICE_ID_SELECTED

    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] && SERVICE_EXIST $SERVICE_ID_SELECTED
    then
      break
    else
      echo -e "\nI could not find that service. What would you like today?"
      GET_SERVICES
    fi
  done

  # ask for customer phone
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //')
  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # ask custmer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

   # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATED=$(echo $SERVICE_NAME | sed 's/ //')

  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # ask for service time
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATED, $CUSTOMER_NAME"
  read SERVICE_TIME
      
  #insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # output message
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME."

}

SERVICE_EXIST() {
  SERVICES=$($PSQL "SELECT count(*) FROM services WHERE service_id=$1")
  [[ $SERVICES -gt 0 ]]  
}


GET_SERVICES() {
  # get services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  #if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo  -e "\nSorry, we don't have any services availables right now"
    else 
      # display available services
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
  fi
}

MAIN_MENU