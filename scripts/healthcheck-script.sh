#!/bin/bash

retries=3
delay_seconds=20

for attempt in $(seq "$retries"); do
  case $SERVER_PORT in
    3000)
      http_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$SERVER_PORT/health-check)
      ;;
    8000)
      http_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$SERVER_PORT/graphql)
      ;;
    8001|8002|8004|8005|8006)
      http_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$SERVER_PORT/api/v1/healthcheck)
      ;;
    *)
      echo "Unsupported SERVER_PORT: $SERVER_PORT"
      exit 1
      ;;
  esac

  if [ "$http_status" -eq 200 ]; then
    echo "The service has been successfully raised"
    exit 0
  else
    echo "Error: Service not available (attempt $attempt/$retries)"
  fi

  if [ "$attempt" -lt "$retries" ]; then
    sleep "$delay_seconds"
  fi
done

echo "Error: Service could not be raised"
exit 1