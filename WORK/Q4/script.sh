#!/bin/bash

LOG_FILE="script_log.txt"
ERROR_LOG="error_log.txt"

echo "Starting script execution..." > $LOG_FILE
echo "Starting error log..." > $ERROR_LOG


if [[ "$#" -eq 1 ]]; then
  
  if [[ -f "$1" && "$1" == *.csv ]]; then
    echo "CSV file is ok." | tee -a $LOG_FILE
    # TODO: goes here 
    csv_file=$1
  else
    echo "Error: '$1' not valid .csv file  " | tee $ERROR_LOG
    exit 1
  fi

else
  csv_file=$(find . -maxdepth 1 -type f -name "*.csv" | head -n 1)
  # If a CSV file is found, print it
  if [[ -n "$csv_file" ]]; then
    echo "Found CSV file in the current directory: $csv_file" | tee -a $LOG_FILE
    echo "working ... " 
    # TODO: work here 
  else
    # If no CSV file is found, exit
    echo "Error: No CSV file found in the current directory." | tee -a $ERROR_LOG
    exit 1
  fi
fi

# Create and activate a virtual environment if it doesn't exist
echo "checking for venv ...  " | tee -a $LOG_FILE
VENV_DIR="venv"
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating virtual environment..." | tee -a $LOG_FILE
    python3 -m venv ./venv

    if [[ $? -eq 0 ]]; then
        echo "Virtual environment created successfully." | tee -a $LOG_FILE
    else
        echo "Failed to create virtual environment." | tee -a $ERROR_LOG
        exit 1
    fi
else 
    echo "vevn found in the cur dir." | tee -a $LOG_FILE
fi


echo "activiting venv"  | tee -a $LOG_FILE
# Activate the virtual environment
source ./venv/bin/activate

# Check if virtual environment is active
if [[ $? -eq 0 ]]; then
    echo "Virtual environment is active." | tee -a $LOG_FILE
else
    echo "Error: Virtual environment activation failed." | tee -a $ERROR_LOG
    exit 1
fi

# Install required packages from requirements.txt if needed
if [[ ! -f "requirements.txt" ]]; then
    echo "requirements.txt not found. exiting" | tee -a $ERROR_LOG
    exit 1
fi

echo "installing requirements.txt " | tee -a $LOG_FILE
pip install -r requirements.txt

if [[ $? -eq 0 ]]; then
    echo "Required packages installed successfully." | tee -a $LOG_FILE
else
    echo "Error: Failed to install required packages." | tee -a $ERROR_LOG
    exit 1
fi


pip list | tee -a $LOG_FILE

# ## Read the CSV file and process each row
while IFS=, read -r plant_name height leaf_count dry_weight
do
    if [[ -n "$plant_name" ]]; then
        height=$(echo $height | sed 's/"//g')
        leaf_count=$(echo $leaf_count | sed 's/"//g')
        dry_weight=$(echo $dry_weight | sed 's/"//g')
        
        mkdir -p "Diagrams/$plant_name"    
        cd "Diagrams/$plant_name" 
        COMMAND="python3 ../../plant_v2.py --plant $plant_name --height $height --leaf_count $leaf_count --dry_weight $dry_weight"
        $COMMAND >> "../../$LOG_FILE"
        cd ../../
                    
        # Check if Python script ran successfully
        if [[ $? -eq 0 ]]; then
                echo "Python script executed successfully for $plant_name." | tee -a $LOG_FILE
            else
                echo "Error: Python script execution failed for $plant_name." | tee -a $ERROR_LOG
        fi
    
    fi

done < <(tail -n +2 "$csv_file")  # Skips the first line
# # Deactivate the virtual environment
deactivate
echo "Script execution completed. , deactivating" | tee -a $LOG_FILE

tree Diagrams | tee -a $LOG_FILE


