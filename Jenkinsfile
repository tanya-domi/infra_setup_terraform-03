pipeline {
agent any

environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
}
stages{
  stage('Terraform Init'){
    steps {
	    script {
            sh 'terraform init'
        }
    }
  }
  stage('Terraform Plan'){
    steps {
	    script {
            sh 'terraform plan'
        }
    }
  }
  stage('Approval'){
    when { branch 'main'}
    steps {
       script {
          waitUntil {
            fileExists('dummyfile')
          }
       }
     }
   }
   stage('Terraform Apply'){
     when { branch 'main'}
     steps {
 	    script {
             sh 'terraform apply -auto-approve'
         }
     }
   }
}
}