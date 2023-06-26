#!/bin/bash

#Returns the count of nodes with Status=Ready
ready_node_count=`kubectl get nodes --kubeconfig admin.conf | grep "Ready" | wc -l`
echo $ready_node_count
