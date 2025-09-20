kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds?ref=stable

ARGOCD_NAMESPACE="argocd" # e.g. argo-cd
ARGOCD_RELEASENAME="bootstrap" # e.g. argo-cd
REPO_DIR="/tmp/$ARGOCD_RELEASENAME"

for crd in "applications.argoproj.io" "applicationsets.argoproj.io" "appprojects.argoproj.io"; do
    kubectl label --overwrite crd $crd app.kubernetes.io/managed-by=Helm
    kubectl annotate --overwrite crd $crd meta.helm.sh/release-namespace="$ARGOCD_NAMESPACE"
    kubectl annotate --overwrite crd $crd meta.helm.sh/release-name="$ARGOCD_RELEASENAME"
done

git clone https://github.com/aidenharwood/portfolio-helm-argocd-bootstrap.git $REPO_DIR
helm upgrade --install --create-namespace --dependency-update --namespace $ARGOCD_NAMESPACE $ARGOCD_RELEASENAME $REPO_DIR

rm -rf $REPO_DIR