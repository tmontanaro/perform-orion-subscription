#!/bin/bash
# this script works only if in the system the following packages are installed:
#- curl
#- jq


idm_url="https://<urlOfTheIdm>:<port>"
orion_url="https://<urlOfTheIdm>:<port>/<path>"

subscriber_url="<urlOfTheSubscriber>"
#possible entity Ids:
# * Company
# * Farm
# * Building
# * Compartment
# * Pen
# * Pig
entityIdToBeSubscribed="Compartment"

# possible entity Types:
# * Company
# * Farm
# * Building
# * Compartment
# * Pen
# * Pig
entityTypeToBeSubscribed="Pig"

# Define last variables
usernameIdm="emailUsedAsUsername"
passwordIdm="pass"
# if the genericId is set to true the "entityTypeToBeSubscribed" parameter can be left empty
genericId=true
#if the throttling param is set to true it will set to 1, otherwise it will not set
throttling=false

CLIENT_ID="<clientIdTakenFromIdm>"
CLIENT_SECRET="<clientSecretTakenFromIdm>"

function get_token () {
    # Client ID and client Secret from the Identity Manager

    # Generate the Authentication Header for the request
    AUTH_HEADER="$(echo -n ${CLIENT_ID}:${CLIENT_SECRET} | base64 -w 0)"
    
    # Create the request
	REQUEST="curl -s --location --request POST '${idm_url}/oauth2/token' \
    --header 'Authorization: Basic ${AUTH_HEADER}' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'username=${username}' \
    --data-urlencode 'password=${password}' \
    --data-urlencode 'grant_type=password'
"

	result=$(eval ${REQUEST})
    access_token=$(echo "$result" | jq '.access_token')
    echo $access_token
}

jsonRequestIdPatternGeneric="{\
      \"description\": \"A subscription to get info about ${entityTypeToBeSubscribed}\",\
      \"subject\": {\
        \"entities\": [\
          {\
            \"idPattern\": \".*\",\
            \"type\": \"${entityTypeToBeSubscribed}\"\
          }\
        ],\
        \"condition\": {\
          \"attrs\": [\
            \"additionalInfo\"\
          ]\
        }\
      },\
      \"notification\": {\
        \"http\": {\
          \"url\": \"${subscriber_url}\"\
        },\
        \"attrs\": [\
        ]\
      },\
      \"expires\": \"2040-01-01T14:00:00.00Z\",\
      \"throttling\": 1\
    }"


jsonRequest="{\
      \"description\": \"A subscription to get info about Pig\",\
      \"subject\": {\
        \"entities\": [\
          {\
            \"id\": \"${entityIdToBeSubscribed}\",\
            \"type\": \"${entityTypeToBeSubscribed}\"\
          }\
        ],\
        \"condition\": {\
          \"attrs\": [\
            \"additionalInfo\"\
          ]\
        }\
      },\
      \"notification\": {\
        \"http\": {\
          \"url\": \"${subscriber_url}\"\
        },\
        \"attrs\": [\
        ]\
      },\
      \"expires\": \"2040-01-01T14:00:00.00Z\",\
      \"throttling\": 1\
    }"

jsonRequestIdPatternGenericWithoutThro="{\
      \"description\": \"A subscription to get info about ${entityTypeToBeSubscribed}\",\
      \"subject\": {\
        \"entities\": [\
          {\
            \"idPattern\": \".*\",\
            \"type\": \"${entityTypeToBeSubscribed}\"\
          }\
        ],\
        \"condition\": {\
          \"attrs\": [\
            \"additionalInfo\"\
          ]\
        }\
      },\
      \"notification\": {\
        \"http\": {\
          \"url\": \"${subscriber_url}\"\
        },\
        \"attrs\": [\
        ]\
      },\
      \"expires\": \"2040-01-01T14:00:00.00Z\"\
    }"


jsonRequestWithoutThro="{\
      \"description\": \"A subscription to get info about Pig\",\
      \"subject\": {\
        \"entities\": [\
          {\
            \"id\": \"${entityIdToBeSubscribed}\",\
            \"type\": \"${entityTypeToBeSubscribed}\"\
          }\
        ],\
        \"condition\": {\
          \"attrs\": [\
            \"additionalInfo\"\
          ]\
        }\
      },\
      \"notification\": {\
        \"http\": {\
          \"url\": \"${subscriber_url}\"\
        },\
        \"attrs\": [\
        ]\
      },\
      \"expires\": \"2040-01-01T14:00:00.00Z\"\
    }"

function submit_a_subscription () {
    access_token=$1
    # Remove the suffix " (escaped with a backslash to prevent shell interpretation).
    access_token="${access_token%\"}"
    # Remove the prefix " (escaped with a backslash to prevent shell interpretation).
    access_token="${access_token#\"}"

    if [ "$genericId" = true ]; then
        if [ "$throttling" = true ]; then
            REQUEST="curl -i -s --location --request POST '${orion_url}/v2/subscriptions/' --header 'Content-Type: application/json' \
            --header 'Accept: application/json' --header 'X-auth-token: ${access_token}' -d '${jsonRequestIdPatternGeneric}'"
        else
            REQUEST="curl -i -s --location --request POST '${orion_url}/v2/subscriptions/' --header 'Content-Type: application/json' \
            --header 'Accept: application/json' --header 'X-auth-token: ${access_token}' -d '${jsonRequestIdPatternGenericWithoutThro}'"
    else
        if [ "$throttling" = true ]; then
            REQUEST="curl -i -s --location --request POST '${orion_url}/v2/subscriptions/' --header 'Content-Type: application/json' \
            --header 'Accept: application/json' --header 'X-auth-token: ${access_token}' -d '${jsonRequest}'"
        else
            REQUEST="curl -i -s --location --request POST '${orion_url}/v2/subscriptions/' --header 'Content-Type: application/json' \
            --header 'Accept: application/json' --header 'X-auth-token: ${access_token}' -d '${jsonRequestWithoutThro}'"
    fi
    var=$(eval ${REQUEST})
    
    if [[ $var == *"201"* ]]; then
        echo "Subscription created"
    fi
    echo "$var"

}

access_token=$(get_token)
submit_a_subscription $access_token
