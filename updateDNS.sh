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
        prompt_input "Please enter the PASSWORD for the DDNS record"
        read var_pwd
        export PASSWORD=$(echo $var_pwd | tr '[:upper:]' '[:lower:]')
    fi
    prompt_info "Password has been set"
}

# If an IP has been given, then return 0 (indicating no error)
# If no IP has been given, then public IP will be use, return 1 (indicating error/false)
function hasIP() {
    if [ -z $IP ]; then
        prompt_info "Local public IP will be used"
        return 1
    else
        prompt_info "'$HOST' record will be asscoiated with IP '$IP'"
        return 0
    fi
}

# Checks if existed remote DNS record is the same with the IP address to be updated
# If they are identical, then returns 0 (indicating no error)
function isRemoteSame() {
    remoteIp="$(dig +short $HOST.$DOMAIN_NAME @resolver1.opendns.com)"
    localIp=$IP && [[ -z $IP ]] && localIp="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    if [ "$remoteIp" == "$localIp" ]; then
        return 0
    else
        return 1
    fi
}

function processResponse() {
    errCount=$(xmllint --xpath '//interface-response/ErrCount/text()' - <<< $response)
    if [ "$errCount" == "0" ]; then
        IP=$(xmllint --xpath '//interface-response/IP/text()' - <<< $response)
        prompt_info "DDNS '$HOST' record has been updated against IP '$IP'"
    else
        errMsg=$(xmllint --xpath '//interface-response/errors/Err1/text()' - <<< $response)
        prompt_error "$errMsg"
        exit 1
    fi
}

function main() {
    getHost
    getDomainName
    if [ -z $VAR_FORCE ] && isRemoteSame; then
        prompt_warn "Remote DDNS record is identical to the IP to be set to. Process exits gracefully."
        prompt_info "To force updating the record, please set '-f' or '--force' argument."
        exit 0
    fi

    getPassword
    hostUrl="https://dynamicdns.park-your-domain.com/update?host=${HOST}&domain=${DOMAIN_NAME}&password=${PASSWORD}"
    if hasIP; then
        hostUrl="${hostUrl}&ip=${IP}"
    fi

    # send request via curl
    response="$(curl -s $hostUrl)"
    processResponse
}

# Read arguments
for arg in "$@"
do  
    case $arg in 
        -f|--force)
        VAR_FORCE=true
        ;;
        *)
        prompt_error "Unknown argument type $arg"
        exit 1
        ;;
    esac
done

main
