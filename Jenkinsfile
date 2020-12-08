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
          TFE_WORKSPACE_NAME="cf-imoayad-me-prod"
          TFE_ORGANIZATION='moayadi'
          VAULT_TOKEN= sh(script: """
              curl -k -s --request POST \
                 --data '{ \"role_id\": "$ROLE_ID", \"secret_id\": "$SECRET_ID" }' \
                 "$VAULT_ADDR"/v1/auth/approle/login | jq -r .auth.client_token
              """, returnStdout: true, encoding: 'UTF-8').trim()
          TFE_TOKEN= sh(script: """
              curl -k -s  \
                 --header "X-Vault-Token: $VAULT_TOKEN" \
                 "$VAULT_ADDR"/v1/kv/data/tfe | jq -r .data.data.token
              """, returnStdout: true, encoding: 'UTF-8').trim()
    }

  
  stages {

    stage('GetCode') {
        steps {
          git poll: false, url: 'https://github.com/moayadi/cf-imoayad-me-prod'
          sh 'tar -zcvf jenkinsdemo.tar.gz -C . --exclude .git --exclude .terraform .'

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
            sh 'tar -zcvf jenkinsdemo.tar.gz -C . --exclude .git --exclude .terraform .'

            sh '''#!/bin/bash
            echo Get workspace id
            H1="Content-Type: application/vnd.api+json"
            H2="Authorization: Bearer $TFE_TOKEN"
            URL="https://app.terraform.io/api/v2/organizations/$TFE_ORGANIZATION/workspaces/$TFE_WORKSPACE_NAME"
            curl -k -s -H "$H1" -H "$H2" --request GET "$URL" > workspace_results.json
            '''

            sh '''#!/bin/bash
            workspace_id=($(cat workspace_results.json | jq -r '.data.id'))
            H1="Content-Type: application/vnd.api+json"
            H2="Authorization: Bearer $TFE_TOKEN"
            URL="https://app.terraform.io/api/v2/workspaces/$workspace_id/configuration-versions"
            curl -k -s -H "$H1" -H "$H2" --request POST --data @configuration.json "$URL" > config_results.json
            '''
            
            sh '''#!/bin/bash
            config_id=($(cat config_results.json | jq -r '.data.id'))
            # echo $config_id
            config_url=($(cat config_results.json | jq -r '.data.attributes."upload-url"'))
            # echo $config_url
            H1="Content-Type: application/octet-stream"
            H2="Authorization: Bearer $TFE_TOKEN"
            # URL=$config_url
            curl -k -s -H "$H1" -H "$H2" --request PUT --data-binary @jenkinsdemo.tar.gz "$config_url"
            '''
        
      }
    }
    // stage('TFEApply') {
        
    //   steps { 
    //             sh '''#!/bin/bash
    //                 echo apply a run on the Terraform workspace
    //                 message=($(cat buildurl.txt))
    //                 workspace_id=($(cat workspace_results.json | jq -r '.data.id'))
    //                 echo $workspace_id
    //                 config=($(cat config_results.json | jq -r '.data.id'))
    //                 echo '{
    //                           "data": {
    //                             "attributes": {
    //                               "is-destroy": "false",
    //                               "message": "'$message'"
    //                             },
    //                             "type":"runs",
    //                             "relationships": {
    //                               "workspace": {
    //                                 "data": {
    //                                   "type": "workspaces",
    //                                   "id": "'$workspace_id'"
    //                                 }
    //                               },
    //                               "configuration-version": {
    //                                 "data": {
    //                                   "type": "configuration-versions",
    //                                   "id": "'$config'"
    //                                 }
    //                               }
    //                             }
    //                           }
    //                     }' > run.json
    //                     '''
                    
    //                 sh '''#!/bin/bash
    //                 TOKEN=($(cat tfetokens.json | jq -r '.data.data.token'))
    //                 H1="Content-Type: application/vnd.api+json"
    //                 H2="Authorization: Bearer $TOKEN"
    //                 URL="https://app.terraform.io/api/v2/runs"
    //                 curl -k -s -H "$H1" -H "$H2" --request POST --data @run.json "$URL" > run_results.json
    //                 '''
    //   }
    //}

  }
}
