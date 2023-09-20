#!/usr/bin/bash

valid_type() {
    if [[ "$1" != "str" && "$1" != "int" ]]; then
        return 1
    fi
    return 0
}

while true; do
    read -p "Enter the name of the table (type 'r' to return): " table_name

    if [ $table_name = "r" ]; then
        continue 2
    fi

    if valid_name "$table_name"; then
        if [ -f "$table_name" ]; then
            echo -e "\e[1;31mTable '$table_name' already exists.\e[0m"
        else
            echo -e "\e[1;33mNote: The first column in this table is the primary key 'id' with an integer data type.\e[0m"

            while true; do
                read -p "Enter the number of columns: " col_num
                if [[ ! "$col_num" =~ ^[1-9][0-9]*$ ]]; then
                    echo -e "\e[1;31mPlease enter a number.\e[0m"
                    continue
                fi
                break
            done

            col_names=()
            col_types=()

            col_names+=("id")
            col_types+=("int")

            for ((i = 2; i <= col_num; i++)); do
                while true; do
                    read -p "Enter name for column $i: " col_name

                    for existing_col_name in "${col_names[@]}"; do
                        if [ "$existing_col_name" = "$col_name" ]; then
                            echo -e "\e[1;31mDuplicate column name.\e[0m"
                            continue 2
                        fi
                    done

                    if valid_name "$col_name"; then
                        break
                    else
                        echo -e "\e[1;31mInvalid column name. Please use only alphanumeric characters, starting with a letter or underscore.\e[0m"
                    fi
                done

                while true; do
                    read -p "Enter data type for $col_name (str or int): " col_type
                    if valid_type "$col_type"; then
                        col_names+=("$col_name")
                        col_types+=("$col_type")
                        break
                    else
                        echo -e "\e[1;31mInvalid data type. Please enter 'str' or 'int'.\e[0m"
                    fi
                done
            done
            touch "$table_name"

            echo "${col_names[@]}" | tr ' ' ':' >> "$table_name"
            echo "${col_types[@]}" | tr ' ' ':' >> "$table_name"

            echo -e "\e[1;32mTable definition has been saved to '$table_name'.\e[0m"
            break
        fi
    else
        echo -e "\e[1;31mInvalid table name. Please use only alphanumeric characters, starting with a letter or underscore.\e[0m"
    fi
done
