#!/usr/bin/env bash
# convert all colors in the database from one palette to another
currentcolors=('#29579d' '#5a82b6' '#8aaccf' '#91ceb4' '#97ef99')
newcolors=('#216584' '#69a5c0' '#ffc857' '#63b34f' '#a1d195')

length=${#currentcolors[@]}

for (( i=0; i < length; i++ ))
do
    uppercolor=$( echo "${currentcolors[$i]}" | tr '[:lower:]' '[:upper:]' )
    echo "Replacing ${uppercolor} with ${newcolors[$i]} ..."
    wp search-replace "${uppercolor}" "${newcolors[$i]}"
    
    lowercolor=$( echo "${currentcolors[$i]}" | tr '[:upper:]' '[:lower:]' )
    echo "Replacing ${lowercolor} with ${newcolors[$i]} ..."
    wp search-replace "${lowercolor}" "${newcolors[$i]}"
done

echo "Replacements complete."