#!/usr/bin/bash

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
    read -p "Enter the index of the table you want to update (type 'r' to return): " table_index

    if [ $table_index = "r" ]; then
        continue 2
    fi

    if [ "$table_index" -ge 0 ] && [ "$table_index" -lt "${#tables[@]}" ]; then
        selected_table="${tables[$table_index]}"
        echo -e "\e[1;32mYou selected table '$selected_table'.\e[0m"

        while true; do
            echo -e "\e[1;33mUpdate Menu:\e[0m"
            echo "1. Update by ID"
            echo "2. Return"
            echo "3. Exit"
            read -p "Enter your choice: " choice

            case $choice in
                1)
                    mapfile -t selected_id < <(awk -F: 'NR > 2 {print $1}' "$selected_table")

                    echo -e "\e[1;33m-:Available IDs:-\e[0m"
                    for ((i = 0; i < ${#selected_id[@]}; i++)); do
                        echo "$i. ${selected_id[$i]}"
                    done
                    echo -e "\e[1;33m-----------------\e[0m"

                    read -p "Enter the id index you want to filter by: " sel_id_index

                    valid_selection=true
                    if [[ "$sel_id_index" -lt 0 || "$sel_id_index" -ge "${#selected_id[@]}" ]]; then
                        echo -e "\e[1;31mInvalid column index $sel_id_index. Please enter valid index.\e[0m"
                        valid_selection=false
                    fi

                    if [[ "$valid_selection" == true ]]; then
                        IFS=":" read -ra col_names <<< $(awk 'NR==1' "$selected_table")

                        echo -e "\e[1;33m-:Available columns:-\e[0m"
                        for ((i = 0; i < ${#col_names[@]}; i++)); do
                            echo "$i. ${col_names[$i]}"
                        done
                        echo -e "\e[1;33m---------------------\e[0m"

                        read -p "Enter the column index you want to filter by: " sel_col_index

                        valid_selection=true
                        if [[ "$sel_col_index" -lt 0 || "$sel_col_index" -ge "${#col_names[@]}" ]]; then
                            echo -e "\e[1;31mInvalid column index $sel_col_index. Please enter valid index.\e[0m"
                            valid_selection=false
                        fi
                        
                        if [[ "$valid_selection" == true ]]; then
                            IFS=":" read -ra col_types <<< $(awk 'NR==2' "$selected_table")
                            
                            read -p "Enter the new value for '${col_names[$sel_col_index]}': " new_value

                            if ! valid_value "$new_value" "${col_types[$sel_col_index]}"; then
                                continue 
                            fi

                            temp_file="$(mktemp)"
                            awk -v update_id="${selected_id[$sel_id_index]}" -v col_index="$sel_col_index" -v new_value="$new_value" -F: '
                                BEGIN { OFS=":"; }
                                {
                                    if ($1 == update_id) {
                                        $((col_index+1)) = new_value;
                                    }
                                    print $0;
                                }
                            ' "$selected_table" > "$temp_file"

                            mv "$temp_file" "$selected_table"

                            echo -e "\e[1;32mColumn '${col_names[$sel_col_index]}' for ID '${selected_id[$sel_id_index]}' updated successfully.\e[0m"
                        fi
                    fi
                    ;;
                2)
                    continue 3
                    ;;
                3)
                    echo -e "\e[1;33mGoodbye\e[0m"
                    exit
                    ;;
                *)
                    echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m"
                    ;;
            esac
        done

    else
        echo -e "\e[1;31mInvalid table index '$table_index'. Please enter a valid index.\e[0m"
        continue
    fi
done
