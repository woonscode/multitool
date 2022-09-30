#!/bin/bash

pid=$(lsof -ti :$PORT)

if [ ! -z $pid ];
then
kill $pid
fi

cd localenv
source bin/activate

old_path=$(echo $VIRTUAL_ENV)   
new_path=$(echo $PWD)
cd bin
sed -i "s|$old_path|$new_path|g" *
deactivate
source activate
cd ~