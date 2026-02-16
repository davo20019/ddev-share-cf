cd /media/kwame-boateng/175670467C15B3F4/Open-Source/ddev-share-cf

# Install the addon to a test DDEV project
cd /path/to/test-ddev-project
ddev add-on get /media/kwame-boateng/175670467C15B3F4/Open-Source/ddev-share-cf

# Test quick tunnel
ddev share-cf  # Should show "Using Docker mode"

# Test named tunnel (requires login first)
ddev share-cf --login
ddev share-cf --create-tunnel test --hostname test.example.com
ddev share-cf --tunnel test

## Description
This PR adds automatic Docker fallback support when `cloudflared` is not installed on the host machine. This is an **incremental enhancement** that preserves all existing functionality while removing the hard requirement for a host-installed `cloudflared` binary.

When `cloudflared` is not found on the host, the addon automatically uses the official `cloudflare/cloudflared` Docker image to run tunnels. Users with `cloudflared` already installed see no changes - the addon continues to use host mode.

Fixes # (issue)

## Type of change
Please delete options that are not relevant.

- [ ] Bug fix (non-breaking change which fixes an issue)
- [x] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
Please describe the tests that you ran to verify your changes.

- [ ] Test A
- [ ] Test B

## Checklist:
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes
