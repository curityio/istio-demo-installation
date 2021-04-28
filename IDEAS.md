## General Goal

The Identity Server has a reputation of being difficult to deploy compared to PAAS solutions.\
We want to show that:

- It it not as difficult as some customers think
- It is worth the effort and you then get excellent control over many capabilities

## Suggested Approach

The deployment course along with some articles / scripts will help customers to get started.\
Perhaps the end result would be a more `production like developer setup`, using Minikube.

## Article 1: Deploying Identity Server to Kubernetes Walkthrough

An article on taking control of the Kubernetes YAML, refining it, and troubleshooting.\
Certain best practices and background will be useful for customers to understand.

## Article 2: Adding an API Gateway

Deploying an API Gateway with a working phantom token or split token plugin.

## Article 3: End to End Solution

Deploying a working small Web UI and API that use the Identity Server and API Gateway.

## Article 4: Benefits of Istio

Using Istio for better management of cross cutting concerns for both apps and the Identity Server.\
One possible use case might be routing of users via cookies and heart tokens.

## Article 5: Using Cert Manager

Getting the Identity Server to pick up certificates when pods are created.\
Ideally also dealing with certificate expiry automatically, in the same manner as PAAS solutions.