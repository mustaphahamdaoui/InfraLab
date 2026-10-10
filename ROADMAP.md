# InfraLab — Engineering Roadmap

## Vision

Build and continuously improve one real infrastructure environment, starting with Linux and networking and progressively expanding into automation, cloud infrastructure, and security.

**Core rule: Never restart from scratch. Every phase must build upon the existing infrastructure.**

## Phase 0 — Foundation & Documentation

**Status: In Progress**

- [x] Set up a physical Ubuntu Server
- [x] Identify network interfaces and IP addresses
- [x] Test connectivity between Ubuntu and Windows
- [x] Troubleshoot an ICMP firewall issue
- [x] Create the InfraLab GitHub repository
- [x] Create the project README
- [ ] Document Incident 001
- [ ] Document the initial network architecture
- [ ] Verify DHCP configuration and configure an IP reservation if needed

**Milestone:** A documented and functioning base environment.

## Phase 1 — Linux & Networking

**Status: Learning / Active Development**

- [ ] Strengthen Linux administration skills
- [ ] Manage processes, services, permissions, and storage
- [ ] Configure and troubleshoot SSH
- [ ] Deploy and manage Nginx
- [ ] Understand TCP/IP, DNS, routing, and firewalls
- [ ] Diagnose network and service failures
- [ ] Document configuration changes and incidents

**Milestone:** Independently manage and troubleshoot the Linux server and its network services.

## Phase 2 — Reliability & Monitoring

**Status: Planned**

- [ ] Centralize important logs
- [ ] Monitor system and service health
- [ ] Configure basic service alerts
- [ ] Implement and test backups
- [ ] Investigate simulated failures
- [ ] Document recovery procedures

**Milestone:** Detect failures, investigate their causes, and recover services reliably.

## Phase 3 — Git & Infrastructure Automation

**Status: Planned**

- [ ] Learn Git workflows
- [ ] Develop Bash automation scripts
- [ ] Learn Python for infrastructure tasks
- [ ] Create a service health-check tool
- [ ] Automate routine administration tasks
- [ ] Add tests and technical documentation

**Milestone:** Develop working automation tools that improve the existing infrastructure.

## Phase 4 — Containers & Deployment

**Status: Planned**

- [ ] Understand container fundamentals
- [ ] Deploy services with Docker
- [ ] Use Docker Compose
- [ ] Manage persistent storage and networking
- [ ] Build a basic CI/CD workflow
- [ ] Troubleshoot deployment failures

**Milestone:** Deploy and maintain containerized services reproducibly.

## Phase 5 — Microsoft Azure & Hybrid Infrastructure

**Status: Planned**

- [ ] Learn Azure fundamentals
- [ ] Configure Azure networking and virtual machines
- [ ] Connect relevant cloud services to InfraLab
- [ ] Understand cloud identity and access management
- [ ] Introduce Infrastructure as Code
- [ ] Implement cloud monitoring and cost controls

**Milestone:** Extend InfraLab into a practical hybrid infrastructure environment.

## Phase 6 — Infrastructure & Cloud Security

**Status: Planned**

- [ ] Strengthen Linux and network security
- [ ] Apply identity and least-privilege principles
- [ ] Implement security monitoring
- [ ] Manage secrets and credentials securely
- [ ] Investigate security incidents
- [ ] Improve infrastructure resilience

**Milestone:** Demonstrate practical infrastructure security and incident investigation skills.

---

## Continuous Engineering Cycle

Every important change follows this workflow:

**Plan → Understand → Implement → Test → Troubleshoot → Document → Improve**

## Project Rules

1. Maintain one continuously evolving infrastructure.
2. Learn technologies when they solve real problems.
3. Understand commands before using them.
4. Document meaningful engineering decisions.
5. Never publish secrets or sensitive infrastructure information.
6. Prioritize practical experience and autonomy.
7. Keep future phases flexible as requirements and skills evolve.

## Career Objective

Develop a demonstrable technical portfolio supporting a 2027 IT internship in infrastructure and automation, with the long-term goal of working in Cloud Engineering and Cloud Security.

This roadmap is a living document. Milestones and priorities may evolve, but the same infrastructure remains the foundation.
