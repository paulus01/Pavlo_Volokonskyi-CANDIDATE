#https://cert-manager.io/v1.11-docs/tutorials/getting-started-aks-letsencrypt/

cd ./cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade cert-manager jetstack/cert-manager \
    --install \
    --create-namespace \
    --wait \
    --namespace cert-manager \
    --set installCRDs=true \ 
    -f values.yaml

kubectl apply -f clusterissuer-selfsigned.yaml

