#!/bin/bash

get_registration_token() {
    echo "Requesting registration token..."
    local api_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOSITORY}/actions/runners/registration-token"
    local token_response=$(curl --silent --request POST --header "Authorization: token ${GITHUB_PAT}" --header "Accept: application/vnd.github.v3+json" "${api_url}")
    REG_TOKEN=$(echo "${token_response}" | jq .token --raw-output)

    if [ -z "$REG_TOKEN" ] || [ "$REG_TOKEN" == "null" ]; then
        echo "Error: Failed to get registration token. Response:"
        echo "${token_response}"
        exit 1
    fi
}

configure_runner() {
    ./config.sh \
        --url "https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY}" \
        --token "${REG_TOKEN}" \
        --name "${RUNNER_NAME:-$(hostname)}" \
        --labels "${RUNNER_LABELS:-self-hosted,linux,x64}" \
        --work "_work" \
        --unattended \
        --replace
}

cleanup() {
    echo "Caught signal. Removing runner..."
    ./config.sh remove --token "${REG_TOKEN}"
    exit 0
}

if [ -f ".runner" ]; then
    echo "Runner already configured. Starting..."
else
    echo "Runner not configured. Starting registration process..."
    get_registration_token
    configure_runner
fi

trap cleanup SIGINT SIGQUIT SIGTERM

./run.sh & wait $!
