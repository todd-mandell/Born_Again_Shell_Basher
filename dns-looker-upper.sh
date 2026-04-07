#!/bin/bash

input_file="hosts.txt"
output_file="lookup_results.txt"

> "$output_file"

is_ip() {
    [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

while IFS= read -r raw; do
    # Clean input
    host=$(echo "$raw" | tr -d '\r' | xargs)

    [[ -z "$host" || "$host" =~ ^# ]] && continue

    if is_ip "$host"; then
        # Reverse lookup IP → PTR
        ptr=$(dig -x "$host" +short | sed 's/\.$//')

        if [[ -z "$ptr" ]]; then
            line="$host NO_PTR NO_IP"
            echo "$line" | tee -a "$output_file"
            continue
        fi

        # Forward lookup PTR → IP
        ip2=$(dig +short "$ptr" | head -n1)

        if [[ -z "$ip2" ]]; then
            line="$host $ptr NO_IP"
        else
            line="$host $ptr $ip2"
        fi

        echo "$line" | tee -a "$output_file"

    else
        # Forward lookup FQDN → IP
        ip=$(dig +short "$host" | head -n1)

        if [[ -z "$ip" ]]; then
            line="$host NO_IP"
            echo "$line" | tee -a "$output_file"
            continue
        fi

        # Reverse lookup IP → PTR
        ptr=$(dig -x "$ip" +short | sed 's/\.$//')

        if [[ -z "$ptr" ]]; then
            line="$host $ip NO_PTR"
        else
            line="$host $ip $ptr"
        fi

        echo "$line" | tee -a "$output_file"
    fi

done < "$input_file"
