pipeline {
	agent {
	    label 'Windows_Node'
	}
	stages {
		stage('Git-Checkout') {
			steps {
					echo "checking out from Git repo !!";
					git branch: 'main', credentialsId: '3186a2d7-901a-4ffe-9921-fdc969b60742', url: 'https://github.com/PrashanthMothukuri/PrashanthM.git'
			}
		}
		
		stage('Build') {
			steps {
					echo "Building the checked out project ";
					bat 'Build.bat'
			}
		}
		
		stage('Unit-Test') {
			steps {
					echo "Running JUnit tests ";
					bat 'Unit.bat'
			}
		}
		
		stage('Quality-Gate') {
			steps {
					echo "verifying quality gates";
					bat 'Quality.bat'
			}
		}
		
		stage('Deploy') {
			steps {
					echo "Deploying  !!";
					bat 'Deploy.bat'
			}
		}
		
		
	}
}
