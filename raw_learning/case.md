# Test Progressive Assistant — Network (Generation 26-1)

## Case Brief: ComMX

ComMX is a simple, real-time lobby chatting applicatilopers. As the project grew beyond its initial scope, the team realized they needed a robust infrastructure to handle persistent messaging and strict security requirements. The development team is seeking help from a skilled DevOps Engineer to launch the application properly, with the goal of achieving high availability and a production-ready environment.

**Role:** As the appointed DevOps Engineer, the task is to bring together everything learned to deploy the ComMX application securely.

**Stack:**
- Frontend: React
- Backend: NestJS
- Real-time layer: Redis adapter, used to manage persistent WebSocket connections

**Objective:** Prepare the deployment environment and ensure the system is completely locked down, strictly mandating encrypted protocols (`HTTPS` and `WSS`) for all communications to operate safely and efficiently in the real world.

---

## General Requirements

- Do not change any configurations at **Ether 1** of the physical MikroTik router.
- All team members are responsible for restoring any damage or error.
- Do not communicate or collaborate with other teams unless explicitly permitted.
- Do not change other teams' servers or configuration. Any violation of this rule results in a penalty for the team.
- Each participant is obligated to understand every command run and what it does; failure to do this results in not receiving full points for the corresponding scoring component.
- Configure virtual machines and the router based on the given requirements.
- IP addresses assigned to servers must be configured manually via **static IP**.
- If unsure about any requirement, ask the Astdev or Casemaker for clarification.

---

## Internet

- Give internet access to the 5 PCs provided.
- Because of limited public IPs, encapsulate all Servers and VMs using **NAT** on the provided MikroTik router.
- Make sure the PC and VM can access the internet.

---

## DNS

- Configure DNS forwarding to `10.22.64.21` and `10.22.64.22`.
- Create internal DNS records for the following applications:

| Domain | Points to |
|---|---|
| `ComMX.local.com` | ComMX Web Application |
| `Grafana.local.com` | Grafana monitoring dashboard |

---

## DHCP

- Set up a DHCP Server and its IP pool.
- After setting up DHCP, configure at least **2 PCs** to obtain an IP from the DHCP Server's IP pool.

---

## Wireless

- Set up a wireless connection with the following credentials:
  - **SSID:** `Wi-Fi-[MikroTik box number]`
- Set up a default hotspot user:
  - **Username:** `hotspot`
  - **Password:** `spothot`
- Add every team member as a user, using the following format:
  - **Username:** `[INITIAL]`
  - **Password:** `[GENERATION]`
- The IP obtained by a device connecting via wireless must come from an IP pool.

---

## Firewall

- Create a firewall filter rule that blocks any device making more than **5 login attempts per minute** to the MikroTik.
- Configure a NAT rule to filter outgoing packets with action: `masquerade`.

---

## VPN

- Set up an **L2TP/IPSec** server.
- VPN user credentials:
  - **Username:** `network26-1`
  - **Password:** `tpanetgampang`
- IPSec secret:
  - `duaenamsatu`
- Ensure the user connected via this VPN can also access the internet.

---

## Queues

- Set up Queues for each subnet in the network.
- Create a queue to enable/disable **high bandwidth** access to the internet.
  - **High Bandwidth specification:**
    - Upload Max Limit: `50M`
    - Download Max Limit: `100M`
- Create a queue to enable/disable internet access for each PC.
  - **Normal Internet specification:**
    - Upload Max Limit: `10M`
    - Download Max Limit: `10M`

---

## Virtualization

- Use **Proxmox** to install all VMs needed for the Kubernetes nodes inside the Virtualization VM.
  - Proxmox credentials:
    - **Username:** `Group-[group-number]`
    - **Password:** `tpanetkelar`
- Configure virtualization so Proxmox performance does not falter.
- Join **3 or 4 Proxmox Nodes** into 1 data center, to ease the burden of many VMs running on a single PC.
- Recommended hardware settings (optional guidance — values can be higher or lower depending on the number of Proxmox nodes):
  - RAM: `6–12 GB`
  - Storage: `55–60 GB`
- Ensure each VM is backed up every night at **12:00 PM**.
- Enable the migration feature: if a Proxmox node goes down, every node hosted on it must be migrated to its neighboring node within the same data center.

---

## Automation

- Create a **Terraform** configuration to automate bulk provisioning of all Virtual Machines.
  - Use variable definitions and environment variables for sensitive data.
  - Ensure the Terraform state is managed correctly to prevent data loss during updates.
- Develop an **Ansible Playbook** structured using **Roles** to ensure modularity and reusability.
  - Ensure all tasks are **idempotent** — the playbook can be run multiple times without causing errors or unintended changes.
- The playbook must automatically provision and configure the following components:
  - Core System Setup
  - Load Balancer Setup
  - Cluster Setup
  - Monitoring and Alerting
  - CI/CD Integration

---

## App Description

- The application uses a Redis adapter to manage WebSocket sessions and maintain persistent connections.
- The application requires a secure, encrypted environment to function: both directions of communication are obligated to run over secure protocols.

