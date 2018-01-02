#!groovy
import com.bit13.jenkins.*

properties ([
	buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5')),
	disableConcurrentBuilds(),
	pipelineTriggers([
		pollSCM('H/30 * * * *')
	]),
])


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

	def artifactory = Artifactory.server env.CI_ARTIFACTORY_SERVER_ID
  def buildInfo = Artifactory.newBuildInfo()

	currentBuild.result = "SUCCESS"
	def errorMessage = null

	if(env.BRANCH_NAME ==~ /master$/) {
			return
	}

	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
					stage ("install" ) {
							deleteDir()
							// buildInfo.retention maxBuilds: 1, maxDays: 2, doNotDiscardBuilds: ["3"], deleteBuildArtifacts: true
							Branch.checkout_vsts(this, teamName, ProjectName)

							Pipeline.install(this)
					}
					stage ("build") {
							sh script: "${WORKSPACE}/.deploy/build.sh -n '${ProjectName}' -v '${env.CI_BUILD_VERSION}'"
					}
					stage ("test") {
							withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_ARTIFACTORY_CREDENTIAL_ID,
							 								usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
							 		sh script: "${WORKSPACE}/.deploy/test.sh -n '${ProjectName}' -v '${env.CI_BUILD_VERSION}'"
							}
					}
					stage ("deploy") {
							sh script: "${WORKSPACE}/.deploy/deploy.sh -n '${ProjectName}' -v '${env.CI_BUILD_VERSION}'"

							def uploadSpec = """{
  "files": [
    {
      "pattern": "dist/${ProjectName}-${env.CI_BUILD_VERSION}.zip",
      "target": "generic-local/${ProjectName}/${env.CI_BUILD_VERSION}/${ProjectName}-${env.CI_BUILD_VERSION}.zip"
    }
 ]
}"""
						server.upload(uploadSpec, buildInfo)
						server.publishBuildInfo(buildInfo)
					}
					stage ('cleanup') {
							// this only will publish if the incominh branch IS develop
							Branch.publish_to_master(this)
							Pipeline.cleanup(this)
					}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.message
				throw err
			}
			finally {
				if(currentBuild.result == "SUCCESS") {
					if (Branch.isMasterOrDevelopBranch(this)) {
						currentBuild.displayName = "${env.CI_BUILD_VERSION}"
					} else {
						currentBuild.displayName = "${env.CI_BUILD_VERSION} [#${env.BUILD_NUMBER}]"
					}
				}
				Notify.slack(this, currentBuild.result, errorMessage)
			}
		}
	}
}
