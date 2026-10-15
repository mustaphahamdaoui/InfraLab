# InfraLab — Learning Log (week1)

I use this file to record my **real progress**, including things that went wrong. I don't want a separate report for every small mistake. The permanent architecture and setup are in [INFRASTRUCTURE.md](../INFRASTRUCTURE.md); this log is for what I tried, what I understood, and what I want to improve.

**About AI assistance:** I use ChatGPT to explain concepts, review my investigations and help edit documentation. I also asked it to create **controlled, reversible failure scripts and support tickets** so I could practise diagnosis without being given the cause. **I did not write those failure scripts myself.** Their role is to provide exercises; the terminal investigations and screenshots are from my own Ubuntu and Windows machines. I distinguish what I tested from what was only explained to me.

## Week 01 — 9–13 October 2026

**Focus:** Build a working local Linux web service, then secure the connection.

### What I worked on

- Identified the Ubuntu and Windows interfaces and checked local connectivity.
- Enabled a DHCP reservation for Ubuntu in the FRITZ!Box.
- Investigated why Ubuntu could not ping Windows; corrected the scope of an ICMP rule in Windows Firewall.
- Used SSH from Windows to administer Ubuntu and investigated systemd's `ssh.socket` behavior.
- Installed and configured Nginx, a separate virtual host, and a local `infra.test` hostname.
- Diagnosed the difference between **Nginx listening** and **UFW allowing** remote HTTP connections.
- Generated a local TLS certificate, secured its private key, configured HTTPS and added the HTTP-to-HTTPS redirect.
- Transferred the public certificate with SCP and tested HTTPS from Windows using `--cacert`.

### Mistakes that taught me something

- I confused a directory path with a filename while running OpenSSL.
- I temporarily removed the `x` permission from the TLS directory; I learned why directories need traversal permission.
- Nginx rejected certificate directives when I placed them inside `location {}` rather than `server {}`.
- Editing a protected Windows `hosts` file in Notepad didn't initially save to the actual file.
- I learned that HTTP requests to an IP and requests to `infra.test` can select different Nginx sites.

**Result:** A working local website, redirected to HTTPS and verified with a supplied self-signed certificate. The permanent setup and original screenshots are in [INFRASTRUCTURE.md](../INFRASTRUCTURE.md).

## Week 02 — From 14 October 2026

**Focus:** Stop following configuration steps blindly and practise troubleshooting under realistic conditions.

### Why I used failure scripts

After getting the site working, I asked ChatGPT to generate two Bash exercises and present the symptoms as internal support tickets. I wanted to investigate them as if I were the technician on call. The scripts were **AI-generated**, not authored by me; I used them only on my own lab.

The AI-generated scripts belong in [`drills/`](../drills/) for reproducibility once uploaded to the repository. They should be inspected before running with `sudo`. These are training scenarios, **not actual production incidents**.

### Exercise 01 — A running server, but an unreadable page

The first script was designed to remove the file mode permissions from `/var/www/infralab/index.html` using `chmod 000`. This can leave Nginx **active** and listening on port 443 while its worker cannot read the page.

I spent around **40 minutes** checking DNS, ports, the certificate, Nginx status and the server's network configuration. I did not locate the permissions cause during that investigation. I later learned what the script was designed to change.

Some of my tests were misleading:

- `infra.test` did not resolve on Ubuntu because I had originally configured that name in **Windows hosts**, not on Ubuntu.
- An HTTP request to the server IP returned the **default Nginx page**, rather than my named virtual host.
- An HTTPS request to the IP produced a certificate-name mismatch. The certificate contains the DNS name `infra.test`, not the IP.
- `systemctl status nginx` showed a running service. That did not establish that the site content was readable.

![Nginx running while I was investigating](../evidence/18-service-active-during-investigation.png)

**What I learned:** start by reproducing the reported website symptom using the correct hostname and HTTP response. Then inspect file permissions or error logs if the response suggests access is denied. A process being active is only one part of service health.

**Evidence limit:** My screenshots do not independently establish both fault injection and successful manual recovery, so I am not claiming I independently solved this first exercise.

### Exercise 02 — HTTP/HTTPS redirect loop

The next simulated ticket said the internal website no longer loaded correctly. This time I examined several possible causes before finding a meaningful discrepancy inside the Nginx configuration.

```nginx
# HTTP virtual host — expected
return 301 https://$host$request_uri;

# HTTPS virtual host — injected mistake
return 302 http://$host$request_uri;
```

I had one redirect sending HTTP to HTTPS and a second sending HTTPS back to HTTP. The client would keep bouncing between the two. **`nginx -t` can accept this syntax**; the problem is the behavior, not the grammar of the file.

![Original terminal showing the competing redirects](../evidence/19-original-opposing-redirects.png)

I removed the unwanted `return 302` from the HTTPS virtual host. My edited configuration is captured here:

![Original edited configuration after removing the second redirect](../evidence/20-original-https-config-after-edit.png)

I subsequently confirmed in our conversation that the site worked again. **I did not capture a fresh, final end-to-end curl result for this exercise**, so the recovery is reported rather than independently documented in the screenshots.

**What I learned:** a syntactically valid configuration can be logically wrong. Next time I want to inspect response headers and the redirect chain earlier, instead of restarting services or spending too long on unrelated certificate and DNS behavior.

### What I want to improve next

- Reproduce the problem using the actual client's URL before touching the server.
- Distinguish a port listener, a healthy process and a working end-user request.
- Use Nginx access/error logs to support or reject a hypothesis.
- Change one thing at a time, test it, and record the result.
- Eventually build **my own** small Bash or Python health-check tool, rather than only running AI-generated drill scripts.
