# InfraLab — Learning Log (Week 03)

**20–22 October 2026 · Bash fundamentals and a first health check**

This week I built my first Bash script for the existing InfraLab server. The goal was to turn manual checks into a small, read-only diagnostic — not to build a production monitoring system.

## What I built

- Created `health-check.sh` to check whether **Nginx is active** with `systemctl`.
- Added an **HTTPS request with `curl`** and a locally trusted self-signed certificate.
- Used variables, command substitution (`$(...)`), `if/else`, `&&`, and `exit 0` / `exit 1`.
- Added an initial `ss`-based view of listening ports when an alert is raised.

The script is in [`scripts/health-check.sh`](../../scripts/health-check.sh). The committed version is a **lightly cleaned-up reconstruction** of the screenshot-based script (`-fsS` to hide the progress meter and `$HOME` instead of a machine-specific certificate path). That publishing copy has **not been re-tested** in this record; the evidence below is from my own terminal tests of the learning version.

## What I tested

| Test | Observation |
| --- | --- |
| Nginx active | The first version printed `OK`. |
| Nginx intentionally stopped | `systemctl is-active nginx` returned `inactive`; the script displayed `Alert!`. Nginx was started again and confirmed `active`. |
| HTTPS reachable | `curl` returned `HTTP/1.1 200 OK` with certificate verification. |
| Nonexistent URL (`404`) | `curl -f` reported error 22 / HTTP 404; the script displayed `Alert!` and returned exit code `1`. Ports 80 and 443 were still listening. |
| Original URL restored | The script returned to displaying `OK`. |

The HTTP 404 was a **deliberate test using a nonexistent path**, not an unexpected production incident.

## Evidence

**First Bash version:** service state, an `if/else` decision, basic port check and exit codes.

![First health-check script](../evidence/01_first_bash_script.png)

**Service stopped:** the script detects the inactive Nginx service.

![Nginx stopped and alert displayed](../evidence/02_nginx_inactive_alert.png)

**HTTPS response:** the site returns HTTP 200 when requested with certificate verification.

![HTTPS 200 response](../evidence/03_https_200_response.png)

**HTTP 404 test:** the script flags a failure even while ports 80/443 are listening, and returns `1`.

![HTTP 404 detected by script](../evidence/04_http_404_alert.png)

**Recovery:** after restoring the normal URL, the script displays `OK` again.

![Health check after restoring original URL](../evidence/05_url_restored_ok.png)

## Lessons and limits

- An **active service** does not guarantee that the **web application responds as expected**.
- A `curl` **exit code** (such as `0` or `22`) is different from an **HTTP status** (such as `200` or `404`).
- `curl -f` catches typical HTTP 4xx/5xx failures, but **does not enforce exactly HTTP 200**. A redirect can still count as success.
- The current port filter (`grep -E '80|443'`) is **not precise**: it could also match other port numbers. This will be improved later.
- This is a **local check on the server**, not proof that clients on the network can reach it. I also tested HTTPS from Windows separately.
- The script reports an issue; it **does not automatically restart services or change firewall rules**.

## Next

Practice small Bash functions and loops, improve diagnostics when necessary, and move toward Python scripting and scheduled checks.

I wrote, edited and executed the learning script myself on Ubuntu. The screenshots are from my lab; no external outage or independent production incident is claimed.
