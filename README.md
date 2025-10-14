# ddev-share-cf

Share your DDEV sites publicly using Cloudflare Tunnel (free alternative to `ddev share`)

[![version](https://img.shields.io/github/v/release/davo20019/ddev-share-cf)](https://github.com/davo20019/ddev-share-cf/releases)
[![license](https://img.shields.io/github/license/davo20019/ddev-share-cf)](https://github.com/davo20019/ddev-share-cf/blob/main/LICENSE)

## What is this?

This DDEV addon provides a simple command to share your local DDEV sites publicly using [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/). It works similarly to `ddev share` (which uses ngrok) but with Cloudflare's free tunnel service.

## Features

- 🚀 **One command** - Just run `ddev share-cf` and get a public URL
- 🆓 **Completely free** - No rate limits, no paid plans needed
- 🔒 **Secure** - No need to open ports on your firewall
- ⚡ **Fast** - Powered by Cloudflare's global network
- 🎯 **Zero configuration** - No account or API tokens required
- 🔄 **Auto-install** - Automatically installs `cloudflared` if not present

## Requirements

- DDEV v1.21.0 or higher
- macOS, Linux, or WSL2

## Installation

```bash
ddev add-on get davo20019/ddev-share-cf
```

## Usage

From your DDEV project directory, simply run:

```bash
ddev share-cf
```

This will:
1. Install `cloudflared` if it's not already installed
2. Start a Cloudflare Tunnel
3. Display a public URL you can share (like `https://randomly-generated.trycloudflare.com`)

Press **Ctrl+C** to stop the tunnel when you're done.

## How It Works

When you run `ddev share-cf`, the addon:

1. Checks if `cloudflared` is installed (installs it automatically if needed)
2. Creates a temporary Cloudflare Tunnel
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

### Command not found after installation

Restart your terminal or run:
```bash
ddev restart
```

### Permission denied error

The script should be executable, but if you encounter issues:
```bash
chmod +x .ddev/commands/host/share-cf
```

### Cloudflared installation fails

You can manually install cloudflared:

**macOS (Homebrew):**
```bash
brew install cloudflared
```

**Linux:**
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
sudo mv cloudflared /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared
```

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

MIT License - see [LICENSE](LICENSE) file for details.

## Maintainer

**David Loor**
- GitHub: [@davo20019](https://github.com/davo20019)
- Website: [davidloor.com](https://davidloor.com)

## Acknowledgments

- Built on [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- Inspired by DDEV's built-in `ddev share` command
- Part of the [DDEV](https://ddev.com) ecosystem
