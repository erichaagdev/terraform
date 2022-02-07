```shell
gcloud container clusters get-credentials coruscant-cluster
```

```shell
# Clear a namespace stuck in terminating
$ NAMESPACE=certificates; kubectl get namespace "$NAMESPACE" -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -; unset NAMESPACE
```

```shell
gcloud domains registrations configure dns erichaag.dev --cloud-dns-zone=erichaag-dev-dns-zone
```
