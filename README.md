# portfolio-helm-argocd-bootstrap
Helm chart for bootstrapping ArgoCD applications on the portfolio cluster

## Overview

This repository contains a Helm chart designed to bootstrap an ArgoCD installation with applications to be deployed and hosted on the portfolio cluster. It simplifies the process of managing and deploying applications using GitOps principles.

## Features

- Automates the setup of ArgoCD applications.
- Provides a streamlined way to manage application configurations.
- Ensures consistency and repeatability in deployments.

## Prerequisites

- A Kubernetes cluster.
- Helm installed on your local machine.
- ArgoCD installed and configured on the cluster.

## Installation

1. Clone this repository:
    ```bash
    git clone https://github.com/aidenharwood/portfolio-helm-argocd-bootstrap.git
    cd portfolio-helm-argocd-bootstrap
    ```

2. Install the Helm chart:
    ```bash
    repo=$(git config --get remote.origin.url)
    helm install portfolio-bootstrap -n argocd --create-namespace ./ --set repo=$repo
    ```