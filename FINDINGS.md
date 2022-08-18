# Service Mesh Architecture

I did an initial investigation focused on using both Kubernetes and a Service Mesh, where Istio is the most widely used:

| Goal | Description |
| ---- | ----------- |
| Co-exist in a Service Mesh Cluster | The Curity Identity Server can co-exist with other components that use service mesh features |
| Identify Useful Features | Identify behaviors that we may want the Curity Identity Server to support in future |

### Curity Identity Server Deployment

Deploy the Curity Identity Server to a namespace that does not use sidecars.\
The Helm chart works fine, though ingress must be disabled, and a separate one configured.\
This is justifiable since the Helm chart is not meant to support arbitrary custom resource definitions (CRDs).

## Istio Features

The overall goal is around a separation of infrastructure from application code.\
Extra tools and then available in the cloud native toolbox.

### HTTP Requests

Application components can send and receive traffic via sidecars that use [Virtual Service](https://istiobyexample.dev/retry/) resources.\
This enables the sidecar to handle cross cutting concerns such as retries.\
The [Envoy Proxy](https://www.envoyproxy.io/) is used, which has some advanced features.

### Infrastructure Security

A [SPIFFE implementation](https://istio.io/latest/docs/ops/integrations/spire/) can enable Mutual TLS between applications (workloads), based on workload attestation.\
A [PeerAuthentication](https://istio.io/latest/docs/reference/config/security/peer_authentication/) resource can be used to configure this behavior.\
It can be applied at a namespace level, with the Curity Identity Server running in a different namespace.

### Advanced Deployment

Certain options such as [canary releases](https://istio.io/latest/blog/2017/0.1-canary/) of the Curity Identity Server could be easier with Istio traffic routing.\
The [DestinationRule](https://istio.io/latest/docs/reference/config/networking/destination-rule/) CRD can use weighted load balancing.

### Scalability

Use of sidecars may also have some benefits around scalability when there are many components.\
Each workload's sidecar can indicate [egress rules](https://istio.io/latest/docs/reference/config/networking/sidecar/) on which components it will interact with.\
The control plane can then send fewer configuration changes to that workload.

### Logging

Extra logging and diagnostics at the network level is possible when routing traffic via sidecars.

### Future

There is talk of using [eBPF](https://isovalent.com/blog/post/2021-12-08-ebpf-servicemesh/) extensibility to replace the overhead of sidecars.\
This is considered more efficient in networking terms as the number of containers scale, than the default use of iptables.

## User Level Security

These notes provides a brief summary of Istio and user level security:

### Sidecar JWT Processing

Istio has a [RequestAuthentication](https://istio.io/latest/docs/tasks/security/authentication/jwt-route/) resource for receiving user level JWTs.\
It can be combined with an [AuthorizationPolicy](https://istio.io/latest/docs/tasks/security/authorization/authz-jwt/) to allow or deny access.\
An [outputPayloadToHeader](https://istio.io/latest/docs/reference/config/security/jwt/) can pass claims to the actual API.\
The argument is that if JWT access tokens are provided to APIs they can leak.

### Threats

The above is not entirely bad, since each API would typically also use mTLS based on workload attestation.\
It would not be easy for an attacker to pass a malicious `outputPayloadToHeader` value.\
It does not protect against a malicious process running in the sidecar, which might be possible in some setups.

### Multiple APIs

Currently APIs cannot forward JWTs to each other, and there is a discussion in these links:

- [Passing JWTs between microservices](https://discuss.istio.io/t/passing-authorization-headers-automatically-jwt-between-microservices/9053/8)
- [outputClaimToHeader Proposal](https://docs.google.com/document/d/1eJ4sPt5-fbXytSwov7senndMsrq4Et6qNYQKicLGHDs/edit#)

### Comparison to Zero Trust

Our zero trust message is stronger, since we argue that each API should vouch for its own security.\
APIs should actively use JWTs and be able to act as OAuth clients and perform operations such as token exchange.\
This is a more scalable solution, without blocking issues, and does not over-rely on the platform.

## Impressions

There are some interesting possibilities here, but also trade offs, since this technology is still quite immature.

### Secondary Security

Being able to engage in Mutual TLS and SPIFFE would be very useful for HTTP operations such as these:

- Reaching out from the Curity Identity Server to APIs for custom claims
- Reaching out from the Curity Identity Server to APIs for custom backup solutions
- Connections from APIs to the Curity Identity Server that use a client secret, eg for token exchange

### Gateway Integration

Sidecars use the Envoy reverse proxy / gateway, and so does the Istio ingress and egress gateways.\
The Envoy gateway can also runs LUA plugins, and the ingress controller itself can be used as an API gateway.\
Envoy supports LUA plugins, so we could write a short article on how to integrate with it.\
We might want to extend the tutorial to include an API that uses sidecars, in a different namespace.

### Complexity

Troubleshooting is a struggle when using Istio.\
When configuration is wrong, the error messages and logs can be really poor.\
When you google there is less information available on highly standard use cases, such as [TLS ingress](./idsvr/ingress.yaml).

### Summary

I'm not sure if I would use a service mesh if it was my cluster.\
Some of these problems are likely to be solved in plain Kubernetes.\
I would need to think carefully about requirements and the pros and cons.
