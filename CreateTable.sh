#! /usr/bin/bash

is_valid_type() {
    if [[ "$1" != "str" && "$1" != "int" ]]; then
        return 1
    fi
    return 0
}

while true; do
    read -p "Enter the name of the table: " table_name
    if is_valid_name "$table_name"; then
        if [ -f "$table_name" ]; then
            echo "Table '$table_name' already exists."
        else
            touch "$table_name"
            break
        fi
    else
        echo "Invalid table name. Please use only alphanumeric characters, starting with a letter or underscore."
    fi
done

read -p "Enter the number of columns (including 'id'): " col_num

declare -a col_names
declare -a col_types

col_names+=("id (Primary key)")
col_types+=("int")

for ((i = 2; i <= col_num; i++)); do
    while true; do
        read -p "Enter name for column $i: " col_name
        if is_valid_name "$col_name"; then
            break
        else
            echo "Invalid column name. Please use only alphanumeric characters, starting with a letter or underscore."
        fi
    done

    while true; do
        read -p "Enter data type for $col_name (str or int): " col_type
        if is_valid_type "$col_type"; then
            col_names+=("$col_name")
            col_types+=("$col_type")
            break
        else
            echo "Invalid data type. Please enter 'str' or 'int'."
        fi
    done
done

echo "${col_names[@]}" | tr ' ' ':' >> "$table_name"
echo "${col_types[@]}" | tr ' ' ':' >> "$table_name"

echo "Table definition has been saved to '$table_name '."
