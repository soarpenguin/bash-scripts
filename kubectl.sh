source <(kubectl completion zsh)  # 在 zsh 中设置当前 shell 的自动补全
echo "[[ $commands[kubectl] ]] && source <(kubectl completion zsh)" >> ~/.zshrc

kubectl proxy
kubectl get --raw /
kubectl get --raw /
kubectl get --raw /api/v1

kubectl explain
kubectl api-resources
kubectl get pods
kubectl describe pods my-pod

# watch pod update
kubectl get pod -w

kubectl logs my-pod
kubectl logs my-pod -c my-container
# -f means follow logs output
kubectl logs -f my-pod
kubectl logs -f my-pod -c my-container

# debug pod
kubectl exec my-pod -- /bin/bash
kubectl top pod POD_NAME --containers

