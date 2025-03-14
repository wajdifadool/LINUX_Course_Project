#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
clear
CURRENT_CSV=""

# Function to display menu
show_menu() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${YELLOW}        Plant Data Management        ${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e "${GREEN}1) Create a new CSV file${NC}"
    echo -e "${GREEN}2) Select an existing CSV file${NC}"
    echo -e "${GREEN}3) Display the current CSV file${NC}"
    echo -e "${GREEN}4) Add a new plant row${NC}"
    echo -e "${GREEN}5) Run Python script for a plant${NC}"
    echo -e "${GREEN}6) Update a row for a plant${NC}"
    echo -e "${GREEN}7) Delete a row (by index or plant)${NC}"
    echo -e "${GREEN}8) Show plant with highest leaf count${NC}"
    echo -e "${GREEN}9) Exit${NC}"
    echo -e "${BLUE}======================================${NC}"
}



# Function to create a new CSV file
create_csv() {
    clear
    read -p "Enter the name of the new CSV file: " filename
    if [[ -z "$filename" ]]; then
        echo -e "${RED}Invalid filename!${NC}"
        return
    fi
    echo "Plant,Height,Leaf Count,Dry Weight" > "$filename"
    CURRENT_CSV="$filename"
    echo -e "${GREEN}Created new CSV: $CURRENT_CSV${NC}"
}


# Function to select an existing CSV file
select_csv() {
    clear 
    read -p "Enter the name of the existing CSV file: " filename
    if [[ -f "$filename" ]]; then
        CURRENT_CSV="$filename"
        echo -e "${GREEN}Selected: $CURRENT_CSV${NC}"
    else
        echo -e "${RED}File not found!${NC}"
    fi
}

# Function to display the CSV file
display_csv() {
    clear 
    if [[ -z "$CURRENT_CSV" ]]; then
        echo -e "${RED}No CSV file selected!${NC}"
        return
    fi
    echo -e "${YELLOW}Contents of $CURRENT_CSV:${NC}"
    # column -t -s "," "$CURRENT_CSV"
    cat "$CURRENT_CSV"
    
    
}



