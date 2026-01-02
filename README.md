# 🚀 VPS Bootstrap: The "Cheapskate Enterprise" Edition

> "Why pay for Kubernetes when you have Bash and madness?" © DevOps Wisdom

This repository contains **Infrastructure as Code (IaC)** logic to bootstrap a full-stack environment on a naked $5 VPS.
It features a **self-healing, hook-based pipeline** that manages Docker, WireGuard, Reverse Proxy, and hardened security settings automatically.

## 🏗 Key Features

1.  **Pipeline Orchestrator:** A single `pipeline.sh` script manages the entire lifecycle, ensuring strict execution order.
2.  **Hook System:** Modular architecture (`hooks/`) allows inserting custom logic (notifications, health checks, cleanup) without touching the core pipeline.
3.  **Clean Architecture (Stateless Code):**
    * All persistent data is stored in `./volumes`.
    * Logic and configuration are treated as disposable trash.
    * **Stealth Mode:** A "Self-Destruct" hook wipes all scripts and secrets after deployment, leaving only the running containers and data.
4.  **Security First:**
    * **UFW** managed automatically.
    * **SSH Port Rotation:** Moves SSH to a custom port and closes port 22 automatically.
5.  **Smart templating:** Secrets are injected dynamically into scripts at runtime.

---

## 📂 Project Structure

```text
.
├── docker-compose.yml        # Stack definition (binds ./volumes)
├── .github/workflows
│   └── deploy.yml            # CI/CD: Detects ports, renders templates, triggers pipeline
└── scripts
    ├── pipeline.sh           # THE BOSS (Orchestrator)
    ├── entrypoint.sh         # Migration Logic (Pre/Post phases)
    ├── create_env.sh         # Generates .env from injected secrets
    ├── docker_deploy.sh      # Docker commands
    ├── hooks                 # Lifecycle Hooks
    │   ├── 00_before_all.sh
    │   ├── 99_self_destruct.sh   # Wipes everything EXCEPT ./volumes
    │   └── ...
    └── migrations
        ├── 001_base_setup.sh      # PRE: UFW, Docker
        └── 001_finalize.post.sh   # POST: SSH Port Rotation
```

## 🛠 Requirements

1.  **VPS:** Debian 12 / Ubuntu 22.04+ (Root access).
2.  **DNS:** Configure Cloudflare.
    * `vpn.domain.com` -> **DNS Only** (Grey Cloud)
    * `admin.domain.com` -> **Proxied** (Orange Cloud)

---

## 🔮 Magic Templating System

You don't need to edit the pipeline code to add new secrets into your bash scripts.
Just add them to **GitHub Secrets** and map them in the `env:` section of `deploy.yml` with the prefix `SECRET_`.

**How it works:**
1.  Add `SECRET_MY_VAR: ${{ secrets.MY_VAR }}` to `deploy.yml`.
2.  Use `${MY_VAR}` in any script inside `scripts/`.
3.  The pipeline automatically finds `SECRET_` variables, strips the prefix, and injects the value into the scripts before uploading them to the server.

---

## 🔐 Secrets Configuration

Set these in **Settings -> Secrets and variables -> Actions**:

| Secret | Mapped As (in YAML) | Description |
| :--- | :--- | :--- |
| `SSH_PORT` | `SECRET_SSH_PORT` | **TARGET** Custom Port (e.g., `2807`). The script will configure the server to listen here. |
| `WG_HOST` | `SECRET_WG_HOST` | VPN Domain (e.g., `vpn.s-iman.dev`). |
| `WG_PASSWORD` | `SECRET_WG_PASSWORD` | WireGuard Admin Password. |
| `SSH_HOST` | - | Server IP or Domain. |
| `SSH_USER` | - | SSH Username (`root`). |
| `SSH_KEY` | - | **Private** SSH Key. |
| `SSH_PASSPHRASE` | - | Key Password (if set). |

> **Port Magic:** The CI pipeline automatically detects if the server is listening on `SSH_PORT`. If not, it falls back to port 22. If it connects via 22, the migration script will reconfigure the server to `SSH_PORT` automatically.

---

## ⚙️ The Pipeline Flow

1.  **Detection:** GitHub Action detects the active SSH port.
2.  **Templating:** Secrets are injected into bash scripts.
3.  **Transfer:** Scripts are uploaded to `/opt/siman-stack`.
4.  **Execution (`pipeline.sh`):**
    * **Hook 00:** Start.
    * **Pre-Migration:** Installs Docker, sets up UFW (Allows both 22 and Custom Port).
    * **Env Creation:** Generates `.env`.
    * **Deploy:** Pulls images, starts containers.
    * **Post-Migration:** Updates `sshd_config`, schedules SSH restart, deletes UFW rule for port 22.
    * **Hook 99 (Self Destruct):** Deletes `.env`, `scripts/`, and `docker-compose.yml`.
5.  **Result:** A clean server with running containers and persistent data in `/opt/siman-stack/volumes`.

---

**Author:** Sauyrbay Imangali
**License:** WTFPL (Do What The Fuck You Want To Public License) 🗿