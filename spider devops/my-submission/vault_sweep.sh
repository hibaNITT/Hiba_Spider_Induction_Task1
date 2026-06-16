#!/bin/bash

# 1] Grabbing the first input given to the script and save it in a variable
TARGET_DIR=$1


#2] Check if the TARGET_DIR variable is completely empty
if [ -z "$TARGET_DIR" ]; then
    echo "Error: You forgot to provide a directory path!"
    echo "Usage: bash vault_sweep.sh <directory_path>"
    exit 1
fi

# 3] Checking if the directory actually exists on the system
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: The directory '$TARGET_DIR' does not exist!"
    exit 1
fi


# 4] Now that we are sure the folder exists, we need to scan inside it to find files ending with .sh
# In DevOps, malicious files can be buried deep inside nested folders or intentionally hidden by 
# starting their filenames with a dot (like .hidden_script.sh).

# Define Log File location and ensure its directory exists
LOG_FILE="./vault_sweep.log" # Update this path based on where you want it saved

# Helper function to generate timestamps in the required format: [2026-05-10 14:32:01]
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}


echo "Success: '$TARGET_DIR' is a valid directory. Proceeding with scan..."

# 5] adding search functionality
# Finding all .sh files and loop through them one by one

find "$TARGET_DIR" -type f -name "*.sh" | while read -r FILE_PATH; do
    echo "location of the script: $FILE_PATH"

    # our script now automatically crawls through the specified directory, uncovers hidden files

    # 6] We need to look inside those files to catch destructive behavior before it runs.

    # 7] first major threat pattern we must flag is Destructive Commands like rm -rf / or mkfs (which formats hard drives).

    # 8] We also need to hunt for:
    # Other destructive commands: mkfs  or shutdown/reboot.
    # Suspicious downloads: curl or wget piping directly into a shell interpreter like sh or bash (e.g., curl ... | bash).
    # Instead of writing a separate grep line for every single bad keyword, we can use 
    # Extended Regular Expressions - grep -E


    echo "auditing : $FILE_PATH"

# Scan for Destructive Commands (rm -rf, mkfs, shutdown, reboot)
    if grep -E -q "rm -rf|mkfs|shutdown|reboot" "$FILE_PATH"; then
    echo "[WARN] $FILE_PATH _ Reason: Destructive command detected!"
    echo "[$(get_timestamp)] [WARN] $FILE_PATH  contains destructive command" >> "$LOG_FILE"
    fi 

# Scan for Suspicious Downloads (curl/wget piped into sh/bash)
    if grep -E -q "(curl|wget).*\|.*(sh|bash)" "$FILE_PATH"; then
    echo "[WARN] $FILE_PATH _ Reason: Suspicious download pipe to shell detected!"
    echo "[$(get_timestamp)] [WARN] $FILE_PATH  contains suspicious download pipe" >> "$LOG_FILE"
    fi 



# 9] insecure permisiions 
# When we look at a file's permissions in Linux, it is represented by 10 characters, like this: -rwxrwxrwx

    #  Getting the 10-character permission string of the file (e.g., -rwxrwxrwx)
    PERMISSIONS=$(stat -c "%A" "$FILE_PATH")

    # Extracting just the 9th character 
    WORLD_WRITE_BIT=${PERMISSIONS:8:1}

    # If that 9th character is "w", then the file is world-writable-danger!!!
    if [ "$WORLD_WRITE_BIT" = "w" ]; then

     
        echo "[WARN] $FILE_PATH _ Reason: Insecure permissions (world-writable)"
        
        # Logging the warning to our log file
        echo "[$(get_timestamp)] [WARN] $FILE_PATH  contains world-writable permissions" >> "$LOG_FILE"

        #  if you want to fix it
        # /dev/tty -  makes sure it reads from our keyboard
        read -p "Warning: $FILE_PATH is world-writable. Fix it? (y/n): " choice < /dev/tty
        
        # If yes , we fix it
        if [ "$choice" = "y" ] || [ "$choice" = "yes" ]; then
            chmod o-w "$FILE_PATH"  # Remove the write bit for others
            
            # Log that we fixed it
            echo "[$(get_timestamp)] [FIX]  $FILE_PATH  removed world write permission" >> "$LOG_FILE"
            echo "Success: Removed world write permission for $FILE_PATH."
        else
            echo "Skipping fix for $FILE_PATH."
        fi
    fi
done


# TASK 2: FILE CLEANING 

echo "Starting Environment File Audit..."

# Find all files starting with .env recursively
find "$TARGET_DIR" -type f -name ".env*" | while read -r ENV_FILE; do
    SANITIZED_FILE="${ENV_FILE}.sanitized"
    echo "Sanitizing: $ENV_FILE -> $SANITIZED_FILE"
    
    # Clear out the sanitized file if it already exists from a previous run
    > "$SANITIZED_FILE"

    # Initialize counters for logging 
    valid_count=0
    invalid_count=0
    rejected_secrets=()

    # Read the .env file line by line
    while read -r line || [ -n "$line" ]; do
        # Skip completely empty lines or comments
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi

        # Reject forbidden keys (PASSWORD, SECRET, TOKEN, PATH)
        if echo "$line" | grep -E -q "^(PASSWORD|SECRET|TOKEN|PATH)="; then
            invalid_count=$((invalid_count + 1))
            # Save the exact line to show in logs later
           rejected_secrets+=("$line")
            continue
        fi

        # Validate structure (Only A-Z0-9_, no spaces, no unnecessary quotes)
        # Key=Value with no spaces around '='
        
        if echo "$line" | grep -E -q '^[A-Z0-9_]+=[^[:space:]].*$'; then

            # Ensure the value isn't wrapped in unnecessary quotes 
            if echo "$line" | grep -E -q '=("[^"]*"|'\''.*'\'')'; then
                invalid_count=$((invalid_count + 1))
            else
                # if Line is perfectly valid 
                valid_count=$((valid_count + 1))
                echo "$line" >> "$SANITIZED_FILE"
            fi
        else
            # Failed structure layout
            invalid_count=$((invalid_count + 1))
        fi
    done < "$ENV_FILE"

    # Task 3 Logging placeholders for these results 
    echo "[$(get_timestamp)] [INFO] $ENV_FILE  Valid: $valid_count, Invalid: $invalid_count" >> "$LOG_FILE"
    
if [ ${#rejected_secrets[@]} -gt 0 ]; then
        # Format the skipped variables neatly into a comma-separated string with spaces
        joined_secrets=$(IFS=", "; echo "${rejected_secrets[*]}")
        echo "[$(get_timestamp)] [SKIP] $ENV_FILE  Rejected: $joined_secrets" >> "$LOG_FILE"
    fi

    echo "Finished cleaning $ENV_FILE."
done

# Task 3: Set log file permissions so only the current user can read/write
chmod 600 "$LOG_FILE"

echo "Audit complete! Check $LOG_FILE for details."