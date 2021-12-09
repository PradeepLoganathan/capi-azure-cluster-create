#create the kind cluster
kind create cluster

kubectl get pods -A
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-558bd4d5db-98vmp                     1/1     Running   0          29m
kube-system          coredns-558bd4d5db-jw58j                     1/1     Running   0          29m
kube-system          etcd-kind-control-plane                      1/1     Running   0          30m
kube-system          kindnet-b4622                                1/1     Running   0          29m
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          30m
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          30m
kube-system          kube-proxy-95wg5                             1/1     Running   0          29m
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          30m
local-path-storage   local-path-provisioner-547f784dff-rncr2      1/1     Running   0          29m

#print cluster information
kubectl cluster-info


#login to azure
az login

#create a service principal
az ad sp create-for-rbac --role contributor

#set the azure subscription id
export AZURE_SUBSCRIPTION_ID=$(az account show --query 'id' --output tsv)

#set the azure tenant id
export AZURE_SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --role contributor)

#set the client id
export AZURE_CLIENT_ID=$(echo $AZURE_SERVICE_PRINCIPAL | jq -r '.appId') 
echo $AZURE_CLIENT_ID

#set the client secret
export AZURE_CLIENT_SECRET=$(echo $AZURE_SERVICE_PRINCIPAL | jq -r '.password')
echo $AZURE_CLIENT_SECRET

#set the tenant id
export AZURE_TENANT_ID=$(echo $AZURE_SERVICE_PRINCIPAL | jq -r '.tenant')
echo $AZURE_TENANT_ID

#set the azure location
export AZURE_LOCATION="eastus"

# Select VM types.
export AZURE_CONTROL_PLANE_MACHINE_TYPE="Standard_D2s_v3"
export AZURE_NODE_MACHINE_TYPE="Standard_D2s_v3"


# Base64 encode the variables
export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "$AZURE_SUBSCRIPTION_ID" | base64 | tr -d '\n')"
export AZURE_TENANT_ID_B64="$(echo -n "$AZURE_TENANT_ID" | base64 | tr -d '\n')"
export AZURE_CLIENT_ID_B64="$(echo -n "$AZURE_CLIENT_ID" | base64 | tr -d '\n')"
export AZURE_CLIENT_SECRET_B64="$(echo -n "$AZURE_CLIENT_SECRET" | base64 | tr -d '\n')"

# Settings needed for AzureClusterIdentity used by the AzureCluster
export AZURE_CLUSTER_IDENTITY_SECRET_NAME="cluster-identity-secret"
export CLUSTER_IDENTITY_NAME="cluster-identity"
export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE="default"


# Create a secret to include the password of the Service Principal identity created in Azure
# This secret will be referenced by the AzureClusterIdentity used by the AzureCluster
kubectl create secret generic "${AZURE_CLUSTER_IDENTITY_SECRET_NAME}" --from-literal=clientSecret="${AZURE_CLIENT_SECRET}"

# Initialize the management cluster
clusterctl init --infrastructure azure

# Fetching providers
# Installing cert-manager Version="v1.5.3"
# Waiting for cert-manager to be available...
# Installing Provider="cluster-api" Version="v1.0.1" TargetNamespace="capi-system"
# Installing Provider="bootstrap-kubeadm" Version="v1.0.1" TargetNamespace="capi-kubeadm-bootstrap-system"
# Installing Provider="control-plane-kubeadm" Version="v1.0.1" TargetNamespace="capi-kubeadm-control-plane-system"
# I1206 17:45:23.490778    6091 request.go:665] Waited for 1.024684562s due to client-side throttling, not priority and fairness, request: GET:https://127.0.0.1:35691/apis/cluster.x-k8s.io/v1alpha3?timeout=30s
# Installing Provider="infrastructure-azure" Version="v1.0.1" TargetNamespace="capz-system"

# Your management cluster has been initialized successfully!

# You can now create your first workload cluster by running the following:

# clusterctl generate cluster [name] --kubernetes-version [version] | kubectl apply -f - took 1m 6s  



kubectl get pods -A
# NAMESPACE            NAME                                         READY   STATUS              RESTARTS   AGE
# cert-manager         cert-manager-848f547974-82nx2                0/1     ContainerCreating   0          6s
# cert-manager         cert-manager-cainjector-54f4cc6b5-qrnxf      0/1     ContainerCreating   0          6s
# cert-manager         cert-manager-webhook-7c9588c76-lwqwg         0/1     ContainerCreating   0          6s
# kube-system          coredns-558bd4d5db-98vmp                     1/1     Running             0          30m
# kube-system          coredns-558bd4d5db-jw58j                     1/1     Running             0          30m
# kube-system          etcd-kind-control-plane                      1/1     Running             0          30m
# kube-system          kindnet-b4622                                1/1     Running             0          30m
# kube-system          kube-apiserver-kind-control-plane            1/1     Running             0          30m
# kube-system          kube-controller-manager-kind-control-plane   1/1     Running             0          30m
# kube-system          kube-proxy-95wg5                             1/1     Running             0          30m
# kube-system          kube-scheduler-kind-control-plane            1/1     Running             0          30m
# local-path-storage   local-path-provisioner-547f784dff-rncr2      1/1     Running             0          30m

#CAPI and capz pods running to begin cluster creation on Azure
 kubectl get pods -A
