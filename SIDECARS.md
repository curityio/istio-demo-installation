# Sidecar Integration

Use of sidecars for the Curity Identity Server may not be something we want to support.\
In particular the Curity Identity Server should manage its own Mutual TLS requests and audit the results.

## Enabling Sidecars for the Curity Identity Server

This is done with the following configuration for a namespace:

```bash
kubectl label namespace curity istio-injection=enabled
```

Alternatively a particualar component can opt in or out of using sidecars like this:

```bash
kind: Deployment
metadata:
  name: example
spec:
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: 'false'
```

## Enabling Mutual TLS for Sidecars

This would be done by applying a PeerAuthentication resource for the Curity Identity Server's namespace:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: curity
spec:
  mtls:
    mode: STRICT
```

## Curity Identity Server and Sidecars

If the Curity Identity Server is deployed using sidecars, the cluster conf job never completes.\
The problem is that the connection from runtime to admin nodes, over port 6789, needs to use Mutual TLS.\
This fails when a sidecar is in the way, so we would need to support an option to use plain HTTP.\
The expectation would then be that the platform is providing Mutual TLS for this request instead.

## Next Steps

It might be worth considering an option such as `MUTUAL_TLS_VIA_PLATFORM` in the core product.\
This might be an undocumented setting, but could prevent port 6789 from using Mutual TLS.\
It would enable SPIFFE related behavior to be investigated further.
