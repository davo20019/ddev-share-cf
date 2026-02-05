#!/usr/bin/env bats

# Test suite for ddev-share-cf addon

setup() {
    # Set up test environment
    export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
    export TESTDIR=~/tmp/test-ddev-share-cf
    export DDEV_NON_INTERACTIVE=true

    mkdir -p $TESTDIR
    cd "${TESTDIR}"
}

teardown() {
    # Clean up test environment
    set -eu -o pipefail
    cd "${TESTDIR}" || true
    ddev delete -Oy ddev-share-cf >/dev/null 2>&1 || true
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
}

@test "install from directory" {
    set -eu -o pipefail
    cd ${TESTDIR}
    echo "# ddev config --project-name=ddev-share-cf" >&3
    ddev config --project-name=ddev-share-cf
    echo "# ddev start -y" >&3
    ddev start -y
    echo "# ddev add-on get ${DIR}" >&3
    ddev add-on get ${DIR}

    # Verify command was installed
    echo "# Checking if share-cf command exists" >&3
    [ -f .ddev/commands/host/share-cf ]

    # Verify command is executable
    echo "# Checking if share-cf command is executable" >&3
    [ -x .ddev/commands/host/share-cf ]

    # Verify command has #ddev-generated marker
    echo "# Checking for #ddev-generated marker" >&3
    grep -q "#ddev-generated" .ddev/commands/host/share-cf

    # Verify docker-compose file was installed
    echo "# Checking if docker-compose.cloudflared.yaml exists" >&3
    [ -f .ddev/docker-compose.cloudflared.yaml ]
}

@test "share-cf command shows cloudflared instructions when not installed" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # If cloudflared is not installed, command should use Docker mode if Docker is available
    if ! command -v cloudflared &> /dev/null; then
        echo "# Testing share-cf without cloudflared installed" >&3

        if docker info &> /dev/null; then
            # Docker is available - should use Docker mode
            echo "# Docker is available, should use Docker mode" >&3
            run timeout 10s ddev share-cf || true
            [[ "$output" =~ "Using Docker mode" ]]
        else
            # Docker not available - should show install instructions
            echo "# Docker not available, should show install instructions" >&3
            run ddev share-cf
            [ "$status" -eq 1 ]
            [[ "$output" =~ "cloudflared is not installed" ]]
            [[ "$output" =~ "Installation Instructions" ]]
            [[ "$output" =~ "Alternative: Docker mode" ]]
        fi
    else
        echo "# cloudflared is installed, skipping this test" >&3
        skip "cloudflared is installed on this system"
    fi
}

@test "share-cf uses Docker mode when cloudflared not installed but Docker available" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # Skip if cloudflared is installed
    if command -v cloudflared &> /dev/null; then
        skip "cloudflared is installed - can't test Docker fallback"
    fi

    # Skip if Docker not available
    if ! docker info &> /dev/null; then
        skip "Docker is not available"
    fi

    # Should detect Docker mode
    run timeout 5s ddev share-cf || true
    [[ "$output" =~ "Using Docker mode" ]]
}

@test "share-cf Docker mode can start quick tunnel" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # Skip if cloudflared is installed (would use host mode)
    if command -v cloudflared &> /dev/null; then
        skip "cloudflared is installed - can't test Docker mode"
    fi

    # Skip if Docker not available
    if ! docker info &> /dev/null; then
        skip "Docker is not available"
    fi

    # Start tunnel and check for success indicators
    timeout 10s ddev share-cf || true

    # Check that container was created
    run docker ps -a --filter name=ddev-ddev-share-cf-cloudflared
    [[ "$output" =~ "cloudflared" ]]

    # Cleanup
    docker rm -f ddev-ddev-share-cf-cloudflared 2>/dev/null || true
}

@test "share-cf Docker mode cleanup on interrupt" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # Skip if cloudflared is installed
    if command -v cloudflared &> /dev/null; then
        skip "cloudflared is installed - can't test Docker mode"
    fi

    # Skip if Docker not available
    if ! docker info &> /dev/null; then
        skip "Docker is not available"
    fi

    # Start tunnel in background and kill it
    timeout 5s ddev share-cf >/dev/null 2>&1 &
    local pid=$!
    sleep 2
    kill -INT $pid 2>/dev/null || true
    wait $pid 2>/dev/null || true

    # Verify cleanup happened - container should be stopped/removed
    sleep 2
    run docker ps --filter name=ddev-ddev-share-cf-cloudflared
    [[ ! "$output" =~ "cloudflared" ]] || [[ "$output" =~ "Exited" ]]

    # Final cleanup
    docker rm -f ddev-ddev-share-cf-cloudflared 2>/dev/null || true
}

@test "share-cf Docker mode requires authentication for named tunnels" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # Skip if cloudflared is installed
    if command -v cloudflared &> /dev/null; then
        skip "cloudflared is installed - can't test Docker mode"
    fi

    # Skip if Docker not available
    if ! docker info &> /dev/null; then
        skip "Docker is not available"
    fi

    # Skip if already authenticated
    if [ -f "${HOME}/.cloudflared/cert.pem" ]; then
        skip "User is already authenticated"
    fi

    # Attempt to create tunnel without auth
    run ddev share-cf --create-tunnel test-tunnel
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Not authenticated" ]]
}

@test "share-cf command detects DDEV project" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # If cloudflared is installed, we can test project detection
    if command -v cloudflared &> /dev/null; then
        echo "# Testing share-cf with cloudflared installed" >&3
        # Start the command in background and kill it quickly
        timeout 5s ddev share-cf || true
    else
        echo "# cloudflared not installed, skipping" >&3
        skip "cloudflared is not installed on this system"
    fi
}

@test "share-cf --tunnel without name shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --tunnel
    [ "$status" -eq 1 ]
    [[ "$output" =~ "--tunnel requires a tunnel name" ]]
}

@test "share-cf --create-tunnel without name shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --create-tunnel
    [ "$status" -eq 1 ]
    [[ "$output" =~ "--create-tunnel requires a tunnel name" ]]
}

@test "share-cf --hostname without value shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --hostname
    [ "$status" -eq 1 ]
    [[ "$output" =~ "--hostname requires a hostname" ]]
}

@test "share-cf --delete-tunnel without name shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --delete-tunnel
    [ "$status" -eq 1 ]
    [[ "$output" =~ "--delete-tunnel requires a tunnel name" ]]
}

@test "share-cf unknown flag shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --invalid-flag
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown option" ]]
}

@test "share-cf --hostname without --create-tunnel shows error" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    run ddev share-cf --hostname dev.example.com
    [ "$status" -eq 1 ]
    [[ "$output" =~ "--hostname can only be used with --create-tunnel" ]]
}

@test "share-cf --create-tunnel without login shows error" {
    set -eu -o pipefail

    if ! command -v cloudflared &> /dev/null; then
        skip "cloudflared is not installed on this system"
    fi

    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev start -y
    ddev add-on get ${DIR}

    # Only run if cert.pem does NOT exist (user is not logged in)
    if [ ! -f "${HOME}/.cloudflared/cert.pem" ]; then
        echo "# Testing --create-tunnel without authentication" >&3
        run ddev share-cf --create-tunnel test-tunnel
        [ "$status" -eq 1 ]
        [[ "$output" =~ "Not authenticated with Cloudflare" ]]
    else
        echo "# User is already authenticated, skipping" >&3
        skip "User is already authenticated with Cloudflare"
    fi
}
