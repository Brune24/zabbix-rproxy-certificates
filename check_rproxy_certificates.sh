#!/bin/bash
# hostname de la VM, nom de domaine, issuer, subject, date d’émission, date d’expiration.
ACTION=${1}
CERTPATH=${2}
CERTNAME=${3}

function discovery(){
    mapfile -t ARRAY < <(grep -rPo '^SSLCertificateFile \K(.*?)$' <PATH_TO_SSL.CONF> | cut -d'"' -f 2)
    # Split each elements because there are no multimensions arrays in BASH
    for INDEX in ${ARRAY[@]} 
    do
        CERTPATH=$(printf ${INDEX%/*})
        CERTNAME=$(printf ${INDEX##*/})                   
        json_data="$json_data,"'{"{#CERTPATH}":"'${CERTPATH}'","{#CERTNAME}":"'${CERTNAME}'"}'           
    done
    echo -e '{"data":['${json_data#,}']}'
}

function startdate(){
    STARTDATE=$(openssl x509 -in ${CERTPATH}/${CERTNAME} -noout -startdate | cut -d'=' -f2)
    printf $(date -d "${STARTDATE}" +%s)
}

function enddate(){
    ENDDATE=$(openssl x509 -in ${CERTPATH}/${CERTNAME} -noout -enddate| cut -d'=' -f2)
    printf $(date -d "${ENDDATE}" +%s)
}

function issuer(){
    echo $(openssl x509 -in ${CERTPATH}/${CERTNAME} -noout -issuer | grep -Po '(?:\/(C|ST|L|O|OU|CN|emailAddress)=\K([^\/]+))?')
}

function subject(){
    echo $(openssl x509 -in ${CERTPATH}/${CERTNAME} -noout -subject | grep -Po '(?:\/(C|ST|L|O|OU|CN|emailAddress)=\K([^\/]+))?')
}

case "${ACTION}" in
    "discovery")
        discovery
    ;;
    "startdate")
        startdate
    ;;
    "enddate")
        enddate
    ;;
    "issuer")
        issuer
    ;;
    "subject")
        subject
    ;;
*) echo "No arguments !"
esac
