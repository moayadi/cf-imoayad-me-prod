pipeline {   
  agent {
      node {
            label 'master'
          }  
  }
  environment {
          VAULT_ADDR="https://192.168.50.101:8200"
          ROLE_ID="158ff78e-21ac-43ef-fb01-5fb2a3294419"
          SECRET_ID=credentials("SECRET_ID")
          TFE_WORKSPACE_NAME="jenkinsdemo"
          TFE_ORGANIZATION='moayadi'
    }

  
  stages {
    stage('Stage 0') {
        steps {
            sh """
              echo got role_id and secret_id from Jenkins secret
              echo ${BUILD_URL} > buildurl.txt
              export PATH=/usr/local/bin:\${PATH}
              # AppRole Auth request
              echo retrieve token from Vault
              curl -k -s --request POST \
                 --data '{ \"role_id\": "$ROLE_ID", \"secret_id\": "$SECRET_ID" }' \
                 "\$VAULT_ADDR"/v1/auth/approle/login > login.json
              """
        }
      }
    stage('getAWSCredentials'){
    
      steps{
     
           sh """#!/bin/bash
            echo generate dynamic AWS IAM APIs for Terraform Workspace 
            VAULT_TOKEN=\$(cat login.json | jq -r .auth.client_token)
            # echo \$VAULT_TOKEN
            # Secret read request
            H1="X-Vault-Token: \$VAULT_TOKEN"
            # echo \$H1
            URL="\$VAULT_ADDR/v1/aws-jenkins/creds/awsjenkins"
            # echo \$URL
            curl -k -s -H "\$H1" \$URL > creds.json
            # cat creds.json
            """
          
        }    
    }

    
    stage('RotateWorkspaceTFECreds'){
      steps{
    
            sh '''#!/bin/bash
            echo Rotate Terraform workspace credentials
            access_key=($(cat creds.json | jq -r '.data.access_key'))
            secret_key=($(cat creds.json | jq -r '.data.secret_key'))
            
            echo '{
                "data": {
                  "id":"var-xXq8ihy7etqCYNHj",
                  "attributes": {
                    "key":"AWS_ACCESS_KEY_ID",
                    "value":"'$access_key'",
                    "description": "new description",
                    "category":"env",
                    "hcl": "false",
                    "sensitive": "true"
                  },
                  "type":"vars"
                }
              }' > access.json
            
            echo '{
                "data": {
                  "id":"var-jFZotZUY1xF6cnR7",
                  "attributes": {
                    "key":"AWS_SECRET_ACCESS_KEY",
                    "value":"'$secret_key'",
                    "description": "new description",
                    "category":"terraform",
                    "hcl": "false",
                    "sensitive": "true"
                  },
                  "type":"vars"
                }
              }' > secret.json
            
            '''

          sh """#!/bin/bash
            VAULT_TOKEN=\$(cat login.json | jq -r .auth.client_token)
            # echo \$VAULT_TOKEN
            # Secret read request
            H1="X-Vault-Token: \$VAULT_TOKEN"
            # echo \$H1
            URL="\$VAULT_ADDR/v1/kv/data/tfe"
            # echo \$URL
            curl -k -s -H "\$H1" \$URL > tfetokens.json
            # cat tfetokens.json
            """
            sh '''#!/bin/bash
            TOKEN=($(cat tfetokens.json | jq -r '.data.data.token'))
            echo $TOKEN
            H1="Content-Type: application/vnd.api+json"
            H2="Authorization: Bearer $TOKEN"
            echo $H2
            URL1="https://app.terraform.io/api/v2/vars/var-jFZotZUY1xF6cnR7"
            response=$(curl -s -H "$H1" -H "$H2" --request PATCH --data @access.json "$URL1")
            echo $response
            URL2="https://app.terraform.io/api/v2/vars/var-xXq8ihy7etqCYNHj"
            response=$(curl -s -H "$H1" -H "$H2" --request PATCH --data @secret.json "$URL2")
            # echo $response
            '''
        
        
    }    
    }
    
    
    stage('uploadConfiguration') {
      steps {
          
            sh '''#!/bin/bash
            echo upload Terraform configuration file to Terraform Enterprise
            echo '{
                      "data": {
                        "type": "configuration-versions",
                        "attributes": {
                          "auto-queue-runs": false
                        }
                      }
                    }' > configuration.json
                '''
            sh 'tar -czf jenkinsdemo.tar.gz -C /vagrant/demos/pipeline --exclude .git --exclude .terraform .'

            sh '''#!/bin/bash
            echo Get workspace id
            TOKEN=($(cat tfetokens.json | jq -r '.data.data.token'))
            H1="Content-Type: application/vnd.api+json"
            H2="Authorization: Bearer $TOKEN"
            URL="https://app.terraform.io/api/v2/organizations/$TFE_ORGANIZATION/workspaces/$TFE_WORKSPACE_NAME"
            curl -k -s -H "$H1" -H "$H2" --request GET "$URL" > workspace_results.json
            '''

            sh '''#!/bin/bash
            TOKEN=($(cat tfetokens.json | jq -r '.data.data.token'))
            echo $TOKEN
            workspace_id=($(cat workspace_results.json | jq -r '.data.id'))
            H1="Content-Type: application/vnd.api+json"
            H2="Authorization: Bearer $TOKEN"
            URL="https://app.terraform.io/api/v2/workspaces/$workspace_id/configuration-versions"
            curl -k -s -H "$H1" -H "$H2" --request POST --data @configuration.json "$URL" > config_results.json
            '''
            
            sh '''#!/bin/bash
            config_id=($(cat config_results.json | jq -r '.data.id'))
            # echo $config_id
            config_url=($(cat config_results.json | jq -r '.data.attributes."upload-url"'))
            # echo $config_url
            H1="Content-Type: application/octet-stream"
            H2="Authorization: Bearer $TOKEN"
            # URL=$config_url
            curl -k -s -H "$H1" -H "$H2" --request PUT --data-binary @jenkinsdemo.tar.gz "$config_url"
            '''
        
      }
    }
    stage('TFEApply') {
        
      steps { 
                sh '''#!/bin/bash
                    echo apply a run on the Terraform workspace
                    message=($(cat buildurl.txt))
                    workspace_id=($(cat workspace_results.json | jq -r '.data.id'))
                    echo $workspace_id
                    config=($(cat config_results.json | jq -r '.data.id'))
                    echo '{
                              "data": {
                                "attributes": {
                                  "is-destroy": "false",
                                  "message": "'$message'"
                                },
                                "type":"runs",
                                "relationships": {
                                  "workspace": {
                                    "data": {
                                      "type": "workspaces",
                                      "id": "'$workspace_id'"
                                    }
                                  },
                                  "configuration-version": {
                                    "data": {
                                      "type": "configuration-versions",
                                      "id": "'$config'"
                                    }
                                  }
                                }
                              }
                        }' > run.json
                        '''
                    
                    sh '''#!/bin/bash
                    TOKEN=($(cat tfetokens.json | jq -r '.data.data.token'))
                    H1="Content-Type: application/vnd.api+json"
                    H2="Authorization: Bearer $TOKEN"
                    URL="https://app.terraform.io/api/v2/runs"
                    curl -k -s -H "$H1" -H "$H2" --request POST --data @run.json "$URL" > run_results.json
                    '''
      }
    }

  }
}
