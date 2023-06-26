#!/bin/bash

#Returns the number of core objects with Status=Running
core_objects_count=`kubectl get all --all-namespaces --kubeconfig admin.conf | grep "Running" | wc -l`
echo $core_objects_count
