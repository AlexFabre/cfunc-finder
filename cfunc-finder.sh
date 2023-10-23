#!/bin/bash
# ==========================================
#   cfunc-finder - Finds the start line and finish line
#                  of a function declaration inside a C file
#   Copyright (C) 2023 Alex Fabre
#   [Released under MIT License. Please refer to license.txt for details]
# ==========================================

# Call this script by giving the two following args:
# - the C source file where the function has to be found
# - the function name

# Script self version informations
CFUNC_FINDER_MAJOR=0
CFUNC_FINDER_MINOR=1
CFUNC_FINDER_FIX=0

# Print variables
CFUNC_FINDER="cfunc-finder.sh"
CFUNC_FINDER_REV="$CFUNC_FINDER_MAJOR.$CFUNC_FINDER_MINOR.$CFUNC_FINDER_FIX"
CFUNC_FINDER_INTRO_L1="Finds the start line and finish line"
CFUNC_FINDER_INTRO_L2="of a function declaration inside a C file"

# ==========================================
# Default settings
# ==========================================

# path to the source file where to look for the function declaration
file=""

# C function name
func_name=""

# ==========================================
# Script call checks
# ==========================================

# The user has to provide the path for the
# dest file when calling the script
usage() {
    echo "==> $CFUNC_FINDER $CFUNC_FINDER_REV"
    echo "$CFUNC_FINDER_INTRO_L1"
    echo "$CFUNC_FINDER_INTRO_L2"
    echo "Usage:"
    echo "$CFUNC_FINDER [options]"
    echo "-i <input file path>"
    echo "-f <function name>"
    echo "-h <help>"
    echo "-v <script version>"
}

# Check the call of the script
while getopts ":i:f:hv" opt; do
    case "${opt}" in
        i)
            file=${OPTARG}
            ;;
        f)
            func_name=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        v)
            echo "$CFUNC_FINDER_REV"
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

# ==========================================
# Functions
# ==========================================

# Check that input file path was provided
if [ -z "$file" ]; then
    usage
    exit 1
fi

# Check that function name was provided
if [ -z "$func_name" ]; then
    usage
    exit 1
fi

line_number=0
start_line=0
found_start_line=false
open_brackets=0
close_brackets=0

while IFS= read -r line; do
  ((line_number++))

  # Check if the line contains the function declaration beginning
  if [[ $line == *"$func_name"* ]]; then
    start_line=$line_number
    found_start_line=true
    open_brackets=0
    close_brackets=0
  fi

  # TODO: if found_start_line is false, continue loop and do not do the following checks
  if [ "$found_start_line" = true ]; then

    # Count the number of opening and closing brackets on each line
    open_brackets=$((open_brackets + $(grep -o '{' <<< "$line" | wc -l)))
    close_brackets=$((close_brackets + $(grep -o '}' <<< "$line" | wc -l)))

    if [ "$close_brackets" -gt "$open_brackets" ]; then
        found_start_line=false
    fi

    # Check if we have found the start line and the function declaration ends
    if [ "$open_brackets" != 0 ]; then
        if [ "$open_brackets" -eq "$close_brackets" ]; then
            echo "$func_name"
            echo "start line $start_line"
            echo "end line   $line_number"
            break
        fi
    fi
  fi

done < "$file"