# NAMESPACE                           NAME                                                             READY   STATUS    RESTARTS   AGE
# capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-58945b95bf-87lvj       1/1     Running   0          9m46s
# capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-58fc8f8c7c-9w5pm   1/1     Running   0          9m45s
# capi-system                         capi-controller-manager-576744d8b7-8rwsn                         1/1     Running   0          9m48s
# capz-system                         capz-controller-manager-5bb77c9cf4-8vzwb                         1/1     Running   0          9m42s
# capz-system                         capz-nmi-svrht                                                   1/1     Running   0          9m42s
# cert-manager                        cert-manager-848f547974-82nx2                                    1/1     Running   0          10m
# cert-manager                        cert-manager-cainjector-54f4cc6b5-qrnxf                          1/1     Running   0          10m
# cert-manager                        cert-manager-webhook-7c9588c76-lwqwg                             1/1     Running   0          10m
# kube-system                         coredns-558bd4d5db-98vmp                                         1/1     Running   0          40m
# kube-system                         coredns-558bd4d5db-jw58j                                         1/1     Running   0          40m
# kube-system                         etcd-kind-control-plane                                          1/1     Running   0          41m
# kube-system                         kindnet-b4622                                                    1/1     Running   0          40m
# kube-system                         kube-apiserver-kind-control-plane                                1/1     Running   0          41m
# kube-system                         kube-controller-manager-kind-control-plane                       1/1     Running   0          41m
# kube-system                         kube-proxy-95wg5                                                 1/1     Running   0          40m
# kube-system                         kube-scheduler-kind-control-plane                                1/1     Running   0          41m
# local-path-storage                  local-path-provisioner-547f784dff-rncr2                          1/1     Running   0          40m


#generate the cluster configuration
clusterctl generate cluster pradeepl-cluster --kubernetes-version v1.22.0 --control-plane-machine-count=3 --worker-machine-count=3  > pradeep-capz-cluster.yaml


