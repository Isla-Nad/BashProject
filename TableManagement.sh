#!/usr/bin/bash

cd "$1"





while true; do

    tables=($(ls --file-type | grep -v /$))
    list_tables() {
        if [ "${#tables[@]}" -eq 0 ]; then
            echo -e "\e[1;31mNo tables available.\e[0m"
        else
            echo -e "\e[1;34m-:Available tables:-\e[0m"
            for ((i = 0; i < ${#tables[@]}; i++)); do
                echo "$i: ${tables[$i]}"
            done
            echo -e "\e[1;34m--------------------\e[0m"
        fi
    }

    echo -e "\e[1;33mTable Management Menu:\e[0m"
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Insert into Table"
    echo "4. Select from Table"
    echo "5. Update Table"
    echo "6. Delete from Table"
    echo "7. Drop Table"
    echo "8. Return"
    echo "9. Exit"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            source CreateTable.sh
            ;;
        2)
            list_tables
            ;;
        3)
            list_tables
            if [ "${#tables[@]}" -gt 0 ]; then
                source InsertTable.sh
            fi
            ;;
        4)
            list_tables
            if [ "${#tables[@]}" -gt 0 ]; then
                source SelectTable.sh
            fi
            ;;
        5)
            list_tables
            if [ "${#tables[@]}" -gt 0 ]; then
                source UpdateTable.sh
            fi
            ;;
        6)
            list_tables
            if [ "${#tables[@]}" -gt 0 ]; then
                source DeleteTable.sh
            fi
            ;;
        7)
            list_tables
            if [ "${#tables[@]}" -gt 0 ]; then
                read -p "Enter the index of the table you want to select from (type 'r' to return): " table_index

                if [ $table_index = "r" ]; then
                    continue 2
                fi
                
                if [ "$table_index" -ge 0 ] && [ "$table_index" -lt "${#tables[@]}" ]; then
                    selected_table="${tables[$table_index]}"

                    rm "$selected_table"

                    echo -e "\e[1;32mTable $selected_table has been dropped.\e[0m"
                else
                    echo -e "\e[1;31mInvalid table index '$table_index'. Please enter a valid index.\e[0m"
                fi
            fi
            ;;
        8)
            cd ..
            break
            ;;
        9)
            echo -e "\e[1;33mGoodbye\e[0m"
            exit
            ;;
        *) 
            echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m" ;;
    esac
done
