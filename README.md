# VPN Status Indicator

[![Reddit](https://img.shields.io/badge/Reddit-r%2FPlasmaDrifterProjects-FF4500?style=flat-square&logo=reddit&logoColor=white)](https://reddit.com/r/PlasmaDrifterProjects)

A KDE Plasma panel widget that shows whether your VPN (WireGuard `wg0` / PureVPN) is connected, with a click-to-toggle button.

![vpnindicator](vpnindicator.png)
![vpnindicator](desktop-2.png)

## Features

- Green / red indicator showing live VPN connection status
- Click the widget to connect or disconnect
- Monitors the `wg0` WireGuard interface by default
- Lightweight — uses a simple shell command to check status
- No external dependencies beyond WireGuard tools

## Requirements

- KDE Plasma 6.0+
- WireGuard (`wg-quick`) installed and configured
- Appropriate `sudo` / polkit rules for `wg-quick up/down` without a password prompt

## Installation

```bash
cd ~/.local/share/plasma/plasmoids/
git clone https://github.com/PlasmaDrifter/vpnindicator local.widget.vpnindicator
```

Then right-click your panel → **Add Widgets** → search for **VPN Status Indicator**.

## Configuration

Right-click the widget → **Configure…**

| Option | Description |
|--------|-------------|
| Interface | WireGuard interface name (default: `wg0`) |
| Connected colour | Indicator colour when VPN is up |
| Disconnected colour | Indicator colour when VPN is down |

---

## 💬 Community & Discussions

Got questions, setup ideas, or feedback?

* 🌐 Join our subreddit at [**r/PlasmaDrifterProjects**](https://reddit.com/r/PlasmaDrifterProjects) to discuss updates, get support, and share configurations.

