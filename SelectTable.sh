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

read -p "Enter the name of the table: " table_name
if [ -f "$table_name" ]; then
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
else
	echo -e "Table \e[1;31m$table_name\e[0m does not exist."	
fi 