# >cat pradeep-capz-cluster.yaml
# apiVersion: cluster.x-k8s.io/v1beta1
# kind: Cluster
# metadata:
#   labels:
#     cni: calico
#   name: pradeepl-cluster
#   namespace: default
# spec:
#   clusterNetwork:
#     pods:
#       cidrBlocks:
#       - 192.168.0.0/16
#   controlPlaneRef:
#     apiVersion: controlplane.cluster.x-k8s.io/v1beta1
#     kind: KubeadmControlPlane
#     name: pradeepl-cluster-control-plane
#   infrastructureRef:
#     apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
#     kind: AzureCluster
#     name: pradeepl-cluster
# ---
# apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
# kind: AzureCluster
# metadata:
#   name: pradeepl-cluster
#   namespace: default
# spec:
#   identityRef:
#     apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
#     kind: AzureClusterIdentity
#     name: cluster-identity
#   location: eastus
#   networkSpec:
#     subnets:
#     - name: control-plane-subnet
#       role: control-plane
#     - name: node-subnet
#       natGateway:
#         name: node-natgateway
#       role: node
#     vnet:
#       name: pradeepl-cluster-vnet
#   resourceGroup: pradeepl-cluster
#   subscriptionID: d084e879-5a0c-4401-861d-9b4b0436771b
# ---
# apiVersion: controlplane.cluster.x-k8s.io/v1beta1
# kind: KubeadmControlPlane
# metadata:
#   name: pradeepl-cluster-control-plane
#   namespace: default
# spec:
#   kubeadmConfigSpec:
#     clusterConfiguration:
#       apiServer:
#         extraArgs:
#           cloud-config: /etc/kubernetes/azure.json
#           cloud-provider: azure
#         extraVolumes:
#         - hostPath: /etc/kubernetes/azure.json
#           mountPath: /etc/kubernetes/azure.json
#           name: cloud-config
#           readOnly: true
#         timeoutForControlPlane: 20m
#       controllerManager:
#         extraArgs:
#           allocate-node-cidrs: "false"
#           cloud-config: /etc/kubernetes/azure.json
#           cloud-provider: azure
#           cluster-name: pradeepl-cluster
#         extraVolumes:
#         - hostPath: /etc/kubernetes/azure.json
#           mountPath: /etc/kubernetes/azure.json
#           name: cloud-config
#           readOnly: true
#       etcd:
#         local:
#           dataDir: /var/lib/etcddisk/etcd
#           extraArgs:
#             quota-backend-bytes: "8589934592"
#     diskSetup:
#       filesystems:
#       - device: /dev/disk/azure/scsi1/lun0
#         extraOpts:
#         - -E
#         - lazy_itable_init=1,lazy_journal_init=1
#         filesystem: ext4
#         label: etcd_disk
#       - device: ephemeral0.1
#         filesystem: ext4
#         label: ephemeral0
#         replaceFS: ntfs
#       partitions:
#       - device: /dev/disk/azure/scsi1/lun0
#         layout: true
#         overwrite: false
#         tableType: gpt
#     files:
#     - contentFrom:
#         secret:
#           key: control-plane-azure.json
#           name: pradeepl-cluster-control-plane-azure-json
#       owner: root:root
#       path: /etc/kubernetes/azure.json
#       permissions: "0644"
#     initConfiguration:
#       nodeRegistration:
#         kubeletExtraArgs:
#           azure-container-registry-config: /etc/kubernetes/azure.json
#           cloud-config: /etc/kubernetes/azure.json
#           cloud-provider: azure
#         name: '{{ ds.meta_data["local_hostname"] }}'
#     joinConfiguration:
#       nodeRegistration:
#         kubeletExtraArgs:
#           azure-container-registry-config: /etc/kubernetes/azure.json
#           cloud-config: /etc/kubernetes/azure.json
#           cloud-provider: azure
#         name: '{{ ds.meta_data["local_hostname"] }}'
#     mounts:
#     - - LABEL=etcd_disk
#       - /var/lib/etcddisk
#     postKubeadmCommands: []
#     preKubeadmCommands: []
#   machineTemplate:
#     infrastructureRef:
#       apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
#       kind: AzureMachineTemplate
#       name: pradeepl-cluster-control-plane
#   replicas: 3
#   version: v1.22.0
# ---
# apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
# kind: AzureMachineTemplate
# metadata:
#   name: pradeepl-cluster-control-plane
#   namespace: default
# spec:
#   template:
#     spec:
#       dataDisks:
#       - diskSizeGB: 256
#         lun: 0
#         nameSuffix: etcddisk
#       osDisk:
#         diskSizeGB: 128
#         osType: Linux
#       sshPublicKey: ""
#       vmSize: Standard_D2s_v3
# ---
# apiVersion: cluster.x-k8s.io/v1beta1
# kind: MachineDeployment
# metadata:
#   name: pradeepl-cluster-md-0
#   namespace: default
# spec:
#   clusterName: pradeepl-cluster
#   replicas: 3
#   selector:
#     matchLabels: null
#   template:
#     spec:
#       bootstrap:
#         configRef:
#           apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
#           kind: KubeadmConfigTemplate
#           name: pradeepl-cluster-md-0
#       clusterName: pradeepl-cluster
#       infrastructureRef:
#         apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
#         kind: AzureMachineTemplate
#         name: pradeepl-cluster-md-0
#       version: v1.22.0
# ---
# apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
# kind: AzureMachineTemplate
# metadata:
#   name: pradeepl-cluster-md-0
#   namespace: default
# spec:
#   template:
#     spec:
#       osDisk:
#         diskSizeGB: 128
#         osType: Linux
#       sshPublicKey: ""
#       vmSize: Standard_D2s_v3
# ---
# apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
# kind: KubeadmConfigTemplate
# metadata:
#   name: pradeepl-cluster-md-0
#   namespace: default
# spec:
#   template:
#     spec:
#       files:
#       - contentFrom:
#           secret:
#             key: worker-node-azure.json
#             name: pradeepl-cluster-md-0-azure-json
#         owner: root:root
#         path: /etc/kubernetes/azure.json
#         permissions: "0644"
#       joinConfiguration:
#         nodeRegistration:
#           kubeletExtraArgs:
#             azure-container-registry-config: /etc/kubernetes/azure.json
#             cloud-config: /etc/kubernetes/azure.json
#             cloud-provider: azure
#           name: '{{ ds.meta_data["local_hostname"] }}'
#       preKubeadmCommands: []
# ---
# apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
# kind: AzureClusterIdentity
# metadata:
#   labels:
#     clusterctl.cluster.x-k8s.io/move-hierarchy: "true"
#   name: cluster-identity
#   namespace: default
# spec:
#   allowedNamespaces: {}
#   clientID: 4eadf6f2-6465-4955-bd49-40400067c9d5
#   clientSecret:
#     name: cluster-identity-secret
#     namespace: default
#   tenantID: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
#   type: ServicePrincipal


kubectl apply -f pradeep-capz-cluster.yaml

# cluster.cluster.x-k8s.io/pradeepl-cluster created
# azurecluster.infrastructure.cluster.x-k8s.io/pradeepl-cluster created
# kubeadmcontrolplane.controlplane.cluster.x-k8s.io/pradeepl-cluster-control-plane created
# azuremachinetemplate.infrastructure.cluster.x-k8s.io/pradeepl-cluster-control-plane created
# machinedeployment.cluster.x-k8s.io/pradeepl-cluster-md-0 created
# azuremachinetemplate.infrastructure.cluster.x-k8s.io/pradeepl-cluster-md-0 created
# kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/pradeepl-cluster-md-0 created
# azureclusteridentity.infrastructure.cluster.x-k8s.io/cluster-identity created

az group list -o table
Name                               Location       Status
---------------------------------  -------------  ---------
pradeepl-cluster                   eastus         Succeeded
cloud-shell-storage-southeastasia  southeastasia  Succeeded
NetworkWatcherRG                   australiaeast  Succeeded

az resource list -g pradeepl-cluster -o table
# Name                                      ResourceGroup     Location    Type                                     Status
# ----------------------------------------  ----------------  ----------  ---------------------------------------  --------
# pradeepl-cluster-vnet                     pradeepl-cluster  eastus      Microsoft.Network/virtualNetworks
# pradeepl-cluster-controlplane-nsg         pradeepl-cluster  eastus      Microsoft.Network/networkSecurityGroups
# pradeepl-cluster-node-nsg                 pradeepl-cluster  eastus      Microsoft.Network/networkSecurityGroups
# pradeepl-cluster-node-routetable          pradeepl-cluster  eastus      Microsoft.Network/routeTables
# pip-pradeepl-cluster-apiserver            pradeepl-cluster  eastus      Microsoft.Network/publicIPAddresses
# pip-pradeepl-cluster-node-subnet-natgw    pradeepl-cluster  eastus      Microsoft.Network/publicIPAddresses
# node-natgateway                           pradeepl-cluster  eastus      Microsoft.Network/natGateways
# pradeepl-cluster-public-lb                pradeepl-cluster  eastus      Microsoft.Network/loadBalancers
# pradeepl-cluster-control-plane-n24kv-nic  pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces


