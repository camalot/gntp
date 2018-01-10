#!groovy
import com.bit13.jenkins.*

properties ([
	buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5')),
	disableConcurrentBuilds(),
	pipelineTriggers([
		pollSCM('H/30 * * * *')
	]),
])
if(env.BRANCH_NAME ==~ /master$/) {
		return
}

node ("linux") {


	def ProjectName = "gntp"
	def teamName = "docker-scripts"
	def slack_notify_channel = null

	def SONARQUBE_INSTANCE = "bit13"

	def MAJOR_VERSION = 1
	def MINOR_VERSION = 0

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION
	
	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = Accounts.GIT_ORGANIZATION
	env.CI_PROJECT_NAME = "${ProjectName}"

	currentBuild.result = "SUCCESS"
	def errorMessage = null


	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
					stage ("install" ) {
						deleteDir()
						Branch.checkout_vsts(this, teamName, env.CI_PROJECT_NAME)
						Pipeline.install(this)
					}
					stage ("build") {
						sh script: "${WORKSPACE}/.deploy/build.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}'"
					}
					stage ("test") {
						withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_ARTIFACTORY_CREDENTIAL_ID,
						 								usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
						 		sh script: "${WORKSPACE}/.deploy/test.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}'"
						}
					}
					stage ("deploy") {
						sh script: "${WORKSPACE}/.deploy/deploy.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}'"
					}
					stage ('publish') {
						// this only will publish if the incominh branch IS develop
						Branch.publish_to_master(this)
						Pipeline.upload_artifact(this, "dist/${env.CI_PROJECT_NAME}-${env.CI_BUILD_VERSION}.zip", "generic-local/${env.CI_PROJECT_NAME}/${env.CI_BUILD_VERSION}/${env.CI_PROJECT_NAME}-${env.CI_BUILD_VERSION}.zip", "")
						Pipeline.upload_artifact(this, "dist/${env.CI_PROJECT_NAME}-${env.CI_BUILD_VERSION}.zip", "generic-local/${env.CI_PROJECT_NAME}/latest/${env.CI_PROJECT_NAME}-latest.zip", "")
						Pipeline.publish_buildInfo(this)
						sh script:  "${WORKSPACE}/.deploy/publish.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}'"
					}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
