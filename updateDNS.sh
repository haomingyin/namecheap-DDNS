#!/bin/bash -e

# Required environment variables are
# HOST - host record to be updated, e.g. @, www
# DOMAIN_NAME - the second level domain, e.g. haomingyin.com
# PASSWORD - the DDNS password
# IP - optional, if you don't specify any IP, the IP from which you are accessing
# this URL will be set for the domain

. ./utility.sh

function getHost() {
    if [ -z $HOST ]; then
        prompt_input "Please enter the HOST record to be updated"
        read var_host 
        export HOST=$(echo $var_host | tr '[:upper:]' '[:lower:]')
    fi
    prompt_info "Host is set to '$HOST'"
}

function getDomainName() {
    if [ -z $DOMAIN_NAME ]; then
        prompt_input "Please enter the DOMAIN NAME"
        read var_domain 
        export DOMAIN_NAME=$(echo $var_domain | tr '[:upper:]' '[:lower:]')
    fi
    prompt_info "Domain name is set to '$DOMAIN_NAME'" 
}

function getPassword() {
    if [ -z $PASSWORD ]; then
        prompt_input "Please enter the PASSWORD for the DNS record"
        read var_pwd
        export PASSWORD=$(echo $var_pwd | tr '[:upper:]' '[:lower:]')
    fi
    prompt_info "Password has been set"
}

# if an IP has been given, then return 0 (indicating no error)
# if no IP has been given, then public IP will be use, return 1 (indicating error/false)
function hasIP() {
    if [ -z $IP ]; then
        prompt_info "Local public IP will be used"
        return 1
    else
        prompt_info "'$HOST' record will be asscoiated with IP '$IP'"
        return 0
    fi
}

function processResponse() {
    errCount=$(xmllint --xpath '//interface-response/ErrCount/text()' - <<< $response)
    if [ "$errCount" == "0" ]; then
        IP=$(xmllint --xpath '//interface-response/IP/text()' - <<< $response)
        prompt_info "DNS record has been updated with IP '$IP'"
    else
        errMsg=$(xmllint --xpath '//interface-response/errors/Err1/text()' - <<< $response)
        prompt_error "$errMsg"
        exit 1
    fi
}

function main() {
    getHost
    getDomainName
    getPassword
    hostUrl="https://dynamicdns.park-your-domain.com/update?host=${HOST}&domain=${DOMAIN_NAME}&password=${PASSWORD}"
    if hasIP; then
        hostUrl="${hostUrl}&ip=${IP}"
    fi

    # send request via curl
    response="$(curl -s $hostUrl)"
    processResponse
}

main