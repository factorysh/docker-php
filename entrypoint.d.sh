#!/bin/bash

DIR="/entrypoint.d/"

if [ ! -d "$DIR" ]
then
    echo "$DIR directory not found"
    exit
fi

find "$DIR" -type f -executable | while read -r cmd
do
    echo "Executing $cmd"
    bash -c "$cmd"
done

echo "Exiting entrypoint.d.sh"