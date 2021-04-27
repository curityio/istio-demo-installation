## Overview

This document contains information specific to how containers work in an Istio cluster

## Components

The following main components exist and are explained in [this article](https://ordina-jworks.github.io/cloud/2019/05/03/istio-service-mesh-s2s.html):

| Component | Description |
| --------- | ----------- |
| Envoy | The sidecar proxy responsible for handling traffic between services and setting up TLS |
| Mixer | Manages monitoring, logging and authorization for all requests |
| Pilot | Manages routing and provides proxies with configuration and certificate data |
| Galley | Manages configuration data from the underlying platform |
| Citadel | Manages certificates and acts as the Root Authority |

![Istio Architecture](./images/istio-architecture.svg)

## Concepts

| Concept | Description |
| ------- | ----------- |

TODO - policies etc

## Ingress and Egress

TODO