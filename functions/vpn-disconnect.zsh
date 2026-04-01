#!/usr/bin/zsh

vpn-disconnect() {
  export INFISICAL_TOKEN=$(infisical login --method=universal-auth --client-id=$INFISICAL_CLIENT_ID --client-secret=$INFISICAL_CLIENT_SECRET --plain --silent)

  set -a
  source <(infisical export --expand --tags=credentials --env="prod" --projectId="$INFISICAL_PROJECT_ID" --silent)
  set +a

  openvpn3 session-manage --config "$SUPERSIM_USERNAME" --disconnect
}

