#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

MAIN_MENU ()
{
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi
    echo -e "\n~~~~~ MY SALON ~~~~~\nWelcome to My Salon, how can I help you?\n"
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    read SERVICE_ID_SELECTED
    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        SELECTED_SERVICE_FORMATTED=$(echo $SELECTED_SERVICE | sed -r 's/^ *| *$//g')
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        fi
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
        echo -e "\nWhat Time would you like your cut, $CUSTOMER_NAME_FORMATTED?"
        read SERVICE_TIME
        echo -e "\nI have put you down for a $SELECTED_SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME_FORMATTED'")
        ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    else
        MAIN_MENU "I could not find that service. What would you like today?"
    fi
}

MAIN_MENU