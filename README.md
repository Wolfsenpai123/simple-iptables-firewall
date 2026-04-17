# Simple Firewall Rules Using iptables

## Project Overview
This project demonstrates how to build a simple host-based firewall on Linux using **iptables**.  
The firewall is designed to control inbound traffic by allowing only necessary services and blocking all other unwanted connections.

This project was developed and tested on **Kali Linux** as a beginner-friendly networking and cybersecurity practice project.  
It focuses on basic firewall rule creation, traffic filtering, and simple validation using Linux and Windows commands.

---

## Objectives
The main objectives of this project are:

- Understand the basic usage of `iptables`
- Create simple and effective firewall rules for a Linux host
- Allow only trusted and necessary inbound traffic
- Block unwanted incoming connections by default
- Practice testing and verifying firewall behavior
- Gain hands-on experience with host-based firewall configuration

---

## Features
This firewall currently supports:

- Allowing loopback traffic
- Allowing established and related connections
- Allowing SSH access from a trusted admin IP
- Allowing HTTP traffic on port 80
- Allowing HTTPS traffic on port 443
- Allowing ICMP echo request (ping)
- Logging dropped packets with rate limiting
- Dropping all other inbound traffic by default

---

## Firewall Rules Implemented

### Default Policies
- `INPUT DROP`
- `FORWARD DROP`
- `OUTPUT ACCEPT`

### Implemented Rules
1. Allow traffic on the loopback interface
2. Allow established and related connections
3. Allow SSH access only from a trusted admin IP
4. Allow HTTP traffic on port 80
5. Allow HTTPS traffic on port 443
6. Allow ICMP echo requests for ping
7. Log unmatched packets before dropping them
8. Drop all remaining inbound traffic

---

## Technologies Used
- **Kali Linux**
- **Bash scripting**
- **iptables**
- **PowerShell** for testing connectivity from Windows
- **ss** command for checking listening services on Kali Linux

---

## Project Structure
```bash
simple-iptables-firewall/
├── firewall.sh
└── README.md
```

---

## Firewall Script
The main firewall logic is stored in `firewall.sh`.

```bash
#!/bin/bash
set -e

IPT=iptables

# Delete old rules
$IPT -F
$IPT -X

# Default policy
$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT ACCEPT

# 1) Loopback
$IPT -A INPUT -i lo -j ACCEPT

# 2) Existing connections
$IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3) SSH from admin IP
$IPT -A INPUT -p tcp -s 192.168.1.10 --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# 4) Web server
$IPT -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
$IPT -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# 5) Ping
$IPT -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# 6) Log before drop
$IPT -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-drop: " --log-level 4

# 7) Drop the rest
$IPT -A INPUT -j DROP
```

---

## How to Run

### 1. Check the script syntax
```bash
bash -n firewall.sh
```

### 2. Give execute permission
```bash
chmod +x firewall.sh
```

### 3. Run the firewall script
```bash
sudo bash firewall.sh
```

### 4. Verify the rules
```bash
sudo iptables -S
sudo iptables -L -n -v --line-numbers
```

---

## Testing

### 1. Check the Kali Linux IP address
```bash
hostname -I
```

or

```bash
ip a
```

### 2. Check if SSH service is listening
```bash
ss -tulpen | grep :22
```

### 3. Test firewall rules on Kali Linux
```bash
sudo iptables -S
sudo iptables -L -n -v --line-numbers
```

### 4. Test connectivity from Windows PowerShell
Replace `<KALI_IP>` with the actual IP address of the Kali machine.

```powershell
Test-NetConnection -ComputerName <KALI_IP> -Port 22
Test-NetConnection -ComputerName <KALI_IP> -Port 80
Test-NetConnection -ComputerName <KALI_IP> -Port 443
Test-NetConnection -ComputerName <KALI_IP> -Port 9999
```

### Expected Results
- **Port 22** should be allowed only if the source IP matches the trusted admin IP in the firewall rule
- **Port 80** should be allowed only if a web service is running
- **Port 443** should be allowed only if a web service is running
- **Port 9999** should be blocked

### Important Testing Notes
- Testing `127.0.0.1` on Windows checks the Windows machine itself, not the Kali VM
- The Windows machine must test the actual Kali IP address
- If the Kali VM uses NAT mode, direct testing may not work as expected without port forwarding
- If no service is listening on port 80 or 443, those ports will still appear closed even if the firewall allows them

---

## Results
After applying the script successfully, the firewall should produce output similar to this:

```bash
-P INPUT DROP
-P FORWARD DROP
-P OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -s 192.168.1.10/32 -p tcp -m tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p tcp -m tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-drop: "
-A INPUT -j DROP
```

This means:
- The default input policy is set to `DROP`
- Only selected inbound traffic is allowed
- Unmatched traffic is logged and then dropped
- The firewall is functioning as a basic host-based packet filter

---

## Limitations
This project still has some limitations:

- It only applies basic IPv4 filtering
- Rules are not automatically persistent after reboot
- No IPv6 filtering is implemented
- No NAT or port forwarding rules are included
- No custom chains are used for advanced organization
- HTTP and HTTPS rules only work meaningfully when the corresponding services are running
- SSH access is limited to one trusted IP and must be updated if the admin machine IP changes

---

## Future Improvements
Possible future improvements include:

- Make firewall rules persistent after reboot
- Add IPv6 protection using `ip6tables`
- Add NAT and forwarding rules
- Create custom chains for better rule organization
- Add more detailed logging and monitoring
- Support multiple trusted admin IP addresses
- Add rules for DNS and other required services
- Compare this implementation with `nftables`

---

## Lessons Learned
During this project, several practical lessons were learned:

- `bash -n` only checks Bash syntax, not whether `iptables` arguments are valid
- Rule order in `iptables` is very important
- Allowing a port in the firewall does not guarantee connectivity unless a service is actually listening
- `127.0.0.1` on Windows refers to the Windows machine, not the Kali virtual machine
- Using `DROP` may cause connection attempts to wait for timeout instead of failing immediately
- Source IP restrictions must match the actual IP of the testing machine

---

## Conclusion
This project helped demonstrate how to configure a simple host-based firewall on Kali Linux using `iptables`.  
It provides a practical example of allowing trusted traffic, blocking unnecessary inbound connections, and validating firewall behavior through basic testing.

Although this project is simple, it establishes a strong foundation for learning more advanced Linux firewall topics such as persistence, NAT, custom chains, IPv6 filtering, and migration to `nftables`.