---

## Repository Management

- Project to deploy: `https://github.com/KenHoH/ComMX.git`
- Fork the repository to a personal GitHub account.
- Create branches for dev and production:
  - **Dev-branch:** where developers can develop the app
  - **Main-branch:** the code that end users are using
- All changes must be committed and pushed to the repository.

---

## Kubernetes Cluster

**Node hardware — recommended (optional guidance; control planes need more resources):**
- RAM: `3–5 GB`
- Storage: `25–30 GB`
- Core: `1–3`
- Use a Cloud-init drive with blank values.

**Requirements:**
- Write manifests following best practices to ensure security and reliability.
- Free choice of CSI and CRI to support the cluster, e.g.:
  - **CRI:** dockerd, containerd, CRI-O
  - **CSI:** Longhorn, OpenEBS, Ceph
- **CNI:** must use **Cilium**.
- Cluster topology must include at least:
  - 3 Nodes as Control Planes
  - 3 Nodes as Workers
- The cluster configuration must achieve **High Availability (HA)**:
  - The cluster must remain operational if any single node fails.
  - Workloads must automatically scale to handle high traffic volume.
  - Resources must be balanced effectively across available nodes.
- **Load Balancing:**
  - Because a lot of traffic may hit the web app, create a load balancer with a floating IP as the gateway for traffic.
  - **Keepalived** may be used for the floating IP.
  - **HAProxy** may be used as the load balancer.
- Implement **MetalLB** to handle Layer 2 traffic entry into the Kubernetes cluster.
- Implement **Kyverno** to manage cluster policies. Kyverno must enforce:
  - **Disallow Latest Tag:** prevent pods from pulling images using the `latest` tag.
  - **Disallow Default Namespace:** restrict creation of resources in the `default` namespace.
  - **Require Labels:** ensure all resources include mandatory metadata labels.
- To expose the Kubernetes cluster externally, use **MetalLB** and **Gateway API** to route external traffic to internal services.
- Implement a deployment strategy, with a documented, strong justification for why that strategy was chosen.

---

## CI/CD Pipeline

- Implement a pipeline that automates the process from a repository update until it is reflected in the Kubernetes Deployment.
  - The pipeline automates new updates to the cluster whenever an update is detected on the **Main-Branch**.
- Required tooling:
  - **CI/CD:** Local Forgejo
  - **CD tool:** ArgoCD
  - **Private Docker Registry**
- Configure a Private Docker Registry to store application container images.
  - **Username:** `Group-[X]`
  - **Password:** `kelargacor`
- The workflow must include at least the following sequential stages:

  **Continuous Integration (CI):**
  1. **Vulnerabilities:** scan source code and dependencies (GitLeaks, Semgrep, Trivy).
  2. **Containerize:** build the Docker image from source.
  3. **Image Scanning:** scan the built image (Trivy).
  4. **Publish:** push the Docker image to the Private Registry.
  5. **IaC Scan:** scan Kubernetes manifests/Helm charts for misconfigurations (Checkov).
  6. **Update Manifests:** the pipeline commits the new Docker image tag (e.g., `v1.2.3`) back into the Forgejo repository holding the Kubernetes deployment files.

  **Continuous Deployment (CD):**
  1. **Detect:** ArgoCD detects the new commit.
  2. **Sync:** ArgoCD automatically pulls the changes and updates the Kubernetes Deployment to match the desired state.

---

## Monitoring and Alerting

- Implement monitoring and alerting for the Kubernetes cluster using **Grafana** and **Prometheus**.
  - Member access credentials for Grafana and Prometheus:
    - **Username:** `tormonitor`
    - **Password:** `monitor`
  - Metrics to monitor:
    - Condition of each node's CPU and RAM
    - Condition of each Pod
  - Alerts must be created for:
    - CPU/RAM utilization of any node reaching **90%**
    - Any pod errors
  - Generated alerts must be sent via email to each member's email address.

---

## Documentation

- Full documentation of all deployment steps is required, covering:
  - Setting up Proxmox
  - Automation with Terraform and Ansible
  - Configuring the Application
  - Deploying and managing the Kubernetes cluster
  - Deploying Monitoring and Alerting
  - Implementing CI/CD
- Documentation may be written as plain `.txt` or as a Word document.
- Documentation must include all commands used, as well as all reserved IP addresses for every host.
- Documentation must be clear, complete, and easily understandable so that anyone can replicate the entire setup.

---

## Notes

- Every command run must be understood by the participant; failing to explain a command may result in reduced points (not achieving full marks).
- Follow basic security procedures:
  - Do not push `.env` files to GitHub.
  - Do not push any credentials to GitHub.
  - For handling env files, any method may be used as long as it isn't pushed to the repository (e.g., HashiCorp Vault).
- Due to performance restrictions on the provided PCs, Ansible does not need to be run 100% of the time — only when a VM is turned off due to RAM/memory issues (as an exception).

**Good Luck**