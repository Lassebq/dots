#!/bin/sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# Inputs:
# 1. "1" if multiple files can be chosen, "0" otherwise.
# 2. "1" if a directory should be chosen, "0" otherwise.
# 3. "0" if opening files was requested, "1" if writing to a file was
#    requested. For example, when uploading files in Firefox, this will be "0".
#    When saving a web page in Firefox, this will be "1".
# 4. If writing to a file, this is recommended path provided by the caller. For
#    example, when saving a web page in Firefox, this will be the recommended
#    path Firefox provided, such as "~/Downloads/webpage_title.html".
#    Note that if the path already exists, we keep appending "_" to it until we
#    get a path that does not exist.
# 5. The output path, to which results should be written.
#
# Output:
# The script should print the selected paths to the output path (argument #5),
# one path per line.
# If nothing is printed, then the operation is assumed to have been canceled.

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

cmd="/usr/bin/lf"
termcmd="${TERMCMD:-/usr/bin/kitty}"

if [ "$save" = "1" ]; then
    args="-config=$HOME/.config/lf/lfchooser_save"
elif [ "$directory" = "1" ]; then
    #args="-config=$HOME/.config/lf/lfchooser -command='set dironly'" # WTF? Discord asks a directory when attaching a file
    args="-config=$HOME/.config/lf/lfchooser"
elif [ "$multiple" = "1" ]; then
    args="-config=$HOME/.config/lf/lfchooser"
else
    args="-config=$HOME/.config/lf/lfchooser"
fi

# cd to parent directory
cd "$(dirname "$path")"

basename="$(basename "$path")"
export basename

"$termcmd" sh -c "$cmd $args > $out"
#if [ "$save" = "1" ] && [ ! -s "$out" ]; then
#    rm "$path"
#fi
