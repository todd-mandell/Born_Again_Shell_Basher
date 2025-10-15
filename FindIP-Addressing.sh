#these strip the IP down
myIP=$(ifconfig eth0 | grep "inet addr:" | cut -d ':' -f 2 | cut -d ' ' -f 1)

#finds the IP and CIDR value of the first interface in the list which is the pipes to head -n 1
mySUBNET=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n 1)
