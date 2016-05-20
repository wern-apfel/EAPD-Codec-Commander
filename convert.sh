#!/bin/bash

if [ -t 0 ]; then
    echo "usage:"
    echo "  echo -n bytes | ./convert.sh [config|other]"
    echo "or:"
    echo "  pbpaste | ./convert.sh [config|other]"
    exit
fi

declare -a g_configDefault
function add_to_array()
# $1 is node
# $2 is payload
# $3 is shift value
{
    if [[ -z "${g_configDefault[$1]}" ]]; then
        #echo initial set node: $1
        g_configDefault[$1]=0
    fi
    let cur=g_configDefault[$1]
    g_configDefault[$1]=$(( $cur | ($2 << $3) ))
}

declare -a g_unknownVerbs
function add_to_unknown()
# $1 is verb data
{
    count=${#g_unkownVerbs[@]}
    g_unkownVerbs[$count]=$1
}

function shifty()
{
    local result=$(( ($1 >> $2) & ((1 << ($3-$2+1))-1) ))
    echo $result
}

input=$(cat -)
let index=0
while [[ index -lt ${#input} ]]; do
    ch=${input:$index:1}
    if [[ $ch =~ [a-fA-F0-9] ]]; then
        verb=$verb$ch
    fi
    if [[ ${#verb} -eq 8 ]]; then
        let verb_n=0x$verb
        verb=""
        cmd=$(shifty $verb_n 8 19)
        payload=$(shifty $verb_n 0 7)
        node=$(shifty $verb_n 20 26)
        if [[ $cmd -eq 0x71c ]]; then
            #printf "byte0: 0x%x, 0x%02x\n" $node $payload
            add_to_array $node $payload 0
        elif [[ $cmd -eq 0x71d ]]; then
            #printf "byte1: 0x%x, 0x%02x\n" $node $payload
            add_to_array $node $payload 8
        elif [[ $cmd -eq 0x71e ]]; then
            #printf "byte2: 0x%x, 0x%02x\n" $node $payload
            add_to_array $node $payload 16
        elif [[ $cmd -eq 0x71f ]]; then
            #printf "byte3: 0x%x, 0x%02x\n" $node $payload
            add_to_array $node $payload 24
        else
            add_to_unknown $verb_n
        fi
    fi
    ((index++))
done

#echo ${g_configDefault[*]}

if [[ -z "$1" && ${#g_configDefault[@]} -ne 0 ]]; then
    echo Config Data:
fi
if [[ -z "$1" || "$1" == "config" ]]; then
    let i=0
    while [[ $i -lt 256 ]]; do
        if [[ ! -z "${g_configDefault[$i]}" ]]; then
            printf "0x%x, 0x%08x,\n" $i ${g_configDefault[$i]}
        fi
        ((i++))
    done
fi

count=${#g_unkownVerbs[@]}
if [[ -z "$1" && $count -ne 0 ]]; then
    echo Unknown Verbs:
fi
if [[ -z "$1" || "$1" == "other" ]]; then
    let i=0
    while [[ $i -lt $count ]]; do
        new="$(printf "%08x" ${g_unkownVerbs[$i]})"
        if [[ -z "$unknown" ]]; then
            unknown=$new
        else
            unknown="$unknown $new"
        fi
        ((i++))
    done
    if [[ $count -gt 0 ]]; then
        printf "%s\n" "$unknown" | xxd -r -p | xxd -i -c 16
    fi
fi
