#!/bin/bash

valid_value() {
    if [ "$2" == "int" ]; then
        if ! [[ "$1" =~ ^[0-9]+$ ]]; then
            echo -e "\e[1;31mValue must be an integer.\e[0m"
            return 1
        fi
    elif [ "$2" == "str" ]; then
        if ! [[ "$1" =~ ^[A-Za-z]+$ ]]; then
            echo -e "\e[1;31mValue must be a string.\e[0m"
            return 1
        fi
    fi
    return 0
}

while true; do
    read -p "Enter the name of the table to update: " table_name
    if [ -f "$table_name" ]; then

        while true; do
            echo -e "\e[1;33mUpdate Menu:\e[0m"
            echo "1. Update Column Value by ID"
            echo "2. Exit or return"
            read -p "Enter your choice: " choice

            case $choice in
                1)
                    mapfile -t selected_id < <(awk -F: '{print $1}' "$table_name")
                    read -p "Enter the ID of the row you want to update: " update_id

                    if [[ "${selected_id[@]}" =~ "$update_id" ]]; then
                        IFS=":" read -ra col_names <<< $(awk 'NR==1' "$table_name")
                        read -p "Enter the column name you want to update: " update_column
                        if [[ "${col_names[@]}" =~ "$update_column" ]]; then
                            col_index=-1
                            for i in "${!col_names[@]}"; do
                                if [[ "${col_names[$i]}" = "$update_column" ]]; then
                                    col_index="${i}";
                                    break
                                fi
                            done
                            IFS=":" read -ra col_types <<< $(awk 'NR==2' "$table_name")
                            temp_file="$(mktemp)"
                            read -p "Enter the new value for '$update_column': " new_value
                            if ! valid_value "$new_value" "${col_types[$col_index]}"; then
                                continue 
                            fi

                            awk -v update_id="$update_id" -v col_index="$col_index" -v new_value="$new_value" -F: '
                                BEGIN { OFS=":"; }
                                {
                                    if ($1 == update_id) {
                                        $((col_index+1)) = new_value;
                                    }
                                    print $0;
                                }
                            ' "$table_name" > "$temp_file"

                            mv "$temp_file" "$table_name"

                            echo -e "\e[1;32mColumn '$update_column' for ID '$update_id' updated successfully.\e[0m"
                        else
                             echo -e "\e[1;31mColumn '$update_column' not found in '$table_name'.\e[0m"
                        fi
                    else
                        echo -e "\e[1;31mSelected ID '$update_id' not found in table '$table_name'.\e[0m"
                    fi

                    ;;
                2)
                    echo -e "\e[1;33mGoodbye\e[0m"
                    exit
                    ;;
                *)
                    echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m"
                    ;;
            esac
        done

    else
        echo -e "Table \e[1;31m$table_name\e[0m does not exist."
        continue
    fi
done