az resource list -g pradeepl-cluster -o table
# Name                                                           ResourceGroup     Location    Type                                          Status
# -------------------------------------------------------------  ----------------  ----------  --------------------------------------------  --------
# pradeepl-cluster-vnet                                          pradeepl-cluster  eastus      Microsoft.Network/virtualNetworks
# pradeepl-cluster-controlplane-nsg                              pradeepl-cluster  eastus      Microsoft.Network/networkSecurityGroups
# pradeepl-cluster-node-nsg                                      pradeepl-cluster  eastus      Microsoft.Network/networkSecurityGroups
# pradeepl-cluster-node-routetable                               pradeepl-cluster  eastus      Microsoft.Network/routeTables
# pip-pradeepl-cluster-apiserver                                 pradeepl-cluster  eastus      Microsoft.Network/publicIPAddresses
# pip-pradeepl-cluster-node-subnet-natgw                         pradeepl-cluster  eastus      Microsoft.Network/publicIPAddresses
# node-natgateway                                                pradeepl-cluster  eastus      Microsoft.Network/natGateways
# pradeepl-cluster-public-lb                                     pradeepl-cluster  eastus      Microsoft.Network/loadBalancers
# pradeepl-cluster-control-plane-n24kv-nic                       pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-control-plane-n24kv                           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-control-plane-n24kv_OSDisk                    PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-n24kv_etcddisk                  PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-n24kv/CAPZ.Linux.Bootstrapping  pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions
# pradeepl-cluster-md-0-jv86m-nic                                pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-md-0-zlw9q-nic                                pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-md-0-547cl-nic                                pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-md-0-jv86m                                    pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-md-0-zlw9q                                    pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-md-0-547cl                                    pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-md-0-jv86m_OSDisk                             PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-md-0-547cl_OSDisk                             PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-md-0-zlw9q_OSDisk                             PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-whq5x-nic                       pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-control-plane-whq5x                           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-control-plane-whq5x_etcddisk                  PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-whq5x_OSDisk                    PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-md-0-jv86m/CAPZ.Linux.Bootstrapping           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions
# pradeepl-cluster-md-0-547cl/CAPZ.Linux.Bootstrapping           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions
# pradeepl-cluster-md-0-zlw9q/CAPZ.Linux.Bootstrapping           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions
# pradeepl-cluster-control-plane-whq5x/CAPZ.Linux.Bootstrapping  pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions
# pradeepl-cluster-control-plane-qcjcx-nic                       pradeepl-cluster  eastus      Microsoft.Network/networkInterfaces
# pradeepl-cluster-control-plane-qcjcx                           pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines
# pradeepl-cluster-control-plane-qcjcx_OSDisk                    PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-qcjcx_etcddisk                  PRADEEPL-CLUSTER  eastus      Microsoft.Compute/disks
# pradeepl-cluster-control-plane-qcjcx/CAPZ.Linux.Bootstrapping  pradeepl-cluster  eastus      Microsoft.Compute/virtualMachines/extensions


kubectl get cluster
# NAME               PHASE         AGE   VERSION
# pradeepl-cluster   Provisioned   25m   




clusterctl describe cluster pradeepl-cluster

# NAME                                                                 READY  SEVERITY  REASON                       SINCE  MESSAGE                                                                              
# /pradeepl-cluster                                                    True                                          16m                                                                                         
# ├─ClusterInfrastructure - AzureCluster/pradeepl-cluster              True                                          24m                                                                                         
# ├─ControlPlane - KubeadmControlPlane/pradeepl-cluster-control-plane  True                                          16m                                                                                         
# │ └─3 Machines...                                                    True                                          21m    See pradeepl-cluster-control-plane-cxrlg, pradeepl-cluster-control-plane-dslrs, ...  
# └─Workers                                                                                                                                                                                                      
#   └─MachineDeployment/pradeepl-cluster-md-0                          False  Warning   WaitingForAvailableMachines  26m    Minimum availability requires 3 replicas, current 0 available                        
#     └─3 Machines...                                                  True                                          20m    See pradeepl-cluster-md-0-df59c5897-8lv6j, pradeepl-cluster-md-0-df59c5897-f2rrs,

#verify the first control plane is up and running
kubectl get kubeadmcontrolplane

# NAME                             CLUSTER            INITIALIZED   API SERVER AVAILABLE   REPLICAS   READY   UPDATED   UNAVAILABLE   AGE   VERSION
# pradeepl-cluster-control-plane   pradeepl-cluster   true                                 3                  3         3             30m   v1.22.0

#Retrieve the workload cluster Kubeconfig
clusterctl get kubeconfig pradeepl-cluster > pradeepl-cluster.kubeconfig

# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM2akNDQWRLZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1USXdOakV3TVRNd01Wb1hEVE14TVRJd05ERXdNVGd3TVZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUVXCk9IVmc4aytsb20xR3QzZUh3RVJmYVpJL2lMUlVER2t5QStORjQvNjkxK2h2aTFFMGJKMVR0UU5XNThhaTBaK2wKazNsWmtWSHNvMllEaE5MZWJYem9WbVZVYjNRd09VRXZSYmxUaW1iVFozck1ISWJsV2JyaGV0UTZ2V0dBSU9pbQp4bmdwaW5oQnNrK1NLUk03U1VmK294R2MraDN5QUI3RGh1dkpoWndGQjFBSWVjc1cweEVaQldxUkxPbFNDVDhlCm5OZDFGeG9ma282b3VORldpaVpNWDFxNExKMnNWOTBCRkNibmdKTTV1UnVMMDNTN0dwZFoyaEFGN3NtUmtPNW4KSGc3L1p4NEc2WU13dDIyVUh0MmwzSG5MSFRRb2ZWNkpFYkg4K2JoMmx1VTdJTldNa1B6R1VhNHpMRFExM1RJRwprYnVHMUtQSXB2N052czY1aFNNQ0F3RUFBYU5GTUVNd0RnWURWUjBQQVFIL0JBUURBZ0trTUJJR0ExVWRFd0VCCi93UUlNQVlCQWY4Q0FRQXdIUVlEVlIwT0JCWUVGSUhNNlVCZEhnK1NGTmZDaFVIb2h2UUJDaGxmTUEwR0NTcUcKU0liM0RRRUJDd1VBQTRJQkFRQzVjN1RYRWdJemJMekp4VEd0TzhtdkxOM2VvcGU1V1lyVUkrV2VoKzdsVENwMQp0VGdmeVRVWWRNcXRKWmJyeG1BZjVvc2ZnT1JLWmJvVlJ4T3NJZGdZNzQxVDRCSnk2dDA0MVFoM05sNjd1RlpTCmRnSlUzSEFTWEUxU2I0ZTBPbEs3YVhkcFk5emFReU1CMEJiVStTNWVmQUloRnQ4dm9KOUtJNWs5SVRERXlEY00KMS9VOHBvcVl0KzZHM0c3TEdsSzZaZm5RNnFIK055dWtsYk9qL0FlUllpM09iYXIvT00vd0xKVm5QQmdacDZwaApwVzEyc1Nmd1NyU1h0OXVFVXA4M3ZVWXVVdW5SWHB6UG1JNmJBcG1HeVBpMVFjNlFXQmhTNWh1azE5bURLMXhJCnZVZ2ttNXd4TXZxdFgyc0QvejJ1czdVazUrUU9BVnNaVm9sQUdmR3AKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
#     server: https://pradeepl-cluster-358cdd06.eastus.cloudapp.azure.com:6443
#   name: pradeepl-cluster
# contexts:
# - context:
#     cluster: pradeepl-cluster
#     user: pradeepl-cluster-admin
#   name: pradeepl-cluster-admin@pradeepl-cluster
# current-context: pradeepl-cluster-admin@pradeepl-cluster
# kind: Config
# preferences: {}
# users:
# - name: pradeepl-cluster-admin
#   user:
#     client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURFekNDQWZ1Z0F3SUJBZ0lJYnhrYUMrdVVEYk13RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0Ex
                                # VUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TVRFeU1EWXhNREV6TURGYUZ3MHlNakV5TURZeE1ERTRNREZhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJU
                                # cHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQ
                                # TRNWjhJSDZ0VXpjNnZuQ2gKcDVRRWYyOWl1emlPeHlIUlo2UWJrM0JWOGV5OXhVTTdoUnp3OHp4NHZMSnFaeUQrNDJOZFlocm9oQnhrczZXRwpHSmlvWEF1V3
                                # NZa2FhZk9KRjFTT1pqT0JxNGdPSS9GUVhhd2JucWtPR283bFZTTXU5bDhYOEJwdDM4RVJxak5tClVwb2dMMkVUZ0FZeGZVZ0t6enNWcVRpT01UZnVGcGJsN0tC
                                # anRvVnQzd3d5MDBaUmJwcjlLdUIvbkpQdWcwb3QKMmR5TlpFaVZkeDhTTHozZUdPc2ZnWkF6Tkx3VHhRYjRodkR1YUVnZEVaWEZLWlAzQmNNZWVMQ2N5WjVrNG
                                # 5mNwpOUVRDVEJaRWFGL1V1ZnIxeHQxcG9GS29vcmRIb3hpbndhL09PNEVhRlo0YXo5R3cwU29YeXcyRDhTeUU2Z2dXClNMUEtId0lEQVFBQm8wZ3dSakFPQmdOV
                                # khROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0h3WURWUjBqQkJnd0ZvQVVnY3pwUUYwZUQ1SVUxOEtGUWVpRzlBRUtHVjh3RFFZ
                                # SktvWklodmNOQVFFTApCUUFEZ2dFQkFJZDFQeVJjRHExL25UNTlkRVlEcEVaR1MrdEU0bHV2bHV3WkVaVW9lalRhMy9EcUQyNmNHdXB3CjVPaFdSekhOSTRCN2NP
                                # TURMM2padmlOWXVMNVRac3p4WDBRWWlGNTRBSXhJeHpRdmV5T0IraHcyalI5cnloalMKRm1ha2x6YndOTm43alpOQXNsMjJITjl1am5saWFOVlhFRnNiR2crTCtNQ
                                # 2dGZmRMc3owV2F5NVlmSXV5M05ucApYZUVzNDZvR2J3WGVSYUNTM1JsNXNXMHIydFFzQWFaaThSdGNTZk9CVGNYejJLQTBYS3M0YmVuUWw2RHNtYUJiCm5vYUVzRFd
                                # yeW42N0d1RDV5cjIyQS8ySzJ0UlpqazU4RUhGaDFtVUpqc29Ob04wVGJIVnB4TmV3dVlYaXFYODUKamM5ZnVSTVViRW12Rmh1U3UrcWxUbmpQVlQ4NWpvcz0KLS0tLS
                                # 1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
