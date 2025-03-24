#!/bin/sh
# interval and timeout are in seconds
interval=5
timeout=600
#
resourcename=headlamp
counter=0
# need to remove the default "set -e" to allow commands to return nonzero exit codes without the script failing
set +e

while true; do
   echo "Checking $resourcename status..."
   echo "Waiting for $interval seconds..."
   sleep $interval
   
   if [[ "$(kubectl -n "$resourcename" get deployment "$resourcename" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)" == "True" ]]; then
      echo "$resourcename custom resource creation finished"
      break
   fi

   echo "Waiting for $interval seconds..."
   sleep $interval

   counter=$((counter + 1))
   if ((counter * interval >= timeout)); then
      echo "$resourcename timeout after $timeout seconds, running describe..." 1>&2
      kubectl describe deploy "$resourcename" -n "$resourcename" 1>&2
      exit 1
   fi
done

set -e
