#! /usr/bin/bash

while true; do
    read -p "Enter the name of the table to delete from: " table_name
    if [ -f "$table_name" ]; then

        while true; do
            echo -e "\e[1;33mDelete Menu:\e[0m"
            echo "1. Delete all"
            echo "2. Delete rows"
            echo "3. Exit or return"
            read -p "Enter your choice: " choice
            case $choice in
                1)
                    awk 'NR < 3' "$table_name" > "$table_name.temp"
                    mv "$table_name.temp" "$table_name" 
                    echo -e "\e[1;32mAll data deleted in '$table_name' successfully except meta data.\e[0m"
                    ;;
                2)
                    IFS=":" read -ra col_names <<< $(awk 'NR==1' "$table_name")
                    read -p "Enter the column name you want to filter by: " col_name
                    if [[ "${col_names[@]}" =~ "$col_name" ]]; then
                        col_index=-1
                        for i in "${!col_names[@]}"; do
                            if [[ "${col_names[$i]}" = "$col_name" ]]; then
                                col_index="${i}";
                                break
                            fi
                        done
                        if [ "$col_index" -ge 0 ] ; then
                            mapfile -t selected_column < <(awk -F: -v col_index="$col_index" '{print $((col_index+1))}' "$table_name")
                        fi
                        temp_file="$(mktemp)"
                        read -p "Enter the value in column '$col_name' to filter by: " filter_value
                        if [[ "${selected_column[@]}" =~ "$filter_value" ]]; then
                            awk -v col_index="$col_index" -v filter_value="$filter_value" -F: '
                                BEGIN { OFS=":"; }
                                {
                                    if ($((col_index+1)) == filter_value) {
                                        next; 
                                    }
                                    print $0 >> "'"$temp_file"'";  
                                }
                                END {
                                    close("'"$temp_file"'");
                                    system("mv '"$temp_file"' '"$table_name"'"); 
                                }
                            ' "$table_name"
                            echo -e "\e[1;32mRows in '$table_name' with '$col_name'='$filter_value' deleted successfully.\e[0m"
                        else
                            echo -e "\e[1;31mValue '$filter_value' not found in column '$col_name'.\e[0m"
                        fi
                    else
                        echo -e "\e[1;31mColumn '$col_name' not found in '$table_name'.\e[0m"
                    fi
                    ;;

                3)
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