#     client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcGdJQkFBS0NBUUVBNE1aOElINnRVemM2dm5DaHA1UUVmMjlpdXppT3h5SFJaNlFiazNCVjhleTl4VU03CmhSenc4eng
# 0dkxKcVp5RCs0Mk5kWWhyb2hCeGtzNldHR0ppb1hBdVdzWWthYWZPSkYxU09aak9CcTRnT0kvRlEKWGF3Ym5xa09HbzdsVlNNdTlsOFg4QnB0MzhFUnFqTm1VcG9nTDJFVGdBWXhmVWdLenpzVnFUaU9NVGZ1RnBibAo
# 3S0JqdG9WdDN3d3kwMFpSYnByOUt1Qi9uSlB1ZzBvdDJkeU5aRWlWZHg4U0x6M2VHT3NmZ1pBek5Md1R4UWI0Cmh2RHVhRWdkRVpYRktaUDNCY01lZUxDY3laNWs0bmY3TlFUQ1RCWkVhRi9VdWZyMXh0MXBvRktvb
# 3JkSG94aW4Kd2EvT080RWFGWjRhejlHdzBTb1h5dzJEOFN5RTZnZ1dTTFBLSHdJREFRQUJBb0lCQVFDTlpzLzNjVG1BUENKTQpZM2FPZ1dOQzk4TlltLy9WN2NSYU9yYk9UY0VEYkRjRnZZSFgvNWprcTRvWXl2Ujg1Qmow
# MnpHSDRmMmIvbkNyClF0blU1MVFpYzNmZFA2N0tNRlp4d3RQQ0gyelhoOE85Z0xWWitFZDN6RW4vRXgzYUxVUUI0VmloeHo2UG9GbUkKaE1VOStZOTl2c2dScGRQRVNHbmthL3I0ZFllZUZhOVNGYlpOTzNFbUtNSm5oW
# lZoeGZPZEV6eks2RU44SDhQdgp4RUI1VkdJeldULzhleHpuaithNEdRNlJLYVdpZHlCK3dlTERHaGtNRkhCUEM3YjBvZ1IvTTUzNWZOdFJ3bC9YCmlqR0kxUTBmaVZjUEdwM3JaSHRBbzFXZnlJcVU5MFJZd0U3ZGc3VWs2R
# EdJVDIybGpZc0czRkhlZTEraUt1VG8KZnVxSVdkaGhBb0dCQU9peXA2RTJPNU9MOFZTcDdpbFZFYzBvUXJITDlVYk1sRkZsTGQ5YXlMZmw2Nnh6U1dWUApxN2x4WkxVT2lSWWZmWTdVNy9YbWhqUlJKT3FEZlhsMC84czRTUG1
# lQnVtSkFaWFJKcWk0dE8yQnlQNWo2UmtOCmNzdWhkOEdIcWlodHdMWHZ4VHlnb0Z6MUpjd3VVWUhUbjhsZWtHckQyQmtUSlNTWmk3aTJjY1VsQW9HQkFQZEkKdXk2S0JmR3BndFU1dkxmYkxRNk5GdFlHY082ZTJZbVpKNEhBUz
# U4elZSRFJtQkhZajh0V3V1ZmRaOG5nYjFzeQovTDlpcW1KczVHR05BSDB0OUJ4K3hETzVsaXhFN0hwQ3RQQlBIY3Zlcy9YZE5jMHlYY0FvVmpHVHlmM3N4aUM5ClRuUVBMNm8vaXZvbCs2bzNYT1RwWnUycHFiZmcrQUh2aTlJSj
# hvanpBb0dCQUovdVlqM3YyMFNPYzBDQVJwc0wKeDk5Y1kzSjF2czk1UGhzdlVqYm4yM3BoUVBoV2lFUmtYSjlvNnhGeHV4Q0VkalJiNzh6dk1wLzBnVTNaTDd6eApoL2t4Wng2QTJUbGJHOGJQYUNXZ1JXSFR5TVBuQVVkaHNkdDR
# 6NmtveCs5ZmQ0clVENWlhd1gwQ1ZJY2Y4bzhyClZ1LzgyWDgzdVdlS2ZBWEtybmcybEwwdEFvR0JBUENWT1U5NUIzbHJjeGVpT2NJaW9qNkM5Qkc4YUlrdjBQTjMKSnlHc2hhWlkyYzBvTGF4SEp2Y3M1V0VLWHB6aEYxWUNVRGFm
# ZHFlVnk4aEExNVh5YklxQXBzQ3dNYlBXUnNCWQpRQk9BMWJ0d2EyT3NHVmtQUkhqY2hhZHNZdHdDVFd5eTRTNDNUQ2QxOU8rVW5ybW5iV0JrMkRnbmxqQ0kxcUdECmZtUVdPM29UQW9HQkFJUWVGY241NWlvb1Fta3oxSmc4cVlGVk
# VPcUVQMGxyWXJmbnZGSUlvdU1VUzMzdXFYRmoKTzBaKzVacXpJNnlGUDFxM2Qra2ptUHQ0SjgrTEJ0N2NOK0hXRnNJRVZqczl5QTAwQlF4Z3hVUlVMRWZtbmZ5MApKZEJyeFB1MU13TDZpYVM5bTFQcFA0M25xU0M0SjhBbzV0RFls
# UDlyZXcwZ2toSkxFNHd5RkdEZgotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=


