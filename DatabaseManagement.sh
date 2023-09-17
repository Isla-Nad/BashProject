#!/bin/bash

dir=~/Downloads/DB_test
if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
fi
cd "$dir"

valid_name() {
    if [[ ! "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
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
    if valid_name "$name"; then
        if [ -e "$name" ]; then
            echo -e "\e[1;31mDatabase '$name' already exists.\e[0m"
        else
            mkdir "$name"
            echo -e "\e[1;32mDatabase '$name' created successfully.\e[0m"
        fi
    else
        echo -e "\e[1;31mInvalid database name. Please use only alphanumeric characters, starting with a letter or underscore.\e[0m"
    fi
}

connect_to_database() {
    list_databases
    read -p "Enter the name of the database to connect to: " name
    if [ -d "$name" ]; then
        echo -e "\e[1;32mConnected to database '$name'.\e[0m"
		source TableManagement.sh "$name"
    else
        echo -e "\e[1;31mDatabase '$name' does not exist.\e[0m"
    fi
}

drop_database() {
    list_databases
    read -p "Enter the name of the database to drop: " name
    if [ -d "$name" ]; then
        rm -r "$name"
        echo -e "\e[1;32mDatabase '$name' has been dropped.\e[0m"
    else
        echo -e "\e[1;31mDatabase '$name' does not exist.\e[0m"
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
        5) echo -e "\e[1;33mGoodbye\e[0m"; exit ;;
        *) echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m" ;;
    esac
done
