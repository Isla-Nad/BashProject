#! /usr/bin/bash
PS3=$'\e[1;33mDB: \e[0m\e[1;36m'"$1"$'\e[1;35m ✅\e[0m '

select choice in "Create Table" "List Table" "Select from Table" "Delete from Table" "Insert into Table"  "Update Table" "Drop Table" "Exit"
do 
	case $REPLY in
	1)
        read -p "Enter Name of the Table: " name 
        if is_valid "$name"; then
            if [ -f "$name" ] ; then
                echo "Table '$name' already exists."
            else
                touch "$name"
                echo "Table '$name' created successfully."
            fi
        else
            echo "Invalid Table name."
        fi
		;;
	2)
		ls --file-type | grep -v /$
		;;
	3)
		echo "List table"
		;;
	4)
		echo "Delete table"
		;;
	5)
		echo "Exit"
		;;
	6)
		echo "Exit"
		;;
	7)
		ls --file-type | grep -v /$
		read -p "Enter Name of Table " name
		if [ -f $name ] ; then			
			rm $name
		else
			echo "Table '$name' does not exist."	
		fi 
		;;
	8)
		echo goodbye
		exit
		;;
	*) 
		echo "NotFound"
	esac
done
