#!/bin/sh

if [ ! -z "$JFILTER" ]
    then command="exec tshark -i any -l -q -T ek -J \"$JFILTER\" $FILTER"
    echo -e $command
    eval $command

elif [ ! -z "jFILTER" ]
    then command="exec tshark -i any -l -q -T ek -j \"$jFILTER\" $FILTER"
    echo -e $command
    eval $command

    else echo "null" ; exec tshark -i any -l -q -T ek $FILTER
fi
