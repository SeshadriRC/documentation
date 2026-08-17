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

<img width="1251" height="621" alt="image" src="https://github.com/user-attachments/assets/f7cd3d56-5dcf-4cd3-803f-b440d19d5ac7" />

<img width="1261" height="629" alt="image" src="https://github.com/user-attachments/assets/0fcc39aa-6d5c-4d49-a073-e361944577c0" />


- HR department wants to connect with finance department which is in the other network.
- If device is in the same network, then communication will happen using switch, but in this case its a different network, So computer A will send the data to router IP address.
- So how will computer A will know the IP address of router ( default gateway ). it didn't know. so whenever new device is adding to the network, Network admin will manually configure the IP address, default gateway IP , DNS server IP to the computer.
- So to avoid this manual configuration, we have made DHCP , so that automatically configuration will be done.

## DHCP

**DHCP (Dynamic Host Configuration Protocol)**

**Interview Answer (2 lines):**

 DHCP is a network protocol that automatically assigns IP addresses and other network settings (Subnet Mask, Gateway, DNS) to devices in a network. It eliminates the need for manual IP configuration.

**How DHCP Works**

When a device joins a network, DHCP follows the DORA process:

Discover – Client broadcasts a request for an IP address.

Offer – DHCP server offers an available IP address.

Request – Client requests the offered IP address.

Acknowledge – DHCP server confirms and assigns the IP address.

Information Provided by DHCP

- IP Address (e.g., 192.168.1.10)
- Subnet Mask
- Default Gateway
- DNS Server
- Lease Time

Real-Time Example

When you connect your laptop to a Wi-Fi network, the router's DHCP service automatically assigns an IP address such as 192.168.1.100. Without DHCP, you would have to manually configure the IP settings on every device.

Common Ports
UDP 67 → DHCP Server
UDP 68 → DHCP Client

Interview Follow-up Question

Q: What happens if DHCP server is unavailable?

 A: The client cannot obtain a valid IP address. In many systems, it may assign itself an APIPA address (169.254.x.x) for limited local network communication.

- Below details received from the DHCP

<img width="1156" height="428" alt="image" src="https://github.com/user-attachments/assets/696aae01-eafd-43d6-a64c-e5d2cdda36e2" />

---

## Routing table

<img width="1221" height="680" alt="image" src="https://github.com/user-attachments/assets/8ddf78b8-121d-4e40-8215-374ebfe54539" />

A routing table is a list of network routes maintained by a router or operating system to determine where to forward network packets. It helps decide the best path to reach a destination IP address.

**Routing Table Contains**

Destination Network → Target network (e.g., 192.168.1.0/24)

Subnet Mask/Prefix → Network size

Gateway (Next Hop) → Where to send the packet next

Interface → Network adapter used

Metric → Cost of the route (lower is preferred)

<img width="1102" height="268" alt="image" src="https://github.com/user-attachments/assets/824f6eeb-5996-42c2-9d7a-25e2e1a2651f" />

Explanation

Suppose your laptop wants to access 8.8.8.8:

It checks the routing table.

- No specific route exists for 8.8.8.8.
- It uses the default route (0.0.0.0/0).
- Packet is sent to gateway 192.168.1.1.

Q: What is the default route?

 A: The default route (0.0.0.0/0) is used when no more specific route exists in the routing table. It usually points to the network gateway/router.

---

## Internet

- Internet is a network of networks.
  
<img width="1145" height="590" alt="image" src="https://github.com/user-attachments/assets/eda66d86-0fee-4d2c-bf96-0ff4dba2280f" />

## DNS
<img width="1226" height="594" alt="image" src="https://github.com/user-attachments/assets/b04ddcee-0462-4160-beaf-3af48169fb44" />


