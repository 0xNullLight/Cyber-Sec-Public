#!/bin/bash

# Clear the terminal screen at the start
clear

# Introduction message to explain the script functionality
echo "Welcome to the Package Usage Report Generator!"
echo "This script will help you analyze the packages installed on your system."
echo "It will gather important system forensics and auditing metrics for each package, including:"
echo ""
echo "- Package Name"
echo "- Version"
echo "- Size (in MB)"
echo "- Location"
echo "- Last Accessed Time"
echo "- Last Modified Time"
echo "- Usage Status (if you've used the package based on your bash history)"
echo ""
echo "You can choose from three output formats for the report:"
echo "1. Table format"
echo "2. CSV format"
echo "3. JSON format"
echo ""

# Prompt user for format choice
read -p "Enter the number (1/2/3) to select the desired format: " format_choice

# Clear the screen after user makes a selection
clear

# Example of output file locations
echo ""
echo "Example output file locations:"
echo "- /home/user/reports/package_usage_report.txt"
echo "- /var/logs/package_usage_report.csv"
echo "- /path/to/directory/package_usage_report.json"
echo ""
echo "If you don't provide a directory, the file will be saved in the current directory by default."

# Prompt for output file location and name
read -p "Enter the directory and file name to save the report (press Enter to use the default 'package_usage_report'): " output_location

# Set default location if the user doesn't provide one
if [ -z "$output_location" ]; then
    output_location="package_usage_report"
fi

# Determine the file extension based on the selected format
case $format_choice in
    1)
        # Table format, default to .txt
        if [[ "$output_location" != *.txt ]]; then
            output_location="$output_location.txt"
        fi
        ;;
    2)
        # CSV format, default to .csv
        if [[ "$output_location" != *.csv ]]; then
            output_location="$output_location.csv"
        fi
        ;;
    3)
        # JSON format, default to .json
        if [[ "$output_location" != *.json ]]; then
            output_location="$output_location.json"
        fi
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Check if the user provided a directory, and ensure the directory exists
dir_name=$(dirname "$output_location")
if [ ! -d "$dir_name" ] && [ "$dir_name" != "." ]; then
    echo "Directory does not exist. Creating it now."
    mkdir -p "$dir_name"
fi

# Get the list of installed packages
installed_packages=$(dpkg --get-selections | awk '{print $1}')

# Initialize output based on format choice
case $format_choice in
    1)
        # Table format
        echo "Package Usage Report (Table Format)" > "$output_location"
        echo "===========================================================================" >> "$output_location"
        echo "" >> "$output_location"
        echo -e "No.   Package Name             Version    Size    Location                    Last Accessed            Last Modified          Usage Status" >> "$output_location"
        echo "--------------------------------------------------------------------------" >> "$output_location"
        ;;
    2)
        # CSV format
        echo "Package Usage Report (CSV Format)" > "$output_location"
        echo "No.,Package Name,Version,Size (MB),Location,Last Accessed,Last Modified,Usage Status" >> "$output_location"
        ;;
    3)
        # JSON format
        echo "{" > "$output_location"
        echo '  "packages": [' >> "$output_location"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Clear the screen again after initializing the report format
clear

# Initialize a counter for numbering packages
counter=1

# Check each installed package
for package in $installed_packages; do
    # Get the package version
    version=$(dpkg-query -W -f='${Version}' "$package")
    
    # Get the size of the package (in kilobytes)
    size=$(dpkg-query -W -f='${Installed-Size}' "$package")
    
    # Convert size to MB (rounded)
    size_mb=$(echo "scale=2; $size/1024" | bc)
    
    # Get the location of the package files
    location=$(dpkg-query -L "$package" | head -n 1) # Just show the first file location
    
    # Get the last access time of the package's location
    last_accessed=$(stat -c %x "$location" 2>/dev/null || echo "N/A")
    
    # Get the last modified time of the package's location
    last_modified=$(stat -c %y "$location" 2>/dev/null || echo "N/A")
    
    # Check if you've ever used the package by searching in the bash history
    usage_count=$(grep -i "$package" ~/.bash_history | wc -l)

    # Format package name for alignment (pad to 24 characters)
    package_name=$(printf "%-24s" "$package")
    
    # Format the entry based on the chosen format
    case $format_choice in
        1)
            # Table format
            usage_status="Used ($usage_count times)"
            printf "%-5s %-24s %-10s %-8s %-25s %-25s %-25s %-25s\n" \
            "$counter" "$package_name" "$version" "$size_mb" "$location" "$last_accessed" "$last_modified" "$usage_status" >> "$output_location"
            ;;
        2)
            # CSV format
            usage_status="Used ($usage_count times)"
            echo "$counter,$package_name,$version,$size_mb,$location,$last_accessed,$last_modified,$usage_status" >> "$output_location"
            ;;
        3)
            # JSON format
            usage_status="Used ($usage_count times)"
            echo "    {" >> "$output_location"
            echo "      \"No\": $counter," >> "$output_location"
            echo "      \"Package Name\": \"$package\"," >> "$output_location"
            echo "      \"Version\": \"$version\"," >> "$output_location"
            echo "      \"Size (MB)\": \"$size_mb\"," >> "$output_location"
            echo "      \"Location\": \"$location\"," >> "$output_location"
            echo "      \"Last Accessed\": \"$last_accessed\"," >> "$output_location"
            echo "      \"Last Modified\": \"$last_modified\"," >> "$output_location"
            echo "      \"Usage Status\": \"$usage_status\"" >> "$output_location"
            if [ "$counter" -eq "$(echo "$installed_packages" | wc -l)" ]; then
                echo "    }" >> "$output_location"
            else
                echo "    }," >> "$output_location"
            fi
            ;;
    esac
    
    # Increment the counter
    ((counter++))
done

# Close JSON array if JSON format
if [ "$format_choice" -eq 3 ]; then
    echo "  ]" >> "$output_location"
    echo "}" >> "$output_location"
fi

# Output the result
clear
echo "Report generated in $output_location"
cat "$output_location"
