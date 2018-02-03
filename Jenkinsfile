#!groovy
import com.bit13.jenkins.*



if(env.BRANCH_NAME ==~ /master$/) {
		return
}


node ("docker") {
	def ProjectName = "emojipacks"
  def gitOrganization = "bit13labs"
	def slack_notify_channel = null

	def MAJOR_VERSION = 2
	def MINOR_VERSION = 1


properties ([
	buildDiscarder(logRotator(numToKeepStr: '25', artifactNumToKeepStr: '25')),
	disableConcurrentBuilds(),
	pipelineTriggers([
		pollSCM('H/30 * * * *')
	]),
])

	env.PROJECT_MAJOR_VERSION = MAJOR_VERSION
	env.PROJECT_MINOR_VERSION = MINOR_VERSION

	env.CI_BUILD_VERSION = Branch.getSemanticVersion(this)
	env.CI_DOCKER_ORGANIZATION = Accounts.GIT_ORGANIZATION
	env.CI_PROJECT_NAME = ProjectName
	currentBuild.result = "SUCCESS"
	def errorMessage = null
	wrap([$class: 'TimestamperBuildWrapper']) {
		wrap([$class: 'AnsiColorBuildWrapper', colorMapName: 'xterm']) {
			Notify.slack(this, "STARTED", null, slack_notify_channel)
			try {
				withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: env.CI_ARTIFACTORY_CREDENTIAL_ID,
												usernameVariable: 'ARTIFACTORY_USERNAME', passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
					withCredentials([[$class: 'StringBinding', credentialsId: env.CI_VAULT_CREDENTIAL_ID, variable: 'VAULT_AUTH_TOKEN']]) {
						stage ("install" ) {
								deleteDir()
								Branch.checkout(this, "${env.CI_PROJECT_NAME}", gitOrganization)
								Pipeline.install(this)
						}
						stage ("lint") {
							sh script: "${WORKSPACE}/.deploy/lint.sh"
						}
						stage ("build") {
							env.SLACK_SUBDOMAIN = SecretsVault.get(this, "secret/slackmoji", "SLACK_SUBDOMAIN")
							env.SLACK_USER_EMAIL = SecretsVault.get(this, "secret/slackmoji", "SLACK_USER_EMAIL")
							env.SLACK_USER_PASSWORD = SecretsVault.get(this, "secret/slackmoji", "SLACK_USER_PASSWORD")

							sh script: "${WORKSPACE}/.deploy/build.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
						}
						stage ("test") {
							sh script: "${WORKSPACE}/.deploy/test.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
							}
						stage ("deploy") {
							sh script: "${WORKSPACE}/.deploy/deploy.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
						}
						stage ("verify") {
							sh script: "${WORKSPACE}/.deploy/validate.sh -n '${env.CI_PROJECT_NAME}' -v '${env.CI_BUILD_VERSION}' -o '${env.CI_DOCKER_ORGANIZATION}'"
						}
						stage ('publish') {
							// this only will publish if the incominh branch IS develop
							Branch.publish_to_master(this)
							Pipeline.publish_buildInfo(this)
						}
					}
				}
			} catch(err) {
				currentBuild.result = "FAILURE"
				errorMessage = err.toString()
				throw err
			}
			finally {
				Pipeline.finish(this, currentBuild.result, errorMessage)
			}
		}
	}
}
