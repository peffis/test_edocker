# test_edocker
Simple test of running an erlang cluster in kubernetes by building with edocker.mk. It deploys a simple erlang release that just tries to discover and connect all the other nodes in the cluster. It uses the google kubernetes proxy (gcr.io/google_containers/kubectl:v0.18.0-120-gaeb4ac55ad12b1-dirty) to discover the other pods and then it pings them to join the cluster.  

## building
```
$ make docker_image
```

## deploying
```
$ kubectl create -f deployment.yaml
```
