#! /usr/bin/bash

while true; do
    read -p "Enter the index of the table you want to delete from (type 'r' to return): " table_index

    if [ $table_index = "r" ]; then
        continue 2
    fi
    
    if [ "$table_index" -ge 0 ] && [ "$table_index" -lt "${#tables[@]}" ]; then
        selected_table="${tables[$table_index]}"
        echo -e "\e[1;32mYou selected table '$selected_table'.\e[0m"

        while true; do
            echo -e "\e[1;33mDelete Menu:\e[0m"
            echo "1. Delete all"
            echo "2. Delete rows"
            echo "3. Return"
            echo "4. Exit"
            read -p "Enter your choice: " choice
            case $choice in
                1)
                    awk 'NR < 3' "$selected_table" > "$selected_table.temp"
                    mv "$selected_table.temp" "$selected_table" 
                    echo -e "\e[1;32mAll data deleted in '$selected_table' successfully except meta data.\e[0m"
                    ;;
                2)
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

                        mapfile -t selected_column < <(awk -F: -v col_index="$sel_col_index" 'NR > 2 {print $((col_index+1))}' "$selected_table")

                        echo -e "\e[1;33m-:Available values:-\e[0m"
                        for ((i = 0; i < ${#selected_column[@]}; i++)); do
                            echo "$i. ${selected_column[$i]}"
                        done
                        echo -e "\e[1;33m--------------------\e[0m"

                        read -p "Enter the index of the value in column '${col_names[$sel_col_index]}' to filter by: " sel_val_index

                        valid_selection=true
                        if [[ "$sel_val_index" -lt 0 || "$sel_val_index" -ge "${#selected_column[@]}" ]]; then
                            echo -e "\e[1;31mInvalid value index $sel_val_index. Please enter valid index.\e[0m"
                            valid_selection=false
                        fi
                        
                        if [[ "$valid_selection" == true ]]; then

                            temp_file="$(mktemp)"
                            awk -v col_index="$sel_col_index" -v filter_value="${selected_column[sel_val_index]}" -F: '
                                BEGIN { OFS=":"; }
                                {
                                    if ($((col_index+1)) == filter_value) {
                                        next; 
                                    }
                                    print $0;  
                                }
                            ' "$selected_table" > "$temp_file"

                            mv "$temp_file" "$selected_table"

                            echo -e "\e[1;32mRows in '$selected_table' where '${col_names[$sel_col_index]}'='${selected_column[sel_val_index]}' deleted successfully.\e[0m"
                        fi
                    fi
                    ;;

                3)
                    continue 3 ;;
                4)
                    echo -e "\e[1;33mGoodbye\e[0m"; exit ;;
                *)
                    echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m" ;;
            esac
        done

    else
        echo -e "\e[1;31mInvalid table index '$table_index'. Please enter a valid index.\e[0m"
        continue
    fi
done
