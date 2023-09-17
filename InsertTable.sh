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
    read -p "Enter the name of the table: " table_name
    if [ -f "$table_name" ]; then
        IFS=":" read -ra col_names <<< $(awk 'NR==1' "$table_name")
        IFS=":" read -ra col_types <<< $(awk 'NR==2' "$table_name")

        retry=true 
        while $retry; do
            if [ "${col_names[0]}" == "${col_names[0]}" ]; then
                read -p "Enter a unique value for ${col_names[0]} (${col_types[0]}): " new_id
                if grep -q "^$new_id:" "$table_name"; then
                    echo -e "\e[1;31mA record with '$new_id' already exists.\e[0m"
                    continue
                fi

                if ! valid_value "$new_id" "${col_types[0]}"; then
                    continue 
                fi

            fi
            retry=false
        done

        values=()
        i=1
        while [ $i -lt ${#col_names[@]} ]; do
            col_name="${col_names[i]}"
            col_type="${col_types[i]}"

            read -p "Enter value for $col_name ($col_type): " value

            if ! valid_value "$value" "$col_type"; then
                continue 
            fi

            values+=("$value")
            i=$((i + 1))
        done

        new_record="$new_id:$(IFS=":"; echo "${values[*]}")"
        echo "$new_record" >> "$table_name"
        echo -e "\e[1;32mNew record added to '$table_name'.\e[0m"
        break
    else
        echo -e "\e[1;31mTable '$table_name' does not exist.\e[0m "
    fi
done
