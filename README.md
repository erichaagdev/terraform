```shell
gcloud container clusters get-credentials coruscant
```

```shell
# Clear a namespace stuck in terminating
$ NAMESPACE=ingress-nginx; kubectl get namespace "$NAMESPACE" -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -; unset NAMESPACE
```
