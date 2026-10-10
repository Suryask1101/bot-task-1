# DevOps Engineer Take-Home Assignment

## Project Overview

This repository contains my submission for the Enterprise Bot DevOps Engineer take-home assignment.

The project covers application containerization, Kubernetes deployment using Helm, automated environment setup, and troubleshooting a broken Kubernetes deployment.

## Project Structure

- `service/` — application source code and Docker configuration.
- `chart/` — Helm chart for deploying the application.
- `setup.sh` — one-command environment setup script.
- `lab/broken-chart/` — corrected Helm configurations for the debugging exercise.
- `lab/FINDINGS.md` — debugging findings, root causes, fixes, and investigation steps.
- `lab/part4-session.log` — recorded terminal session for Part 4.
- `ANSWERS.md` — written answer for Part 5.

## Prerequisites

- Docker
- Kubernetes kind
- kubectl
- Helm

## Setup

Clone the repository and enter the project directory:

```bash
git clone <YOUR_PUBLIC_REPOSITORY_URL>
cd enterprisebot-submission
```

Run the setup script:

```bash
./setup.sh
```

The script is intended to create or reuse the local kind cluster, install ingress-nginx, build and load the application image, and deploy the Helm chart.

## Verification

Check the Kubernetes resources:

```bash
kubectl get pods -n demo
kubectl get services -n demo
kubectl get ingress -n demo
helm list -n demo
```

Check the application logs:

```bash
kubectl logs deployment/<deployment-name> -n demo
```

The setup and verification commands should be run after the environment has been deployed successfully.

## Resource Requests and Limits

I configured CPU and memory requests and limits in the Helm chart to control resource allocation and prevent containers from consuming unlimited resources.

Requests represent the resources Kubernetes uses when scheduling pods. Limits restrict the resources a container can consume.

For the Part 4 debugging lab, I reduced the metrics workload's CPU request to `50m` and its CPU limit to `200m`, which are more suitable for the available local test environment.

## What I Deliberately Skipped

This is a local take-home exercise, so I kept the implementation focused on the assignment requirements.

A complete production setup would require additional work, including stronger secrets management, comprehensive monitoring and alerting, automated security scanning, and tested backup and recovery procedures.

Skipping these items in a local exercise should not be interpreted as a recommendation to omit them in production.

## Production Improvements

For a production environment, I would consider:

- CI/CD pipelines with automated tests and Helm validation.
- Container image vulnerability scanning.
- Secure management of application secrets.
- Resource monitoring, alerts, and centralized logging.
- Pod disruption budgets and appropriate health probes.
- High availability, rollback procedures, and disaster recovery testing.
- Network policies and least-privilege RBAC permissions.

## Part 4 — Debugging

The debugging investigation and chart changes are documented in `lab/FINDINGS.md`.

The investigation used Kubernetes pod descriptions, application logs, Service configuration, security contexts, RBAC checks, and the provided scenario verification script.

The reporter `/report` check remained unresolved during the documented investigation. Its observed response and the diagnostic steps are recorded in the findings rather than being presented as a successful fix.

## How I Used AI

## How I Used AI

I used ChatGPT to help troubleshoot Kubernetes and Helm deployment issues, understand command outputs, and identify possible causes of errors. I also used it to organize my debugging findings and prepare the project documentation.

I verified the suggested solutions against my actual environment, tested the configuration changes, and recorded the results. Where an issue remained unresolved, I documented the findings rather than claiming a successful fix.
