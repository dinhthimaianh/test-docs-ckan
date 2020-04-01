def agentLabel	// Dùng để phân chia jenkins node
def version	    // Tách version nếu có trên branch name
if (BRANCH_NAME == "master") {
    agentLabel = "demo"    // tránh việc build nhánh master trên jenkins master
} else {
    try {
            version = TAG_NAME    // Trường hợp build tag
        }
        catch (exc) {
            agentLabel = BRANCH_NAME
        }
}
if ( version != null ) {
    agentLabel = "release"      // Nếu build tag thì dùng node build release
}

pipeline {
    agent { label agentLabel }    // Chia tải dựa trên label(branch name)
    options { disableConcurrentBuilds() }   // Disable multitask build
    environment {
        project = "opendata-ckan"   //#################### Định nghĩa project name ####################
        nexus_repo_name = "IT.KV2.Raw.OpenData-CKAN"    // Nexus repository name
    }
    stages {
        stage('Prepare') {
            steps {
                echo 'Prepare ... from ' + env.Server_IP + ' - build-numer: ' + env.BUILD_ID
                echo 'Prepare from source: ' + env.WORKSPACE
                echo 'Prepare version: ' + version
                script {
                    if (env.BRANCH_NAME == 'master') {
                        sh '''#!/bin/bash
                            #cp ${WORKSPACE}/.env.demo ${WORKSPACE}/.env
                        '''
                    } else if (env.BRANCH_NAME == 'release' || version != null){
                        sh '''#!/bin/bash
                            #cp ${WORKSPACE}/.env.prod ${WORKSPACE}/.env
                        '''
                    } else {
                        sh '''#!/bin/bash
                            #cp ${WORKSPACE}/.env.$BRANCH_NAME ${WORKSPACE}/.env
                        '''
                    }
                }
            }
        }
        stage('SonarQube Analysis') {
            // Xác định các nhánh cần scan, có thể sử dụng: when { anyOf { branch 'dev'; branch 'master' } }
            steps {
                script{
                    if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'staging'){
                        echo '##### Analyzing with ' + env.SONAR_HOST_URL
                        withSonarQubeEnv('SonarQube_master') {
                        echo 'Skip SonarQube Scan'
                        sh '''#! /bin/bash
                           #/opt/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=${project} -Dsonar.sources="./" -Dsonar.exclusions=vendor/**/* -Dsonar.language=php
                        '''
                        }
                    } else {
                        echo 'Skip SonarQube Scan'
                    }
                }
            }
        }
        stage('Test') {
            steps {
                echo '##### Skip Testing..'
            }
        }
        stage('Build Docker images') {
            steps {
                script {
                    echo '##### Build docker file for ' + env.BRANCH_NAME + ' branch.'
                    def buildFile = fileExists './build.sh'
                    if ( buildFile ) {
                        sh "/bin/bash ./build.sh ${project} $BRANCH_NAME"
                    } else {
                        echo "Can not found build.sh file"
                    }
                }
            }
        }
        stage('Re-Deploy') {
            steps {
                script {
                    echo 'Re-Deploy ' + env.BRANCH_NAME + ' branch ...'
                    if (env.BRANCH_NAME == 'dev') {
                        sh '''
                            data="{\\"annotations\\":{\\"cattle.io/timestamp\\":\\"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\\"}}"
                            curl -ik -X PUT https://rancher-dev:8443/v3/project/c-ppb4p:p-74hnc/workloads/deployment:opendata-ckan:opendata-ckan -H "Authorization: Bearer token-cc8bz:z9qxv9mdk999pvfw2796znz877k85zhd6rz8pbc69knjl7z57ldl44" -H 'content-type: application/json' -d "$data"
                        '''
                    } else if (env.BRANCH_NAME == 'master'){
                        sh '''
                            data="{\\"annotations\\":{\\"cattle.io/timestamp\\":\\"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\\"}}"
                            curl -ik -X PUT https://rancher-demo:8443/v3/project/c-47zfl:p-5zbj7/workload/deployment:opendata-ckan:opendata-ckan -H "Authorization: Bearer token-cc8bz:z9qxv9mdk999pvfw2796znz877k85zhd6rz8pbc69knjl7z57ldl44" -H 'content-type: application/json' -d "$data"
                        '''
                    } else {
                        echo 'Skip Re-Deploy ' + env.BRANCH_NAME + ' branch.'
                    }
                }
            }
        }
        stage('Nexus') {
            steps {
                script {
                    echo 'Upload source code to Sonatype Nexus Repository Manager ' + project
                    sh '''#!/bin/bash
                        tar -zcf "/tmp/${project}-$BRANCH_NAME.tar.gz" --exclude="./.git" "./"
                        curl -u admin:Vnpt@123 --upload-file "/tmp/${project}-$BRANCH_NAME.tar.gz" "http://nexus-repo:8081/repository/${nexus_repo_name}/GP2/${project}-$BRANCH_NAME.tar.gz"
                        #rm -f "/tmp/${project}-$BRANCH_NAME.tar.gz"
                    '''
                }
            }
        }

    }
}
