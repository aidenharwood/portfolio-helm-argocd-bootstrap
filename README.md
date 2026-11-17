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

## Host fixes

`bootstrap.sh` also runs the scripts in `host/` on the machine it runs on. They are excluded from the chart via `.helmignore`.

- `host/e1000e-no-tso.sh`: turns off TSO/GSO on Intel `e1000e` NICs (e.g. the I218-V in homelab1) at every boot via a systemd unit. Without it the NIC hits "Detected Hardware Unit Hang" under load and the wired network stays down until a reboot. Does nothing on machines without an `e1000e` NIC. Run it on its own with:
    ```bash
    sudo bash host/e1000e-no-tso.sh
    ```