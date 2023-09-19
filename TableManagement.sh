#!/usr/bin/bash.

cd "$1"

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



while true; do
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
            source InsertTable.sh
            ;;
        4)
            list_tables
            source SelectTable.sh
            ;;
        5)
            list_tables
            source UpdateTable.sh
            ;;
        6)
            list_tables
            source DeleteTable.sh
            ;;
        7)
            list_tables
            read -p "Enter the name of the table to drop: " name
            if [ -f "$name" ]; then
                rm "$name"
                echo -e "\e[1;32mTable $name has been dropped.\e[0m"
            else
                echo -e "\e[1;31mTable $name does not exist.\e[0m"
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