#Deploy a CNI solution - Azure does not currently support Calico networking. As a workaround, it is recommended that Azure clusters use the Calico spec below that uses VXLAN.

# kubectl --kubeconfig=./pradeepl-cluster.kubeconfig \
#   apply -f https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-azure/main/templates/addons/calico.yaml

# configmap/calico-config created
# customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
# customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
# clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
# clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
# clusterrole.rbac.authorization.k8s.io/calico-node created
# clusterrolebinding.rbac.authorization.k8s.io/calico-node created
# daemonset.apps/calico-node created
# serviceaccount/calico-node created
# deployment.apps/calico-kube-controllers created
# serviceaccount/calico-kube-controllers created
# Warning: policy/v1beta1 PodDisruptionBudget is deprecated in v1.21+, unavailable in v1.25+; use policy/v1 PodDisruptionBudget
# poddisruptionbudget.policy/calico-kube-controllers created


clusterctl describe cluster pradeepl-cluster
# NAME                                                                 READY  SEVERITY  REASON  SINCE  MESSAGE                                                                              
# /pradeepl-cluster                                                    True                     27m                                                                                         
# ├─ClusterInfrastructure - AzureCluster/pradeepl-cluster              True                     35m                                                                                         
# ├─ControlPlane - KubeadmControlPlane/pradeepl-cluster-control-plane  True                     27m                                                                                         
# │ └─3 Machines...                                                    True                     32m    See pradeepl-cluster-control-plane-cxrlg, pradeepl-cluster-control-plane-dslrs, ...  
# └─Workers                                                                                                                                                                                 
#   └─MachineDeployment/pradeepl-cluster-md-0                          True                     20s                                                                                         
#     └─3 Machines...                                                  True                     31m    See pradeepl-cluster-md-0-df59c5897-8lv6j, pradeepl-cluster-md-0-df59c5897-f2rrs, ...

kubectl --kubeconfig=./pradeepl-cluster.kubeconfig get nodes

# NAME                                   STATUS   ROLES                  AGE   VERSION
# pradeepl-cluster-control-plane-n24kv   Ready    control-plane,master   35m   v1.22.0
# pradeepl-cluster-control-plane-qcjcx   Ready    control-plane,master   30m   v1.22.0
# pradeepl-cluster-control-plane-whq5x   Ready    control-plane,master   32m   v1.22.0
# pradeepl-cluster-md-0-547cl            Ready    <none>                 33m   v1.22.0
# pradeepl-cluster-md-0-jv86m            Ready    <none>                 33m   v1.22.0
# pradeepl-cluster-md-0-zlw9q            Ready    <none>                 33m   v1.22.0


kubectl describe cluster
# Name:         pradeepl-cluster
# Namespace:    default
# Labels:       cni=calico
# Annotations:  <none>
# API Version:  cluster.x-k8s.io/v1beta1
# Kind:         Cluster
# Metadata:
#   Creation Timestamp:  2021-12-06T10:16:11Z
#   Finalizers:
#     cluster.cluster.x-k8s.io
#   Generation:  2
#   Managed Fields:
#     API Version:  cluster.x-k8s.io/v1beta1
#     Fields Type:  FieldsV1
#     fieldsV1:
#       f:metadata:
#         f:annotations:
#           .:
#           f:kubectl.kubernetes.io/last-applied-configuration:
#         f:labels:
#           .:
#           f:cni:
#       f:spec:
#         .:
#         f:clusterNetwork:
#           .:
#           f:pods:
#             .:
#             f:cidrBlocks:
#         f:controlPlaneRef:
#           .:
#           f:apiVersion:
#           f:kind:
#           f:name:
#         f:infrastructureRef:
#           .:
#           f:apiVersion:
#           f:kind:
#           f:name:
#     Manager:      kubectl-client-side-apply
#     Operation:    Update
#     Time:         2021-12-06T10:16:11Z
#     API Version:  cluster.x-k8s.io/v1beta1
#     Fields Type:  FieldsV1
#     fieldsV1:
#       f:metadata:
#         f:finalizers:
#           .:
#           v:"cluster.cluster.x-k8s.io":
#       f:spec:
#         f:controlPlaneEndpoint:
#           f:host:
#           f:port:
#       f:status:
#         .:
#         f:conditions:
#         f:controlPlaneReady:
#         f:failureDomains:
#           .:
#           f:1:
#             .:
#             f:controlPlane:
#           f:2:
#             .:
#             f:controlPlane:
#           f:3:
#             .:
#             f:controlPlane:
#         f:infrastructureReady:
#         f:observedGeneration:
#         f:phase:
#     Manager:         manager
#     Operation:       Update
#     Time:            2021-12-06T10:53:29Z
#   Resource Version:  56671
#   UID:               e4b6a7b2-10ba-4820-bd0f-ba40c4d95008
# Spec:
#   Cluster Network:
#     Pods:
#       Cidr Blocks:
#         192.168.0.0/16
#   Control Plane Endpoint:
#     Host:  pradeepl-cluster-358cdd06.eastus.cloudapp.azure.com
#     Port:  6443
#   Control Plane Ref:
#     API Version:  controlplane.cluster.x-k8s.io/v1beta1
#     Kind:         KubeadmControlPlane
#     Name:         pradeepl-cluster-control-plane
#     Namespace:    default
#   Infrastructure Ref:
#     API Version:  infrastructure.cluster.x-k8s.io/v1beta1
#     Kind:         AzureCluster
#     Name:         pradeepl-cluster
#     Namespace:    default
# Status:
#   Conditions:
#     Last Transition Time:  2021-12-06T10:26:14Z
#     Status:                True
#     Type:                  Ready
#     Last Transition Time:  2021-12-06T10:20:13Z
#     Status:                True
#     Type:                  ControlPlaneInitialized
#     Last Transition Time:  2021-12-06T10:26:14Z
#     Status:                True
#     Type:                  ControlPlaneReady
#     Last Transition Time:  2021-12-06T10:18:00Z
#     Status:                True
#     Type:                  InfrastructureReady
#   Control Plane Ready:     true
#   Failure Domains:
#     1:
#       Control Plane:  true
#     2:
#       Control Plane:  true
#     3:
#       Control Plane:     true
#   Infrastructure Ready:  true
#   Observed Generation:   2
#   Phase:                 Provisioned
# Events:                  <none>

