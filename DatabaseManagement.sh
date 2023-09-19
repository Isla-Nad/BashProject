#!/usr/bin/bash

xdg-open 'FlowChart.jpeg'

dir=~/Downloads/DATABASE
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

while true; do

    databases=($(ls -F | grep / | cut -d "/" -f1))
    list_databases() {
        if [ "${#databases[@]}" -eq 0 ]; then
            echo -e "\e[1;31mNo databases available.\e[0m"
        else
            echo -e "\e[1;34m-:Available Databases:-\e[0m"
            for ((i = 0; i < ${#databases[@]}; i++)); do
                echo "$i: ${databases[$i]}"
            done
            echo -e "\e[1;34m-----------------------\e[0m"
        fi
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
        read -p "Enter the index of the database you want to select: " db_index

        if [ "$db_index" -ge 0 ] && [ "$db_index" -lt "${#databases[@]}" ]; then
            selected_database="${databases[$db_index]}"
            echo -e "\e[1;32mYou selected database '$selected_database'.\e[0m"
            source TableManagement.sh "$selected_database"
        else
            echo -e "\e[1;31mInvalid database index. Please enter a valid index.\e[0m"
        fi
    }

    drop_database() {
        list_databases
        read -p "Enter the index of the database you want to drop: " db_index

        if [ "$db_index" -ge 0 ] && [ "$db_index" -lt "${#databases[@]}" ]; then
            selected_database="${databases[$db_index]}"
            rm -r "$selected_database"
            echo -e "\e[1;32mDatabase '$selected_database' has been dropped..\e[0m"
        else
            echo -e "\e[1;31mInvalid database index '$db_index'. Please enter a valid index.\e[0m"
        fi
    }
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
