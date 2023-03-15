#!/usr/bin/env bash
# convert all matching colors in the WordPress database
# from one palette to another
# note that hex colors are often stored in the
# WP database without the hashtag

# these lists may be any length but the length of both lists must be the same
currentcolors=('29579d' '5a82b6' '8aaccf' '91ceb4' '97ef99')
newcolors=('216584' '69a5c0' 'ffc857' '63b34f' 'a1d195')

# loop through every color in the currentcolors list
length=${#currentcolors[@]}
for (( i=0; i < length; i++ ))
do
    # convert the current color to uppercase and lowercase
    uppercolor=$( echo "${currentcolors[$i]}" | tr '[:lower:]' '[:upper:]' )
    echo "Replacing ${uppercolor} with ${newcolors[$i]} ..."
    wp search-replace "${uppercolor}" "${newcolors[$i]}"
    
    lowercolor=$( echo "${currentcolors[$i]}" | tr '[:upper:]' '[:lower:]' )
    echo "Replacing ${lowercolor} with ${newcolors[$i]} ..."
    wp search-replace "${lowercolor}" "${newcolors[$i]}"
    # note that the search-replace command is case sensitive and will not
    # replace mixed case color values, only all upper or all lower
done

echo "Replacements complete."