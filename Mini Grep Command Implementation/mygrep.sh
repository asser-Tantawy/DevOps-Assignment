#!/bin/bash

# Author : Asser Tantawy
# Date : 2025-4-27 

help() {
    echo -e "NAME \n     mygrep.sh"
    echo -e "SYNOPSIS\n\tmygrep.sh [OPTION...] PATTERNS [FILE...]\n"
    echo -e "DESCRIPTION\nmygrep.sh is a simple script to search for a pattern in a file.\nIt supports case-insensitive search and line number display.\n"
    echo "Options:"
    echo "  -n , -N     Show line numbers"
    echo "  -v , -V     Invert match (show non-matching lines)"
    echo -e "  --help   Show this help message\n"
    echo "Examples:"
    echo "  mygrep.sh hello testfile.txt"
    echo "  mygrep.sh -n hello testfile.txt"
    echo "  mygrep.sh -vn hello testfile.txt"
}

line_numbers=false
invert_match=false
pattern=""
file=""
options_done=false

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided !"
    help
    exit 1
fi

if [[ "$1" == "--help" ]]; then
    help
    exit 0
fi

if [ $# -eq 2 ] && [[ "$1" == -* ]] && [[ "$1" != "--help" ]] && [[ -f "$2" ]]; then
    echo "Error: Missing search pattern!!"
    help
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            help
            exit 0
            ;;
        -*)
            # Process flags (-n, -v, -vn, -nv)
            if [[ "${1,,}" == *n* ]]; then
                line_numbers=true
            fi
            if [[ "${1,,}" == *v* ]]; then
                invert_match=true
            fi
            shift
            ;;
        *)
            # First non-option argument = pattern
            if [ -z "$pattern" ]; then
                pattern="$1"
            elif [ -z "$file" ]; then
                file="$1"
            else
                echo "Error: too many arguments!"
                help
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$pattern" ]; then
    echo "Error: missing search pattern"
    help
    exit 1
fi

if [ -z "$file" ]; then
    echo "Error: Missing file name!"
    help
    exit 1
fi

if [ ! -f "$file" ]; then
    echo "Error: File '$file' does not exist!!"
    exit 1
fi

line_number=1
while IFS= read -r line; do
    lower_line="${line,,}"
    lower_pattern="${pattern,,}"

    if [[ "$lower_line" == *"$lower_pattern"* ]]; then
        match=true
    else
        match=false
    fi

    if [ "$invert_match" = true ]; then
        if [ "$match" = true ]; then
            match=false
        else
            match=true
        fi
    fi

    if [ "$match" = true ]; then
        if [ "$line_numbers" = true ]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi

    line_number=$((line_number + 1))
done < "$file"
