#! /usr/bin/bash
cd $1

PS3=$'\e[1;33mDB: \e[0m\e[1;36m'"$1"$'\e[1;35m ✅\e[0m '

list_tables() {
    echo -e "\e[1;34m-----------Available tables:----------------\e[0m"
    ls --file-type | grep -v /$ | nl -s": "
	echo -e "\e[1;34m--------------------------------------------\e[0m"
}

select choice in "Create Table" "List Tables" "Select from Table" "Delete from Table" "Insert into Table"  "Update Table" "Drop Table" "Exit"
do 
	case $REPLY in
	1)
		source CreateTable.sh
		;;
	2)
		list_tables
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
		list_tables
		read -p "Enter the name of the table to drop:" name
		if [ -f $name ] ; then			
			rm $name
			echo -e "Table \e[1;32m$name\e[0m has been dropped."
		else
			echo -e "Table \e[1;31m$name\e[0m does not exist."	
		fi 
		;;
	8)
		echo goodbye
		exit
		;;
	*) 
		echo "Invalid choice. Please enter a valid option." ;;
	esac
done
