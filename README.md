# ddev-share-cf

Share your DDEV sites publicly using Cloudflare Tunnel (free alternative to `ddev share`)

[![version](https://img.shields.io/github/v/release/davo20019/ddev-share-cf)](https://github.com/davo20019/ddev-share-cf/releases)
[![license](https://img.shields.io/github/license/davo20019/ddev-share-cf)](https://github.com/davo20019/ddev-share-cf/blob/main/LICENSE)
![DDEV registry](https://img.shields.io/badge/ddev-get-blue)](https://github.com/ddev/ddev-addon-registry)

## What is this?

This DDEV addon provides a simple command to share your local DDEV sites publicly using [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). It works similarly to `ddev share` (which uses ngrok) but with Cloudflare's free tunnel service.

## Features

- 🚀 **One command** - Just run `ddev share-cf` and get a public URL
- 🆓 **Completely free** - No rate limits, no paid plans needed
- 🔒 **Secure** - No need to open ports on your firewall
- ⚡ **Fast** - Powered by Cloudflare's global network
- 🎯 **Zero configuration** - No account or API tokens required
- 💻 **Cross-platform** - Works on macOS, Linux, and Windows/WSL2

## Requirements

- DDEV v1.21.0 or higher
- `cloudflared` binary installed on your host machine
- macOS, Linux, or Windows/WSL2

## Installation

### 1. Install cloudflared

First, install `cloudflared` on your host machine:

**macOS (Homebrew):**
```bash
brew install cloudflared
```

**Debian/Ubuntu:**
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
```

**RHEL/CentOS/Fedora:**
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.rpm -o cloudflared.rpm
sudo rpm -i cloudflared.rpm
```

**Windows:**
```powershell
winget install --id Cloudflare.cloudflared
```

For other installation methods, see the [Cloudflare documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/).

### 2. Install the DDEV addon

```bash
ddev add-on get davo20019/ddev-share-cf
```

## Usage

From your DDEV project directory, simply run:

```bash
ddev share-cf
```

This will:
1. Check if `cloudflared` is installed (shows installation instructions if not)
2. Start a Cloudflare Tunnel
3. Display a public URL you can share (like `https://randomly-generated.trycloudflare.com`)

Press **Ctrl+C** to stop the tunnel when you're done.

## How It Works

When you run `ddev share-cf`, the addon:

1. Verifies `cloudflared` is installed on your host machine
2. Creates a temporary Cloudflare Tunnel pointing to your DDEV site
3. Routes public traffic through Cloudflare's network to your local DDEV site
4. No Cloudflare account or configuration required

The tunnel URL changes each time you run the command (similar to `ddev share`).

## Comparison with `ddev share`

| Feature | `ddev share` (ngrok) | `ddev share-cf` (Cloudflare) |
|---------|---------------------|------------------------------|
| **Free tier** | 40 connections/min | Unlimited |
| **Speed** | Good | Excellent (Cloudflare CDN) |
| **Account required** | Yes | No |
| **Setup** | Configure token | Zero config |
| **URL persistence** | Changes each time | Changes each time |

## Use Cases

Perfect for:
- 👥 Client demos and previews
- 🪝 Testing webhooks from external services
- 📱 Mobile device testing
- 🤝 Remote team collaboration
- 🎓 Teaching and presentations

## Troubleshooting

### cloudflared not found

If you get an error that `cloudflared` is not installed, the command will automatically detect your operating system and show you the appropriate installation instructions.

You can also manually install cloudflared by following the instructions in the [Installation](#installation) section above.

### Command not found after installation

Make sure the addon is properly installed:
```bash
ddev add-on get davo20019/ddev-share-cf
```

### Permission denied error

The script should be executable, but if you encounter issues:
```bash
chmod +x .ddev/commands/host/share-cf
```

### Project not running

Make sure your DDEV project is running before starting the tunnel:
```bash
ddev start
ddev share-cf
```

### Drupal Multisite Configuration

The addon **automatically detects** Drupal multisite setups by checking for `sites/sites.php`. When detected, it adjusts the tunnel configuration to properly support multisite routing.

To use with **Drupal multisite**:

1. Run `ddev share-cf` - it will detect multisite and display: `ℹ️ Drupal multisite detected`
2. Note the generated URL (e.g., `https://random-name.trycloudflare.com`)
3. Add the mapping to your `web/sites/sites.php`:

```php
<?php
// Map the Cloudflare tunnel URL to your subsite
$sites['random-name.trycloudflare.com'] = 'stage';  // Replace 'stage' with your subsite directory name
```

4. The tunnel will now correctly route to your subsite

**Note:** The tunnel URL changes each time you run the command, so you'll need to update `sites.php` with the new URL for each session.

## Related Resources

- [Blog post: How to Share Your Local WordPress or Drupal Site with Cloudflare Tunnel](https://davidloor.com/blog/share-local-wordpress-drupal-site-cloudflare-tunnel-free)
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [DDEV Documentation](https://ddev.readthedocs.io/)

## Contributing

Contributions, issues, and feature requests are welcome!

- 🐛 [Report a bug](https://github.com/davo20019/ddev-share-cf/issues)
- 💡 [Request a feature](https://github.com/davo20019/ddev-share-cf/issues)
- 🔧 [Submit a PR](https://github.com/davo20019/ddev-share-cf/pulls)

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.

## Maintainer

**David Loor**
- GitHub: [@davo20019](https://github.com/davo20019)
- Website: [davidloor.com](https://davidloor.com)

## Acknowledgments

- Built on [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- Inspired by DDEV's built-in `ddev share` command
- Part of the [DDEV](https://ddev.com) ecosystem
