#!/bin/bash

# Updated savepoint.sh to be a bash function and added tab completion

# To use, add the following to your .zshrc:
# autoload bashcompinit && bashcompinit
# source /path/to/savepoint_tab.sh

saveloc="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)/saves/"

# Tab completion function
_savepoint_completions() {
    local cur prev flag_opts label_opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    flag_opts="-s -l -r --list --help"
    label_opts=$(ls -m $saveloc | sed -e 's/,//g' -e 's/.txt//g') # This converts the output of ls -m to the format for the completions
    if [[ ${prev} == "savepoint" ]] ; then
        COMPREPLY=( $(compgen -W "${flag_opts}" -- ${cur}) )
        return 0
    elif [[ ${prev} == "-l" || ${prev} == "-r" || ${prev} == "-s" ]] ; then
        COMPREPLY=( $(compgen -W "${label_opts}" -- ${cur}) )
        return 0
    fi
}

# Savepoint function
savepoint() {
    local arg="${1:---help}"
    local label="${2:-default}"

    if [[ $arg = "-s" ]]; then
        # Save the current path
        pwd > "$saveloc$label.txt"
    elif [[ $arg = "-l" ]]; then
        # Load the saved path
        if [[ -f "$saveloc$label.txt" ]]; then
            labelloc=$(<"$saveloc$label.txt")
            cd $labelloc
        else
            echo "Label '$label' does not exist"
        fi
    elif [[ $arg = "-r" ]]; then
        # Remove a saved path
        if [[ -f "$saveloc$label.txt" ]]; then
            rm "$saveloc$label.txt"
        else
            echo "Label '$label' does not exist"
        fi
    elif [[ $arg = "--list" ]]; then
        # Get all the files in the saves directory
        files=($(ls -1 $saveloc | sed 's/.txt$//g'))
        len=$(ls -1 $saveloc | wc -l)
        # Find the longest file name
        longLen=0
        for (( i=0; i<${len}; i++ ));
        do
            file=${files[$i]}
            if [[ $longLen -lt ${#file} ]]; then
                longLen=${#file}
            fi
        done
        # Print the file names and their contents
        for (( i=0; i<${len}; i++ ));
        do
            conts=$(cat "$saveloc${files[$i]}.txt")
            printf "%${longLen}s : %s\n" "${files[$i]}" "$conts"
        done
    elif [[ $arg = "--help" ]]; then
        echo "Usage: savepoint [flag] [label]"
        echo "-s [label] : Save current path"
        echo "-l [label] : Load saved path"
        echo "-r [label] : Remove label"
        echo "--list     : List saved labels and paths"
    else
        echo "Invalid argument: Run with --help for info"
    fi
}

# Register the completion function
complete -F _savepoint_completions savepoint