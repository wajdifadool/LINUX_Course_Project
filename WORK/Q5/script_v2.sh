#!/bin/bash

# git branch BR_Q5
# git checkout BR_Q5


LOG_FILE="script_log.txt"
ERROR_LOG="error_log.txt"
timestamp=$(date +"%Y%m%d_%H%M%S")
echo "Starting script execution..." > $LOG_FILE
echo "Starting error log..." > $ERROR_LOG



# DESCRIPTION :  
    # enhanced script thats take multi params 
    
: '
 OPTIONS 
    -f, --file  the scv file path 
    -o, --output output_dir
'
   


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color



# Default values
csv_file=""
output_dir=""       #  default is empty string 
skip_venv=false

log_file="script_log.txt"

if [[ "$#" -eq 0 || $(($# % 2)) -ne 0  ]]; then 
    echo -e "${RED}Eroor: usage <script> <param , param ...>, Exiting${NC}" | tee $ERROR_LOG
    exit 1 
fi


# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--file) csv_file="$2"; shift ;;  
        -o|--output) output_dir="$2"; shift ;;  
        -b|--backup) backup="$2"; shift ;;  
        
        # --sv|--skip-venv) skip_venv=true ;;  
        *) echo "Unknown option: $1" | tee -a "$log_file"; exit 1 ;;  
    esac
    shift
done
if [[ ! -n $csv_file ]]; then 
    echo "$timestamp: No scv file provided **Exit(1)**" | tee -a $ERROR_LOG
    exit 1 
fi

# # checks for file validity
if [[ ! -f $csv_file ]]; then
    echo "$timestamp: CSV file is Bad. **Exit(1)**" | tee -a $ERROR_LOG
    exit 1 
fi

echo "$timestamp CSV path $csv_file" | tee -a $LOG_FILE

# Checks for output dir
if [[ ! -n $output_dir ]]; then 
    # create the output dir in the current folder
    output_dir="Diagrams"
fi
echo "$timestamp Output Dir $output_dir" | tee -a $LOG_FILE

# should create backup tar file ? false by default
if [[ ! -n $backup ]]; then 
    # create the output dir in the current folder
    backup="false"
fi
echo "aaaaaaaaaaaaaaaaaaaaaaaaaaa"
echo "$timestamp Backup= $backup" | tee -a $LOG_FILE

#            _        _   
#  ___  __ _| |_ _ __| |_ 
# / __|/ _` | __| '__| __|
# \__ \ (_| | |_| |  | |_ 
# |___/\__,_|\__|_|   \__|
                        


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
    echo "Error: Virtual environment activation failed Exit(1)" | tee -a $ERROR_LOG
    exit 1
fi



# Install required packages from requirements.txt if needed
if [[ ! -f "requirements.txt" ]]; then
    echo "requirements.txt not found. Exit(1)" | tee -a $ERROR_LOG
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


# copy the code file to the current dir 
cp ../../CODE/plant_v2.py plant_v2.py 
echo "copy python script to the current dir" | tee -a $LOG_FILE

# ## Read the CSV file and process each row
while IFS=, read -r plant_name height leaf_count dry_weight
do
    if [[ -n "$plant_name" ]]; then
        height=$(echo $height | sed 's/"//g')
        leaf_count=$(echo $leaf_count | sed 's/"//g')
        dry_weight=$(echo $dry_weight | sed 's/"//g')
        
        # echo $dry_weight
        # echo $leaf_count
        # echo $height
        
        mkdir -p "$output_dir/$plant_name"    
        cd "$output_dir/$plant_name" 
        
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
echo "Rmeove python script from the current dir" | tee -a $LOG_FILE
rm plant_v2.py 

tree . -I "venv" | tee -a $LOG_FILE
# echo Removing file 


#        ____  
# __   _|___ \ 
# \ \ / / __) |
#  \ V / / __/ 
#   \_/ |_____|
             

# implementing backup abillity 
if [[ $backup == "true" ]]; then    
    echo "$timestamp Creating backup file " | tee -a $LOG_FILE
    tar -czf ../../BACKUP/diagrams_backup_$timestamp.tar.gz $output_dir
    echo "$timestamp Created backup tar: diagrams_backup_$timestamp.tar.gz file " | tee -a $LOG_FILE
fi

: '
--------------------------------------
----- not included in the script -----
--------------------------------------
# adding all work to current branch
git add .
git commit -m "Completed Q5 bash script"
git checkout master
git merge BR_Q5

git log --oneline | tee git_commits.log
# adding 
git add git_commits.log
git commit -m "adding git_commits.log"

 
git push origin master

--------------------------------------
--------------------------------------
'
