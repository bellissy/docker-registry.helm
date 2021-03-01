#!/usr/bin/env bash

REGISTRY_URL=<REGISTRY_URL>
AUTH_USER=<AUTH_USER>
AUTH_PW=<AUTH_PW>
REPOS=$(curl -s -u $AUTH_USER:$AUTH_PW https://$REGISTRY_URL/v2/_catalog | jq -r .repositories[])

for REPO in $REPOS; do

    LATEST_SHA=$(curl -s -u $AUTH_USER:$AUTH_PW https://$REGISTRY_URL/v2/$REPO/manifests/latest -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' | jq .config.digest)

    TAGS=$(curl -s -u $AUTH_USER:$AUTH_PW  https://$REGISTRY_URL/v2/$REPO/tags/list | jq -r ' .tags | map(select(. != "latest")) | .[]')

    for TAG in $TAGS ; do
        SHA=$(curl -s -u $AUTH_USER:$AUTH_PW https://$REGISTRY_URL/v2/$REPO/manifests/$TAG -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' | jq .config.digest)
        if [ "$SHA" == "$LATEST_SHA" ]; then
            echo "kubectl --insecure-skip-tls-verify set image deployments/$REPO $REPO=$REGISTRY_URL/$REPO:$TAG"
        fi
    done
done
