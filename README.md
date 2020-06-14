----------------------------------------------------------
# Azure Kubernetes Services (AKS) - Application Gateway Ingress Controller (AGIC) configured with Lets Encrypt Certificate and Azure DNS Zone

High Level Architecture Diagram:

![Image description](https://github.com/GBuenaflor/01azure-aks-ingresscontroller-agic/blob/master/GB-AKS-Ingress-AGIC00.png)


Configuration Flow :

1. Create new AKS Cluster (with Advance Networking) and ApplicationGateway (using Azure Terraform)
    

2. Create new DNS Zone

------------------------------------------------------------------------------

- Create new DNS Zone

az network dns zone create \
  --resource-group Dev01-RG \
  --name aks01-web.iomdev.net
 
- Query The DNS ZOne

az network dns zone show \
  --resource-group Dev01-aks01-RG \
  --name aks01-web.iomdev.net \
  --query nameServers

------------------------------------------------------------------------------

3. Install Azure AD Pod Identity

----------------------------------------------------------
 
- Check RBAC -Enabled in the AKS Cluster?
az resource show --resource-group "Dev01-APIG-RG" --name az-k8s --resource-type Microsoft.ContainerService/ManagedClusters --query properties.enableRBAC
 
 
- Install Azure AD Pod Identity,  If RBAC is disabled
kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment.yaml
  
----------------------------------------------------------

4. Install Helm and Install AGIC using Helm

----------------------------------------------------------

- Install Helm, If RBAC is disabled
helm init


- Add the AGIC Helm repository
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update

- Install Ingress Controller Helm Chart

- Download helm-config.yaml to configure AGIC:
wget https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/sample-helm-config.yaml -O helm-config.yaml
 

- Edit the helm-config.yaml File
code helm-config.yaml

----------------------------------------------------------
    
5. Install the Application Gateway ingress controller package:


----------------------------------------------------------

- Connect to the Kubernetes Cluster
az aks get-credentials --resource-group Dev01-aks02-RG --name az-k8s


- Install the Application Gateway ingress controller package:
helm install -f helm-config.yaml application-gateway-kubernetes-ingress/ingress-azure --generate-name

----------------------------------------------------------

6. Configure Cert Manager

----------------------------------------------------------
   
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml

helm install cert-manager \
    --namespace cert-manager \
    --version v0.14.0 \
    jetstack/cert-manager

kubectl get pods --namespace cert-manager

----------------------------------------------------------

7. Add new A Record in new DNS Zone , Get the Application Gateway Public IP

----------------------------------------------------------

az network dns record-set a add-record \
    --resource-group Dev01-RG \
    --zone-name aks01-web.iomdev.net \
    --record-set-name '*' \
    --ipv4-address 52.224.130.28

----------------------------------------------------------

8. Add CAA  Certificate Authority Authentication using Power Shell


----------------------------------------------------------

$zoneName="aks01-web.iomdev.net"
$resourcegroup="Dev01-RG"
$addcaarecord= @()
$addcaarecord+=New-AzDnsRecordConfig -Caaflags 0 -CaaTag "issue" -CaaValue "letsencrypt.org"
$addcaarecord+=New-AzDnsRecordConfig -Caaflags 0 -CaaTag "iodef" -CaaValue "mailto:gbuenaflor@iom.int"
$addcaarecord = New-AzDnsRecordSet -Name "@" -RecordType CAA -ZoneName $zoneName -ResourceGroupName $resourcegroup -Ttl 3600 -DnsRecords ($addcaarecord)
 
----------------------------------------------------------

9. Configure Cert-Manager using Azure DNS , this will be use in 02clusterIsuer.yaml file
   https://cert-manager.io/docs/configuration/acme/dns01/azuredns/


10. Deploy the Kubernentes Files
    
kubectl apply --namespace default -f "01webandsql.yaml"
kubectl apply --namespace default -f "02clusterIsuer.yaml"
kubectl apply --namespace default -f "03Ingress.yaml"


11. Test The Web Application and view the results
 

![Image description](https://github.com/GBuenaflor/01azure-aks-ingresscontroller-agic/blob/master/GB-AKS-Ingress-AGIC01.png)


View the Application Gateway and Azure DNS Zone


![Image description](https://github.com/GBuenaflor/01azure-aks-ingresscontroller-agic/blob/master/GB-AKS-Ingress-AGIC02.png)


View the Kubernetes DashBoard (Ingress,Deployments,and Config Maps)


![Image description](https://github.com/GBuenaflor/01azure-aks-ingresscontroller-agic/blob/master/GB-AKS-Ingress-AGIC03.png)




Note: My Favorite > Microsoft Technologies.