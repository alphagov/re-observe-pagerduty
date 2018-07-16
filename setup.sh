#!/bin/bash
TERRAFORMPATH=$(which terraform)
TERRAFORMBACKVARS=$(pwd)/${ENV}.backend
ROOTPROJ=$(pwd)
TERRAFORMPROJ=$(pwd)/terraform/


############ Actions #################

clean() {
# Removes .terraform files to avoid state clashes
        echo $1

        if [ -d "$TERRAFORMPROJ$1/.terraform" ] ; then
                rm -rf $TERRAFORMPROJ$1/.terraform
                echo "Finished cleaning $1"
        else
                echo "$1 .terraform not found"
        fi
}

import_resource () {
# Import a terraform resource
        resource=`aws-vault exec ${PROFILE_NAME} -- $TERRAFORMPATH state list $1`
        if [ "$1" = "$resource" ] ; then
            echo "$1 already imported"
        else
            aws-vault exec ${PROFILE_NAME} -- $TERRAFORMPATH import $1 $2
        fi
}

init () {
# Init a terraform project
        echo $1

        cd $TERRAFORMPROJ$1

        aws-vault exec ${PROFILE_NAME} -- $TERRAFORMPATH init -backend-config=$TERRAFORMBACKVARS
}

plan () {
# Plan a terraform project
        echo $1

        cd $TERRAFORMPROJ$1

        aws-vault exec ${PROFILE_NAME} -- $TERRAFORMPATH plan
}

apply () {
# Apply a terraform project
        echo $1

        cd $TERRAFORMPROJ$1

        aws-vault exec ${PROFILE_NAME} -- $TERRAFORMPATH apply --auto-approve
}

#################################
#################################
ENV_VARS_SET=1
if [ -z "${ENV}" ] ; then
        echo "Please set your ENV environment variable";
        ENV_VARS_SET=0
fi
if [ -z "${PROFILE_NAME}" ] ; then
        echo "Please set your PROFILE_NAME environment variable";
        ENV_VARS_SET=0
fi

if [ "${ENV_VARS_SET}" = 0 ] ; then
        echo "Your environment hasn't been set correctly"
else
        case "$1" in
        -c) echo "Clean terraform statefile: ${ENV}"
                clean pagerduty
        ;;
        -i) echo "Initialize terraform dir: ${ENV}"
                init pagerduty
        ;;
        -p) echo "Create terraform plan: ${ENV}"
                plan pagerduty
        ;;
        -a) echo "Apply terraform plan to environment: ${ENV}"
                apply pagerduty
        ;;
        *) echo "Invalid option"
        ;;
        esac
fi
