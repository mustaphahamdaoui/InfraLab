# INC-001 — ICMP Connectivity Failure Between Linux and Windows

**Status:** Resolved  
**Category:** Networking / Firewall  
**Environment:** Ubuntu Server + Windows Workstation  
**Severity:** Low — Diagnostic connectivity issue

## 1. Problem Description

During an initial network connectivity test in my InfraLab environment, I discovered an asymmetric ICMP communication issue.

<img width="837" height="230" alt="04-ubuntu-to-windows-failure" src="https://github.com/user-attachments/assets/dcb4d910-f121-4c38-99f4-0ad3d276ad26" />

- Windows could successfully ping Ubuntu Server.
- Ubuntu Server could not receive ping replies from Windows.
- Both devices were connected to the same local network.

**Objective:** Investigate the cause and restore ICMP connectivity without unnecessarily weakening firewall security.

## 2. Environment

| Component | Configuration |
|---|---|
| Server | Ubuntu Server |
| Client | Windows |
| Network | Ethernet LAN |
| Subnet | /24 |
| Linux IP | 192.0.2.10 |
| Windows IP | 192.0.2.20 |
| Windows Network Profile | Public |

*All IP addresses are anonymized using documentation-only addresses.*

## 3. Investigation

**Step 1 — Network Interfaces**

Inspected Linux and Windows network configurations to identify their interfaces, IPv4 addresses, and subnet masks.

**Step 2 — Connectivity Tests**

Tested ICMP connectivity in both directions.

| Test | Result |
|---|---|
| Windows → Ubuntu | Success |
| Ubuntu → Windows | Failure |

**Step 3 — Firewall Investigation**

Examined Windows Defender Firewall inbound rules and discovered that the relevant ICMPv4 Echo Request allow rules were disabled.

Created a custom inbound rule, but the initial test still failed.

**Step 4 — Configuration Review**

Reviewed the custom rule's scope and identified an incorrect IP address assignment:

<img width="534" height="745" alt="06-firewall-wrong-scope" src="https://github.com/user-attachments/assets/f5e8c47b-c6b7-4666-a7a9-705ccaf76527" />

- The Ubuntu IP had been configured as a Local IP.
- The rule should have restricted the Remote IP to the Ubuntu Server.

## 4. Root Cause

The Windows firewall configuration did not permit the required inbound ICMPv4 Echo Requests.

The initial custom rule also contained an incorrect Local IP restriction, preventing it from matching the intended traffic.

## 5. Resolution

Corrected the Windows Firewall inbound rule:

| Setting | Value |
|---|---|
| Direction | Inbound |
| Protocol | ICMPv4 |
| ICMP Type | Echo Request |
| Remote IP | Ubuntu Server only |
| Local IP | Any |
| Network Profile | Public |
| Action | Allow |

The firewall remained enabled.

## 6. Verification

After correcting the firewall rule, repeated the connectivity test from Ubuntu to Windows.

**Result:**

<img width="1029" height="293" alt="08-ubuntu-to-windows-success" src="https://github.com/user-attachments/assets/9da56a2f-2e95-4a52-ba19-24cc6e290f44" />

```text
4 packets transmitted
4 received
0% packet loss
```

The test confirmed that ICMP Echo Requests and replies were successfully exchanged.

## 7. Lessons Learned

- Successful ping tests verify ICMP reachability, not the availability of every network service.
- An active network interface does not guarantee full connectivity.
- Local and Remote IP addresses have different meanings in firewall rules.
- Firewall rules should be restricted to the necessary protocol, traffic type, and source.
- Troubleshooting requires testing assumptions and verifying changes.
- A rule being enabled does not guarantee that it matches the intended traffic.

## 8. Preventive Improvement — DHCP Reservation

A DHCP reservation was configured on the FRITZ!Box
to keep the Ubuntu Server's IPv4 address consistent.

<img width="739" height="439" alt="Screenshot 2026-10-10 230242" src="https://github.com/user-attachments/assets/6e8e692c-4295-4489-bc83-6dbfbd347ab2" />

This reduces the risk of the IP-based firewall rule
becoming outdated after an address change.

---

Security & Privacy Notice

Some IP addresses and sensitive network information have been hidden or anonymized for security and privacy reasons. Thank you for your understanding.

**Incident closed — Connectivity verified successfully.**

