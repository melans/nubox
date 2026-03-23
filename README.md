# nubox

Disposable Debian machines in 60 seconds. Built for AI agents.

One command creates a full isolated Linux environment with networking, SSH, Tailscale, Claude Code, and OpenClaw — ready to use immediately. Break it? Delete it. Start fresh.

Not a VM. Not Docker. Just [systemd-nspawn](https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html) with batteries included.

## Why

I run AI agents 24/7. They break things. A bad config edit, a wrong dependency, an experimental plugin that crashes everything — and I'm spending an hour fixing what took 5 seconds to break.

nubox gives each agent its own machine. Isolated. Disposable. If it breaks, `nubox --remove it -y && nubox --new it` and you're back in 60 seconds.

## Quick Start

```bash
# Clone
git clone https://github.com/melans/nubox.git
cd nubox

# Configure
cp config.example config
nano config  # set your paths, optionally add Tailscale keys and auth tokens

# Symlink to PATH
sudo ln -sf "$(pwd)/nubox" /usr/local/bin/nubox

# Create your first box
nubox --new mybox

# Start it
nubox --start mybox

# Connect
nubox mybox
```

## Requirements

- Debian/Ubuntu host (or any systemd-based Linux)
- `debootstrap` and `systemd-container` packages
- Root access (sudo)

```bash
sudo apt install debootstrap systemd-container
```

## What Each Box Gets

- Full Debian (minbase) with bash, curl, nano, SSH
- User `mr` with passwordless sudo
- SSH server (enabled, keys copied from host)
- Unlimited bash history with timestamps
- Tailscale auto-join (if configured)
- Claude Code + OpenClaw (if auth tokens configured)
- Private network with NAT internet access
- Its own hostname, accessible via Tailscale from anywhere

## Commands

```
nubox -n,  --new NAME              Create a new box
nubox -n,  --new NAME -t NAME      Create with specific token profile
nubox -n,  --new NAME -b [PATH]    Create and bind directory
nubox NAME                         Connect to box (boot if needed)
nubox -sh, --shell NAME            Shell into running box (no boot)
nubox -on, --start NAME            Boot a stopped box
nubox -off,--stop NAME             Shutdown a running box
nubox -b,  --bind NAME [PATH]      Bind directory to box (restart if running)
nubox -ub, --unbind NAME [PATH]    Unbind directory from box
nubox -ls, --list                  List all boxes with status
nubox -rm, --remove NAME [-y]      Remove box + Tailscale cleanup
nubox -t,  --token                 List token profiles
nubox -t,  --token NAME            Show token (masked)
nubox -t,  --token NAME TOKEN      Add/update token
nubox -h,  --help                  Show help
```

## Configuration

Copy `config.example` to `config` and edit:

```bash
# Directories — where boxes live
BOXES_DIR="/mnt/fast/nubox/BOXES"
SYSTEM_DIR="/mnt/fast/nubox/SYSTEM"

# Tailscale (optional)
TS_AUTH_KEY="tskey-auth-..."    # boxes auto-join your Tailscale network
TS_API_KEY="tskey-api-..."      # cleanup on remove

# Auth tokens (optional) — pre-configures Claude Code + OpenClaw
TOKEN_personal="sk-ant-oat01-..."
TOKEN_work="sk-ant-oat01-..."
DEFAULT_TOKEN="personal"
```

### Token Profiles

Each token profile configures both Claude Code and OpenClaw in new boxes. Manage them with:

```bash
nubox --token                        # list all profiles
nubox --token personal               # show (masked)
nubox --token work sk-ant-oat01-...  # add/update
```

Use during creation:

```bash
nubox --new myagent -t work          # uses 'work' token
nubox --new myagent                  # uses default token
```

## Bind Mounts

Share host directories with boxes:

```bash
nubox --bind mybox /path/to/project  # bind specific path
nubox --bind mybox                   # bind current directory
nubox --unbind mybox /path/to/project
```

Binds auto-restart the box if it's running. The path is the same inside the box.

## How It Works

nubox uses `systemd-nspawn` — Linux's built-in container runtime. No daemon, no images, no layers. Each box is just a directory with a Debian filesystem.

- **Networking**: private veth pair with DHCP + NAT (via systemd-networkd)
- **Isolation**: separate PID, network, and mount namespaces
- **Capabilities**: full (needed for Tailscale + Claude Code)
- **Storage**: plain directories on your filesystem

Boxes are just files until started. Create 10 boxes — zero resource usage until you boot them.

## Architecture Example

```
Host (Debian/Ubuntu)
├── nubox/BOXES/
│   ├── agent-1/     # AI agent for project A
│   ├── agent-2/     # AI agent for project B
│   ├── dev/         # development sandbox
│   └── test/        # throwaway testing
└── Each box has:
    ├── Own network (10.0.100.x)
    ├── Own Tailscale identity
    ├── Own SSH server
    ├── Claude Code + OpenClaw
    └── Full Debian userland
```

## Proxy / Residential IP

Route any box through a home machine for residential IP:

```bash
# On the home machine:
tailscale set --advertise-exit-node

# Inside the box:
tailscale set --exit-node=home-machine
```

## License

MIT
