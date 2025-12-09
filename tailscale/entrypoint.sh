#!/bin/sh
set -e

# Build TS_EXTRA_ARGS from individual environment variables
EXTRA_ARGS=""

# Add exit node flag
if [ "${TS_ADVERTISE_EXIT_NODE}" = "true" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --advertise-exit-node"
fi

# Add subnet routes
if [ -n "${TS_ADVERTISE_ROUTES}" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --advertise-routes=${TS_ADVERTISE_ROUTES}"
fi

# Add tags
if [ -n "${TS_TAGS}" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --advertise-tags=${TS_TAGS}"
fi

# Add SSH flag
if [ "${TS_SSH}" = "true" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --ssh"
fi

# Add accept routes flag
if [ "${TS_ACCEPT_ROUTES}" = "true" ]; then
    EXTRA_ARGS="${EXTRA_ARGS} --accept-routes"
fi

# Export the built arguments
export TS_EXTRA_ARGS="${EXTRA_ARGS}"

# Execute the original entrypoint
exec /usr/local/bin/containerboot
