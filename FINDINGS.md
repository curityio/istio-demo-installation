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

### User Level Security

Istio has a [RequestAuthentication](https://istio.io/latest/docs/reference/config/security/request_authentication/) resource for validating user level JWTs.\
An argument is keeping JWTs out of applications where they could leak, but this doesn't feel very joined up.\
It is weak in terms of API authorization based on claims, and how multiple APIs interact.
Our zero trust argument is that user level security is best handled in the API code, and this is a complete solution.

### Advanced Deployment

Certain options such as [canary releases](https://istio.io/latest/blog/2017/0.1-canary/) of the Curity Identity Server could be easier with Istio traffic routing.
The [DestinationRule](https://istio.io/latest/docs/reference/config/networking/destination-rule/) CRD is also relevant to this.

### Scalability

Use of sidecars may also have some benefits around scalability when there are many components.\
Each workload's sidecar can indicate [egress rules](https://istio.io/latest/docs/reference/config/networking/sidecar/) on which components it will interact with.\
The control plane can then send fewer configuration changes to that workload.

### Logging

Extra logging and diagnostics at the network level is possible when routing traffic via sidecars.

### Future

There is talk of using [eBPF](https://isovalent.com/blog/post/2021-12-08-ebpf-servicemesh/) extensibility to replace the overhead of sidecars.\
This is considered more efficient in networking terms as the number of containers scale, than the default use of iptables.

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