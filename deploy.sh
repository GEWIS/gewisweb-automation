#!/bin/sh
echo "Logging into Portainer"
STACK_ID=62
JWT=$(curl -X POST https://docker.gewis.nl/api/auth -d '{"username": '"${USERNAME}"', "password": '"${PASSWORD}"'}' | jq -r .jwt)
echo "Stopping stack"
curl -X POST "https://docker.gewis.nl/api/stack/${STACK_ID}/stop" -H "Authorization: Bearer ${JWT}"
echo "Logging out of Portainer"
curl -X POST https://docker.gewis.nl/api/auth/logout -H "Authorization: Bearer ${JWT}"
