#!/usr/bin/groovy
@Library('github.com/christian-posta/fabric8-pipeline-library@ceposta-db')

def localItestPattern = ""
try {
  localItestPattern = ITEST_PATTERN
} catch (Throwable e) {
  localItestPattern = "*KT"
}

def localFailIfNoTests = ""
try {
  localFailIfNoTests = ITEST_FAIL_IF_NO_TEST
} catch (Throwable e) {
  localFailIfNoTests = "false"
}

def versionPrefix = ""
try {
  versionPrefix = VERSION_PREFIX
} catch (Throwable e) {
  versionPrefix = "1.0"
}

def canaryVersion = "${versionPrefix}.${env.BUILD_NUMBER}"

def fabric8Console = "${env.FABRIC8_CONSOLE ?: ''}"
def utils = new io.fabric8.Utils()
def label = "buildpod.${env.JOB_NAME}.${env.BUILD_NUMBER}".replace('-', '_').replace('/', '_')

podTemplate(label: label, serviceAccount: 'jenkins', containers: [
        [name: 'maven', image: 'fabric8/maven-builder', command: 'cat', ttyEnabled: true, envVars: [
                [key: 'MAVEN_OPTS', value: '-Duser.home=/home/jenkins/'],
                [key: 'DOCKER_CONFIG', value: '/home/jenkins/.docker/'],
                [key: 'KUBERNETES_MASTER', value: 'kubernetes.default']]],
        [name: 'jnlp', image: 'iocanel/jenkins-jnlp-client:latest', command:'/usr/local/bin/start.sh', args: '${computer.jnlpmac} ${computer.name}', ttyEnabled: false,
         envVars: [[key: 'DOCKER_HOST', value: 'unix:/var/run/docker.sock']]]],
        volumes: [
                [$class: 'PersistentVolumeClaim', mountPath: '/home/jenkins/.mvnrepository', claimName: 'jenkins-mvn-local-repo'],
                [$class: 'SecretVolume', mountPath: '/home/jenkins/.m2/', secretName: 'jenkins-maven-settings'],
                [$class: 'SecretVolume', mountPath: '/home/jenkins/.docker', secretName: 'jenkins-docker-cfg'],
                [$class: 'HostPathVolume', mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock']
        ]) {
  node(label) {
    def envTest = utils.environmentNamespace('testing')
    def envStage = utils.environmentNamespace('staging')
    def envProd = utils.environmentNamespace('production')

    git 'http://192.168.64.16:31052/gogsadmin/orders-service.git'

    echo 'NOTE: running pipelines for the first time will take longer as build and base docker images are pulled onto the node'
    container(name: 'maven') {

      stage 'Build Release'
      mavenCanaryRelease {
        version = canaryVersion
        profiles = '-Pmysql'
      }

      stage 'Integration Testing'
      // let's deploy the database if it's not already there
      kubernetesApply(file: 'mysql-kubernetes.yml', environment: envTest)
      mavenIntegrationTest {
        environment = 'Testing'
        failIfNoTests = localFailIfNoTests
        itestPattern = localItestPattern
      }

      stage 'Rollout Staging'
      kubernetesApply(environment: envStage)

      stage 'Approve'
      approve {
        room = null
        version = canaryVersion
        console = fabric8Console
        environment = 'Staging'
      }

      stage 'Rollout Production'
      kubernetesApply(environment: envProd)

    }
  }
}
