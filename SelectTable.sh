#!/usr/bin/bash

seperator() {
    awk -F ':' 'BEGIN { OFS=" | "; }
    {
        for (i = 1; i <= NF; i++) {
            $i = sprintf("%-11s", $i);
        }
        $0 = " | " $0 " | ";
        if (NR == 1) {
            gsub(/./, "-", $0);
            print $0;
        }
    }' $selected_table
}

while true; do
    read -p "Enter the index of the table you want to select from (type 'r' to return): " table_index

    if [ $table_index = "r" ]; then
        continue 2
    fi
    
    if [ "$table_index" -ge 0 ] && [ "$table_index" -lt "${#tables[@]}" ]; then
        selected_table="${tables[$table_index]}"
        echo -e "\e[1;32mYou selected table '$selected_table'.\e[0m"

        while true; do
            echo -e "\e[1;33mSelect Menu:\e[0m"
            echo "1. Select all"
            echo "2. Select rows"
            echo "3. Select columns"
            echo "4. Return"
            echo "5. Exit"
            read -p "Enter your choice: " choice
            case $choice in
                1) 
                    seperator
                    awk -F ':' 'BEGIN { OFS=" | "; }
                    {
                        for (i = 1; i <= NF; i++) {
                            $i = sprintf("%-11s", $i);
                        }
                        $0 = " | " $0 " | ";
                        if (NR == 1 || NR > 2) {
                            print $0;
                        }
                        if (NR == 1) {
                            gsub(/./, "-", $0);
                            print $0;
                        }
                    }' "$selected_table"
                    seperator
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

                            seperator
                            awk -F: -v col_index="$sel_col_index" -v filter_value="${selected_column[$sel_val_index]}" '
                            BEGIN { OFS=" | "; }
                            (NR == 1 || $((col_index+1)) == filter_value) {
                                for (i = 1; i <= NF; i++) {
                                    $i = sprintf("%-11s", $i);
                                }
                                $0 = " | " $0 " | ";
                                print $0;
                                if (NR == 1) {
                                    gsub(/./, "-", $0);
                                    print $0;
                                }
                            }' "$selected_table"
                            seperator

                        else
                            echo -e "\e[1;31mValue '$sel_val_index' not found in column '${col_names[$sel_col_index]}'.\e[0m"
                        fi

                    else
                        echo -e "\e[1;31mColumn '${col_names[$sel_col_index]}' not found in '$selected_table'.\e[0m"
                    fi
                    ;;
                3)
                    IFS=":" read -ra col_names <<< $(awk 'NR==1' "$selected_table")
                    echo -e "\e[1;33m-:Available columns:-\e[0m"
                    for ((i = 0; i < ${#col_names[@]}; i++)); do
                        echo "$i. ${col_names[$i]}"
                    done
                    echo -e "\e[1;33m---------------------\e[0m"

                    read -p "Enter the column indices you want to select (e.g., 0 2 3): " col_indices

                    read -ra selected_indices <<< "$col_indices"

                    valid_selection=true

                    for index in "${selected_indices[@]}"; do
                        if [[ "$index" -lt 0 || "$index" -ge "${#col_names[@]}" ]]; then
                            echo -e "\e[1;31mInvalid column index $index. Please enter valid indices.\e[0m"
                            valid_selection=false
                            break
                        fi
                    done

                    if [ "$valid_selection" = true ]; then

                        awk -F: -v col_indices="$col_indices" '
                        BEGIN {
                            split(col_indices, indices, " ");
                            OFS=" | ";
                        }
                        {
                            line = "";
                            for (i in indices) {
                                col_index = indices[i] + 1; 
                                line = line sprintf("%-11s" OFS, $col_index);
                            }
                            line = OFS line ;
                            if (NR == 2) {
                                gsub(/./, "-", line);
                                print line;
                            }
                        }' "$selected_table"

                        awk -F: -v col_indices="$col_indices" '
                        BEGIN {
                            split(col_indices, indices, " ");
                            OFS=" | ";
                        }
                        {
                            line = "";
                            for (i = 1; i <= length(indices); i++) {
                                col_index = indices[i] + 1;
                                line = line sprintf("%-11s" OFS, $col_index );
                            }
                            columns[NR] = OFS line ;
                            if (NR == 2) {
                                gsub(/./, "-", columns[NR]);
                            }
                        }
                        END {
                            for (i = 1; i <= NR; i++) {
                                print columns[i];
                            }
                        }' "$selected_table"

                        awk -F: -v col_indices="$col_indices" '
                        BEGIN {
                            split(col_indices, indices, " ");
                            OFS=" | ";
                        }
                        {
                            line = "";
                            for (i in indices) {
                                col_index = indices[i] + 1;
                                line = line sprintf("%-11s" OFS, $col_index);
                            }
                            line = OFS line ;
                            if (NR == 2) {
                                gsub(/./, "-", line);
                                print line;
                            }
                        }' "$selected_table"
                    fi
                    ;;

                4) 
                    continue 3 ;;
                5) 
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

