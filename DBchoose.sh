#!/bin/bash

dir=~/Downloads/DB_test
if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
fi
cd "$dir"

is_valid() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]{2,}$ ]]; then
        return 1
    fi
    return 0
}

list_databases() {
    echo -e "\e[1;34m-----------Available databases:----------------\e[0m"
    ls -F | grep / | cut -d "/" -f1 | nl -s": "
	echo -e "\e[1;34m-----------------------------------------------\e[0m"

}

create_database() {
    read -p "Enter the name of the new database: " name
    if is_valid "$name"; then
        if [ -e "$name" ]; then
            echo -e "Database \e[1;31m$name\e[0m already exists."
        else
            mkdir "$name"
            echo -e "Database \e[1;32m$name\e[0m created successfully."
        fi
    else
        echo "Invalid database name. Database names must start with a letter or underscore and contain at least three alphanumeric characters."
    fi
}

connect_to_database() {
    list_databases
    read -p "Enter the name of the database to connect to: " name
    if [ -d "$name" ]; then
        echo -e "Connected to database \e[1;32m$name\e[0m."
		source TBchoose.sh $name
        cd $1
    else
        echo -e "Database \e[1;31m$name\e[0m does not exist."
    fi
}

drop_database() {
    echo "Available databases:"
    list_databases
    read -p "Enter the name of the database to drop: " name
    if [ -d "$name" ]; then
        rm -r "$name"
        echo -e "Database \e[1;32m$name\e[0m has been dropped."
    else
        echo -e "Database \e[1;31m$name\e[0m does not exist."
    fi
}

# Main menu
while true; do
    echo -e "\e[1;33mDatabase Management Menu:\e[0m"
    echo "1. Create Database"
    echo "2. Connect to Database"
    echo "3. List Databases"
    echo "4. Drop Database"
    echo "5. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1) create_database ;;
        2) connect_to_database ;;
        3) list_databases ;;
        4) drop_database ;;
        5) echo "Goodbye"; exit ;;
        *) echo "Invalid choice. Please enter a valid option." ;;
    esac
done
