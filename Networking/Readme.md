-	Currently we are using start topology

## Switch

- A switch is a networking device that connects multiple devices within a Local Area Network (LAN) and forwards data to the correct device using MAC addresses.

Example: In an office network, a switch connects PCs, printers, and servers, ensuring data is sent only to the intended device instead of broadcasting it to everyone.

Interview one-liner:

"A switch operates at `Layer 2` of the OSI model and uses MAC addresses to efficiently forward data between devices within the same network.


---

## Media Access Control 

A MAC (Media Access Control) Address is a unique physical address assigned to a network device's network interface card (NIC) by the manufacturer.
It is used within a local network (LAN) to identify devices and enable communication between them.

``Example: 00:1A:2B:3C:4D:5E``

Interview one-liner:

A MAC address is a unique hardware identifier used to identify a device on a local network, whereas an IP address identifies a device across networks.

---

## ARP ( Address Resolution Protocol )

ARP (Address Resolution Protocol) Request is used to find the MAC address of a device when its IP address is known.

Example:
•	PC wants to send data to 192.168.1.10.
•	It broadcasts an ARP Request: "Who has IP 192.168.1.10? Tell me your MAC address."
•	The device with that IP replies with its MAC address (ARP Reply).

Interview one-liner:

"ARP is a protocol used in a local network to map an IP address to its corresponding MAC address so devices can communicate at the data-link layer."

---
## Subnetting

Subnetting is the process of dividing a large network into smaller logical networks called subnets.
It helps improve network performance, security, and efficient IP address utilization by reducing unnecessary network traffic.

Example:
Network: 192.168.1.0/24 (256 IPs)

Can be split into two subnets:
•	192.168.1.0/25
•	192.168.1.128/25

Interview one-liner:

Subnetting is used to break a large network into smaller manageable networks to improve performance, security, and IP address management.

---
## Router

A router is a network device that connects different networks and forwards data packets between them using IP addresses.

Example: When your laptop accesses a website on the internet, the router sends your request from your local network to the destination network and returns the response back to you.

Interview one-liner:

"A router operates at Layer 3 (Network Layer) and routes traffic between different networks using IP addresses."


---
