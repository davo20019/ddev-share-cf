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
    # Use ddev delete -Oy to ensure cleanup
    ddev delete -Oy ddev-share-cf >/dev/null 2>&1 || true
    # Ensure the cloudflared service is stopped if it was started in the background
    ddev poweroff --stop-service cloudflared >/dev/null 2>&1 || true
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
}

# --- Test Installation and Executability (Updated start sequence) ---
@test "install from directory" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf >&3
    ddev add-on get ${DIR} >&3
    ddev start -y >&3

    # Verify command was installed
    [ -f .ddev/commands/host/share-cf ]
    # Verify command is executable
    [ -x .ddev/commands/host/share-cf ]
    # Verify command has #ddev-generated marker
    grep -q "#ddev-generated" .ddev/commands/host/share-cf
}

# --- Test Docker Fallback Logic (Updated start sequence) ---
# This simulates a system where the host binary is NOT installed
@test "share-cf falls back to Docker service when cloudflared host binary is missing" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev add-on get ${DIR}
    ddev start -y
    
    # Initialize PATH_SAVE to an empty string to prevent "unbound variable" error
    PATH_SAVE=""

    # Temporarily rename the cloudflared host binary path if it exists
    if command -v cloudflared &> /dev/null; then
        export PATH_SAVE="$PATH"
        # Temporarily clear PATH to simulate missing binary
        export PATH=""
        echo "# cloudflared is installed on the host, simulating missing binary by clearing PATH" >&3
    else
        echo "# cloudflared is not installed on the host, proceeding with test" >&3
    fi

    # Run the command
    # This must succeed (status 0) and use the Docker fallback logic.
    run ddev share-cf

    # Restore PATH only if PATH_SAVE was set (i.e., if cloudflared was found initially)
    if [ -n "$PATH_SAVE" ]; then
        export PATH="$PATH_SAVE"
    fi

    # Check for output confirming the fallback logic and success
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Falling back to Dockerized service" ]]
    [[ "$output" =~ "Cloudflare Tunnel service is active" ]]
    [[ "$output" =~ "Public URL: https://[a-zA-Z0-9-]+\.trycloudflare\.com" ]]

    # Clean up the cloudflared service to ensure teardown works smoothly
    ddev poweroff --stop-service cloudflared >/dev/null 2>&1
}

# --- Test Host Priority Logic (Updated start sequence) ---
# This ensures the Docker fallback is NOT used when the host binary is available
@test "share-cf uses host binary and skips Docker fallback when available" {
    set -eu -o pipefail
    cd ${TESTDIR}
    ddev config --project-name=ddev-share-cf
    ddev add-on get ${DIR}
    ddev start -y

    # If cloudflared is not installed, we can't test the priority logic
    if ! command -v cloudflared &> /dev/null; then
        echo "# cloudflared not installed, skipping test for host priority" >&3
        skip "cloudflared is not installed on this system"
    fi

    echo "# Testing host priority logic" >&3
    # Start the command in the background and kill it quickly (5 seconds)
    # The command should print the host startup message and then block.
    # We use 'timeout' and expect it to be killed (exit code 124)
    run timeout 5s ddev share-cf || true

    # Check for output confirming host usage and skipping of docker fallback
    # The host binary confirmation message:
    [[ "$output" =~ "✅ Host binary 'cloudflared' found" ]]

    # The Docker fallback message MUST NOT be present:
    ! [[ "$output" =~ "Falling back to Dockerized service" ]]
}