# Delete the azure infrastructure provider except the hosting namespace and the CRD's

clusterctl delete --infrastructure azure
# Deleting Provider="infrastructure-azure" Version="" Namespace="capz-system"

# NAMESPACE                           NAME                                                             READY   STATUS        RESTARTS   AGE
# capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-58945b95bf-87lvj       1/1     Running       1          20h
# capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-58fc8f8c7c-9w5pm   1/1     Running       2          20h
# capi-system                         capi-controller-manager-576744d8b7-8rwsn                         1/1     Running       2          20h
# capz-system                         capz-nmi-svrht                                                   1/1     Terminating   1          20h
# cert-manager                        cert-manager-848f547974-82nx2                                    1/1     Running       1          20h
# cert-manager                        cert-manager-cainjector-54f4cc6b5-qrnxf                          1/1     Running       2          20h
# cert-manager                        cert-manager-webhook-7c9588c76-lwqwg                             1/1     Running       1          20h
# kube-system                         coredns-558bd4d5db-98vmp                                         1/1     Running       1          20h
# kube-system                         coredns-558bd4d5db-jw58j                                         1/1     Running       1          20h
# kube-system                         etcd-kind-control-plane                                          1/1     Running       1          20h
# kube-system                         kindnet-b4622                                                    1/1     Running       1          20h
# kube-system                         kube-apiserver-kind-control-plane                                1/1     Running       1          20h
# kube-system                         kube-controller-manager-kind-control-plane                       1/1     Running       1          20h
# kube-system                         kube-proxy-95wg5                                                 1/1     Running       1          20h
# kube-system                         kube-scheduler-kind-control-plane                                1/1     Running       1          20h
# local-path-storage                  local-path-provisioner-547f784dff-rncr2                          1/1     Running       2          20h

❯ clusterctl delete --all
Deleting Provider="bootstrap-kubeadm" Version="v1.0.1" Namespace="capi-kubeadm-bootstrap-system"
Deleting Provider="control-plane-kubeadm" Version="v1.0.1" Namespace="capi-kubeadm-control-plane-system"

kubectl get pods -A
# NAMESPACE                           NAME                                                             READY   STATUS        RESTARTS   AGE
# capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-58945b95bf-87lvj       0/1     Terminating   1          20h
# capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-58fc8f8c7c-9w5pm   0/1     Terminating   2          20h
# cert-manager                        cert-manager-848f547974-82nx2                                    1/1     Running       1          20h
# cert-manager                        cert-manager-cainjector-54f4cc6b5-qrnxf                          1/1     Running       2          20h
# cert-manager                        cert-manager-webhook-7c9588c76-lwqwg                             1/1     Running       1          20h
# kube-system                         coredns-558bd4d5db-98vmp                                         1/1     Running       1          20h
# kube-system                         coredns-558bd4d5db-jw58j                                         1/1     Running       1          20h
# kube-system                         etcd-kind-control-plane                                          1/1     Running       1          20h
# kube-system                         kindnet-b4622                                                    1/1     Running       1          20h
# kube-system                         kube-apiserver-kind-control-plane                                1/1     Running       1          20h
# kube-system                         kube-controller-manager-kind-control-plane                       1/1     Running       1          20h
# kube-system                         kube-proxy-95wg5                                                 1/1     Running       1          20h
# kube-system                         kube-scheduler-kind-control-plane                                1/1     Running       1          20h
# local-path-storage                  local-path-provisioner-547f784dff-rncr2                          1/1     Running       2          20h


az group delete -n pradeepl-cluster
Are you sure you want to perform this operation? (y/n): y
 / Running ..