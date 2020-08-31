# Deploy Jenkins on Kubernetes

## Install helm

Install version 3.3.0

See: https://helm.sh/docs/intro/install

Ubuntu:

```bash
wget https://get.helm.sh/helm-v3.3.0-linux-amd64.tar.gz
tar xzvf  helm-v3.3.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64
```

## Install Jenkins

Install stable/jenkins with Kubernetes Continuous Deploy plugin (https://plugins.jenkins.io/kubernetes-cd/) 

```bash
helm install cicd stable/jenkins --set rbac.create=true,master.servicePort=80,master.serviceType=LoadBalancer,master.additionalPlugins={kubernetes-cd:2.3.0}
```

### Get Jenkins external address

```bash
kubectl get svc cicd-jenkins -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

### Get Jenkins login credentials

username: admin

password:
```bash
printf $(kubectl get secret --namespace default cicd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
```
### Create Jenkins service account to deploy 

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-deploy
---
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-deploy-token
  annotations:
    kubernetes.io/service-account.name: jenkins-deploy
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: jenkins-deploy-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: jenkins-deploy
  namespace: default
EOF
```

### Create kubeconfig with service account token

```bash
cat<<EOF | /bin/bash 
SERVICE_ACCOUNT_NAME=jenkins-deploy
CONTEXT=\$(kubectl config current-context)
NAMESPACE=default
NEW_CONTEXT=jenkins
KUBECONFIG_FILE="kubeconfig-sa"
SECRET_NAME=\$(kubectl get serviceaccount \${SERVICE_ACCOUNT_NAME} \
  --context \${CONTEXT} \
  --namespace \${NAMESPACE} \
  -o jsonpath='{.secrets[0].name}')
TOKEN_DATA=\$(kubectl get secret \${SECRET_NAME} \
  --context \${CONTEXT} \
  --namespace \${NAMESPACE} \
  -o jsonpath='{.data.token}')
TOKEN=\$(echo \${TOKEN_DATA} | base64 -d)

# Create dedicated kubeconfig
# Create a full copy
{
kubectl config view --raw > \${KUBECONFIG_FILE}.full.tmp
# Switch working context to correct context
kubectl --kubeconfig \${KUBECONFIG_FILE}.full.tmp config use-context \${CONTEXT}
# Minify
kubectl --kubeconfig \${KUBECONFIG_FILE}.full.tmp \
  config view --flatten --minify > \${KUBECONFIG_FILE}.tmp
# Rename context
kubectl config --kubeconfig \${KUBECONFIG_FILE}.tmp \
  rename-context \${CONTEXT} \${NEW_CONTEXT}
# Create token user
kubectl config --kubeconfig \${KUBECONFIG_FILE}.tmp \
  set-credentials \${CONTEXT}-\${NAMESPACE}-token-user \
  --token \${TOKEN}
# Set context to use token user
kubectl config --kubeconfig \${KUBECONFIG_FILE}.tmp \
  set-context \${NEW_CONTEXT} --user \${CONTEXT}-\${NAMESPACE}-token-user
# Set context to correct namespace
kubectl config --kubeconfig \${KUBECONFIG_FILE}.tmp \
  set-context \${NEW_CONTEXT} --namespace \${NAMESPACE}
# Flatten/minify kubeconfig
kubectl config --kubeconfig \${KUBECONFIG_FILE}.tmp \
  view --flatten --minify > \${KUBECONFIG_FILE}
} > /dev/null
cat \${KUBECONFIG_FILE}
rm -f \${KUBECONFIG_FILE}*
echo
EOF
```

## Configure Jenkins

## Create kubeconfig credential type

![alt text](https://github.com/jaflores357/aws-tf-eks-modules/blob/master/jenkins/jenkins-kubeconfig-credentials.png?raw=true "Jenkins kubeconfig Credentials")

ID: jenkins-kubeconfig

## Create sample pipeline Job

![alt text](https://github.com/jaflores357/aws-tf-eks-modules/blob/master/jenkins/job-pipeline.png?raw=true "Job Pipeline")

### Configure Job

repo: https://github.com/jaflores357/sample-k8s-app.git

![alt text](https://github.com/jaflores357/aws-tf-eks-modules/blob/master/jenkins/configure-job.png?raw=true "Configure Job")

#### JobsJenkinsfile

```js
pipeline {
    agent any
    environment {
        KUBECONFIG = 'jenkins-kubeconfig'
        ENDPOINT = " "
    }
    stages {
        stage("Checkout code") {
            steps {
                checkout scm
            }
        }
        stage("Build image") {
            steps{
                sh "echo 'Build image'"
            }    
        }
        stage("Push image") {
            steps{
                sh "echo 'Push image'"
            }    
        }       
        stage('Deploy to EKS dev cluster') {
            steps{
                script {
                    kubernetesDeploy(configs: "**/k8s/*", kubeconfigId: env.KUBECONFIG)
                }
            }
        }

        //stage('Deploy to EKS production cluster') {
        //   steps{
        //        input message:"Proceed with final deployment?"
        //        script {
        //            kubernetesDeploy(configs: "**/k8s/*", kubeconfigId: env.KUBECONFIG)
        //        }
        //
        //        
        //    }
        //}   

        stage('Test endpoint') {
            steps{
                sh "chmod +x ./check-endpoint.sh"
                sh "./check-endpoint.sh ${ENDPOINT}"
            }
        }
    }    
}
```

### Get job external address

After successful deployment get external address

```bash
kubectl get ingress 2048-ingress -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
```

