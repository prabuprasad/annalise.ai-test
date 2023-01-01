#!/bin/bash

sudo cd /home/radium
sudo wget https://releases.rancher.com/cli2/v2.4.10/rancher-linux-amd64-v2.4.10.tar.gz
sudo tar xzvf rancher-linux-amd64-v2.4.10.tar.gz
LOGINRESPONSE=`curl -s 'https://10.10.1.4:8443/v3-public/localProviders/local?action=login' -H 'content-type: application/json' --data-binary '{"username":"admin","password":"LikeABosch123"}' --insecure`
LOGINTOKEN=`echo $LOGINRESPONSE | jq -r .token`
rancher-v2.4.10/rancher login https://10.10.1.4:8443 --token $LOGINTOKEN --skip-verify --context local:p-wvqs2 
rancher-v2.4.10/rancher cluster create $1 >/dev/null
clusterid=$(rancher-v2.4.10/rancher cluster ls | grep "$1" | awk '{print $1; }')
echo $clusterid
if [ "master" == $2 ] 
then
master_cmd=$(rancher-v2.4.10/rancher cluster add-node --etcd --controlplane --worker $clusterid $1 | grep "sudo" | sed 's/^.*: //' )
$master_cmd
else
worker_cmd=$(rancher-v2.4.10/rancher cluster add-node --worker $clusterid $1 | grep "sudo" | sed 's/^.*: //' )
$worker_cmd
fi

## Project creation command
./rancher context switch
./rancher context switch c-5twxp:p-wsxsg
./rancher project ls
./rancher project create test
./rancher project delete test
(or)
./rancher project delete c-5twxp:p-fpc5q

## curl commands
ADMINBEARERTOKEN=token-ng46v:hnwtvqcfppwv5qc7ssss5xk9skrzvpvh442wxjlzlp4zkkp6mt6j9w
RANCHERENDPOINT=https://10.10.1.4:8443/v3
USERID=`curl -s -u $ADMINBEARERTOKEN $RANCHERENDPOINT/user -H 'content-type: application/json' --data-binary '{"me":false,"mustChangePassword":false,"type":"user","username":"'dummy'","password":"'dummy'","name":"'dummy'"}' --insecure | jq -r .id`
curl -s -u $ADMINBEARERTOKEN $RANCHERENDPOINT/globalrolebinding -H 'content-type: application/json' --data-binary '{"type":"globalRoleBinding","globalRoleId":"'user'","userId":"'$USERID'"}' --insecure
CLUSTERID=`curl -s -u $ADMINBEARERTOKEN $RANCHERENDPOINT/clusters?name=cluster1 --insecure | jq -r .data[].id`
curl -s -u $ADMINBEARERTOKEN $RANCHERENDPOINT/clusterRoleTemplateBinding -H 'content-type: application/json' --data-binary '{"type":"clusterRoleTemplateBinding","clusterId":"'$CLUSTERID'","userPrincipalId":"'local://$USERID'","roleTemplateId":"'cluster-member'"}' --insecure



curl -k -u "token-ng46v:hnwtvqcfppwv5qc7ssss5xk9skrzvpvh442wxjlzlp4zkkp6mt6j9w" \
-X POST \
-H 'Content-Type: application/json' \
-d '{"clusterId":"'c-8jmn5'","allowSystemRole": true,"name": "test1", "description": "Test","members":[{"role": "member","externalIdType": "rancher_id","description": "test", "externalId": "CN=Test User2,CN=Users,DC=tad,DC=rancher,DC=io"}]}' 'https://10.10.1.4:8443/v3/projects/c-8jmn5/projects' 
 
curl -u "token-ng46v:hnwtvqcfppwv5qc7ssss5xk9skrzvpvh442wxjlzlp4zkkp6mt6j9w" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{"groupId": "","groupPrincipalId": "","name": "","namespaceId": "","projectId": "c-8jmn5:p-br76t","roleTemplateId": "project-owner","userId": "u-fhwsk","userPrincipalId": ""}' 'https://10.10.1.4:8443/v3/projectroletemplatebindings'