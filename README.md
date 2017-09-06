# test_edocker
Simple test of running an erlang cluster in kubernetes by building with edocker.mk. It deploys a simple erlang release that just tries to discover and connect all the other nodes in the cluster. It uses the google kubernetes proxy to discover the other pods and then it pings them. 

## building
```
$ make docker_image
```

## deploying
```
$ kubectl create -f deployment.yaml
```
