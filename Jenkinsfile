pipeline {
	agent none
	stages {
		stage('Non-Parallel Stage') {
			agent {
					label "master"
					}
			steps {
					echo "This stage will be executed first !!";
			}
		}
		
		stage('Run Tests') {
			parallel {
				stage('Test on windows') { 
					agent {
						label "Windows_Node"
					}
					steps {
							echo "Task1 on Agent ";
					}
				}
		
				stage('Test on Master') {
					agent {
						label "master"
					}
					steps {
						echo "Task1 on Master";
					}
				}		
			}
		
		}	
	}
}