add_row() {
    clear 
    if [[ -z "$CURRENT_CSV" ]]; then
        echo -e "${RED}No CSV file selected!${NC}"
        return
    fi
    
read -p "Enter plant name: " plant
    read -a height_arr -p "Enter height values (space-separated): "
    read -a leaf_arr -p "Enter leaf count values (space-separated): "
    read -a weight_arr -p "Enter dry weight values (space-separated): "

    # Check if all arrays have the same length
    if [[ ${#height_arr[@]} -ne ${#leaf_arr[@]} || ${#leaf_arr[@]} -ne ${#weight_arr[@]} ]]; then
        echo -e "${RED} <Usage> Columns in diffrent count ${NC}"
        return
    fi
    
    # Validate numeric input
    for val in "${height_arr[@]}" "${leaf_arr[@]}" "${weight_arr[@]}"; do
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            echo -e "${RED} <Usage> Columns contains not ingers  ${NC}"
            return
        fi
    done
    
    # Convert arrays back to space-separated strings
    heights="${height_arr[*]}"
    leaves="${leaf_arr[*]}"
    weights="${weight_arr[*]}"

    echo "$plant," "$heights ", "$leaves ", "$weights" >> "$CURRENT_CSV"
    echo -e "${GREEN}Row added to $CURRENT_CSV${NC}"
        
}

# Function to run Python script
run_python_script() {
    clear 
    if [[ -z "$CURRENT_CSV" ]]; then
        echo -e "Error::<usage>${RED}No CSV file ${CURRENT_CSV} ${NC}"
        return
    fi
    
    read -p "Enter plant name: " plant_name 
    
    cat $CURRENT_CSV | grep $plant_name > current_plant_row
    
    
    # Validate rose is there
    if [[ -z "$plant_name" ]]; then
        echo -e "${RED}Error: Plant '$plant_name' not found in $CURRENT_CSV.${NC}"
        return
    fi
    
    
    # Use awk to split by sep = ','
    IFS=',' read -r plant_name height leaf_count dry_weight <<< "$(awk -F, '{print $1","$2","$3","$4}' current_plant_row)"
    
    # echo "$plant_name"
    # echo "$height"
    # echo "$leaf_count"
    # echo "$dry_weight"
     
    echo  -e "${GREEN}Executig python script: ${YELLOW}<plant_v2.py> ... !${NC}"
    
    python3 plant_v2.py --plant "$plant_name" --height $height --leaf_count $leaf_count --dry_weight $dry_weight

    #  check if the file execution is succsful by checking status code 
    # Check the exit status
    if [[ $? -eq 0 ]]; then
        echo "Python script executed successfully."
    else
        echo "Error: Python script execution failed."
    fi

}

# function to update row 
update_row(){
    clear
    if [[ -z "$CURRENT_CSV" ]]; then
        echo -e "${RED}No CSV file selected!${NC}"
        return
    fi
    
    read -p "Enter plant name to update its value:" plant_name
    

    plant_row=$(cat "$CURRENT_CSV" | grep "^$plant_name,")

    if [[ -z $plant_row ]]; then
        echo -e "${RED}Error: Plant '$plant_name' not found in $CURRENT_CSV.${NC}"
        return    
    fi
    
    
    
    
    

    
    # Validate rose is there
    if [[ -z "$plant_row" ]]; then
        echo -e "${RED}Error: Plant '$plant_name' not found in $CURRENT_CSV.${NC}"
        return
    fi
    
    sed -i.bak "/^$plant_name,/d" "$CURRENT_CSV" && rm "$CURRENT_CSV.bak"
    
    echo " found $plant_row"  # Prints the found row
    
    echo "$plant_name"  # Prints the found row
    read -a height_arr -p "Enter height values (space-separated): "
    read -a leaf_arr -p "Enter leaf count values (space-separated): "
    read -a weight_arr -p "Enter dry weight values (space-separated): "

    # Check if all arrays have the same length
    if [[ ${#height_arr[@]} -ne ${#leaf_arr[@]} || ${#leaf_arr[@]} -ne ${#weight_arr[@]} ]]; then
        echo -e "${RED} <Usage> Columns in diffrent count ${NC}"
        return
    fi
    
    # Validate numeric input
    for val in "${height_arr[@]}" "${leaf_arr[@]}" "${weight_arr[@]}"; do
        if ! [[ "$val" =~ ^[0-9]+$ ]]; then
            echo -e "${RED} <Usage> Columns contains not ingers  ${NC}"
            return
        fi
    done
    
    # Convert arrays back to space-separated strings
    heights="${height_arr[*]}"
    leaves="${leaf_arr[*]}"
    weights="${weight_arr[*]}"

    echo "$plant_name," "$heights ", "$leaves ", "$weights" >> "$CURRENT_CSV"
    echo -e "${GREEN}Row updated in $CURRENT_CSV${NC}"
     
}


delete_row(){
    # Prompt user for input
    echo "Delete Row (index or name)"
    read user_input

    # Check if the input is a number (line number)
    if [[ "$user_input" =~ ^[0-9]+$ ]]; then
    # Input is a number, delete by line number
    # sed -i.bak "${user_input}d" "$CURRENT_CSV" && rm "$CURRENT_CSV.bak"
        sed -i.bak -e "${user_input}d" "$CURRENT_CSV" && rm "$CURRENT_CSV.bak"
        echo "Deleted line $user_input."
    
    else
        # Input is not a number, delete by word (assuming it's a plant name)
        sed -i.bak "/^$user_input,/d" "$CURRENT_CSV" && rm "$CURRENT_CSV.bak"
        echo "Deleted row containing '$user_input'."
    fi
}

highest_leafs_avg(){
    python3 leaf_avg.py $CURRENT_CSV

}
while true; do
    show_menu
    read -p "Choose an option: " choice
    case $choice in
        1) create_csv ;;
        2) select_csv ;;
        3) display_csv ;;
        4) add_row ;;
        5) run_python_script ;;
        6) update_row ;; 
        7) delete_row ;;
        8)  highest_leafs_avg;; 
        8) echo "Find highest leaf count (Not implemented yet)" ;;
        9) echo -e "${YELLOW}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice!${NC}" ;;
    esac
done
