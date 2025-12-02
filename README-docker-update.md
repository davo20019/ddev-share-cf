# DDEV Share CF Guide

## Overview

This DDEV addon provides a simple way to share your local DDEV sites
publicly using Cloudflare Tunnel. It works similarly to `ddev share`,
but uses Cloudflare's free tunnel service and runs inside a Docker
container included in your DDEV project.

## Features

- 🚀 **One command:** Run `ddev share-cf` to get a public URL\
- 🆕 **Dockerized:** No external Cloudflare installation required\
- 🆓 **Completely free:** No limits or paid plans\
- 🔒 **Secure:** No need to expose ports\
- ⚡ **Fast:** Powered by Cloudflare's global CDN\
- 🎯 **Zero configuration**\
- 💻 **Cross-platform**

## Requirements

- DDEV **v1.21.0** or higher\
- No Cloudflare account required

## Installation

### 1. Install the addon

Run this inside your project:

    ddev get davo20019/ddev-share-cf

### 2. Service configuration

This installs `.ddev/docker-compose.cloudflared.yaml` containing:

    command: tunnel --url http://web:80

DDEV's web container always exposes port 80 internally.

### 3. Restart DDEV

    ddev restart

## Usage

### Start sharing:

    ddev share-cf

You will receive a public URL like:

    https://randomname.trycloudflare.com

### Stop the tunnel:

    ddev stop cloudflared

### Stop all:

    ddev stop

## Troubleshooting

### Tunnel URL not found

Check logs:

    ddev logs -s cloudflared

Restart web:

    ddev restart web

Verify services:

    ddev ps

### Command not found

Reinstall and restart:

    ddev get davo20019/ddev-share-cf
    ddev restart

### Project not running

    ddev start
    ddev share-cf

## Drupal Multisite

Add this to `sites.php`:

    $sites['random.trycloudflare.com'] = 'mysite';

## WordPress Temporary URL Changes

After running `ddev share-cf`, update URLs:

    ddev wp option update home 'https://random.trycloudflare.com'
    ddev wp option update siteurl 'https://random.trycloudflare.com'

Restore later:

    ddev wp option update home 'https://yoursite.ddev.site'
    ddev wp option update siteurl 'https://yoursite.ddev.site'

## Magento Base URL Updates

    ddev exec bin/magento config:set web/unsecure/base_url 'https://random.trycloudflare.com'
    ddev exec bin/magento config:set web/secure/base_url 'https://random.trycloudflare.com'
