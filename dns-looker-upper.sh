#!/bin/bash

input_file="hosts.txt"
output_file="lookup_results.txt"

> "$output_file"

while IFS= read -r host; do
    [[ -z "$host" || "$host" =~ ^# ]] && continue

    # Get IP from ping (first resolved address)
    ip=$(ping -c1 "$host" 2>/dev/null | awk -F'[()]' '/PING/{print $2}')

    if [[ -z "$ip" ]]; then
        echo "$host NO_IP" >> "$output_file"
        continue
    fi

    # Reverse DNS lookup
    ptr=$(dig -x "$ip" +short)

    if [[ -z "$ptr" ]]; then
        echo "$host $ip NO_PTR" >> "$output_file"
    else
        echo "$host $ip ${ptr%.}" >> "$output_file"
    fi

done < "$input_file"
