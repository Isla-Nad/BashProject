#! /usr/bin/bash

seperator() {
    awk -F ':' 'BEGIN { OFS=" | "; }
    {
        for (i = 1; i <= NF; i++) {
            $i = sprintf("%-11s", $i);
        }
        if (NR == 1) {
            gsub(/./, "-", $0);
            print $0;
        }
    }' $table_name
}

while true; do
    read -p "Enter the name of the table to select from: " table_name
    if [ -f "$table_name" ]; then

        while true; do
            echo -e "\e[1;33mSelect Menu:\e[0m"
            echo "1. Select all"
            echo "2. Select rows"
            echo "3. Select columns"
            echo "4. Exit or return"
            read -p "Enter your choice: " choice
            case $choice in
                1) 
                    seperator
                    awk -F ':' 'BEGIN { OFS=" | "; }
                    {
                        for (i = 1; i <= NF; i++) {
                            $i = sprintf("%-11s", $i);
                        }
                        print $0;
                        if (NR == 2) {
                            gsub(/./, "-", $0);
                            print $0;
                        }
                    }' $table_name
                    seperator
                    ;;
                2) 
                    IFS=":" read -ra col_names <<< $(awk 'NR==1' "$table_name")
                    read -p "Enter the column name you want to filter by: " col_name
                    col_index=-1
                    if [[ "${col_names[@]}" =~ "$col_name" ]]; then
                        for i in "${!col_names[@]}"; do
                            if [[ "${col_names[$i]}" = "$col_name" ]]; then
                                col_index="${i}";
                                break
                            fi
                        done
                        if [ "$col_index" -ge 0 ] ; then
                            mapfile -t selected_column < <(awk -F: -v col_index="$col_index" '{print $((col_index+1))}' "$table_name")
                        fi
                        read -p "Enter the value in column '$col_name' to filter by: " filter_value
                        if [[ "${selected_column[@]}" =~ "$filter_value" ]]; then
                            seperator
                            awk -F: -v col_index="$col_index" -v filter_value="$filter_value" '
                            BEGIN { OFS=" | "; }
                            {
                                if ($((col_index+1)) == filter_value) {
                                    for (i = 1; i <= NF; i++) {
                                        $i = sprintf("%-11s", $i);
                                    }
                                    print $0;
                                }
                            }' "$table_name"
                            seperator
                        else
                            echo -e "\e[1;31mValue '$filter_value' not found in column '$col_name'.\e[0m"
                        fi
                    else
                        echo -e "Column \e[1;31m$col_name\e[0m not found in $table_name."
                    fi
                    ;;
                3)
                    IFS=":" read -ra col_names <<< $(awk 'NR==1' "$table_name")
                    echo -e "\e[1;33mAvailable columns:\e[0m"
                    for ((i = 0; i < ${#col_names[@]}; i++)); do
                        echo "$i. ${col_names[$i]}"
                    done

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
                        seperator
                        awk -F: -v col_indices="$col_indices" '
                        BEGIN {
                            split(col_indices, indices, " ");
                            OFS=" | ";
                        }
                        {
                            for (i = 1; i <= NF; i++) {
                                if (i - 1 in indices) {
                                    $i = sprintf("%-11s", $i);
                                } else {
                                    $i = "";
                                }
                            }
                            print $0;
                            if (NR == 2) {
                                gsub(/./, "-", $0);
                                print $0;
                            }
                        }' "$table_name"
                        seperator
                    fi
                    ;;

                4) 
                    echo -e "\e[1;33mGoodbye\e[0m"; exit ;;
                *) 
                    echo -e "\e[1;31mInvalid choice. Please enter a valid option.\e[0m" ;;
            esac
        done

    else
        echo -e "Table \e[1;31m$table_name\e[0m does not exist."
        continue
    fi
done

