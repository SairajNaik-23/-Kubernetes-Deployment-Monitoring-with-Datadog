# Interview Guide: Kubernetes Deployment & Monitoring with Datadog

## 60-second explanation

> "I deployed a containerized Python app on Kubernetes and added monitoring with Datadog. The app runs as a Deployment with three replicas, a rolling update strategy, liveness and readiness probes, and CPU and memory limits. Configuration comes from a ConfigMap, and the API token comes from a Secret, both injected as environment variables, so the same image works in any environment. A Service load-balances traffic across the ready pods, and an HPA scales from 3 to 8 pods at 70% CPU. For monitoring, I installed the Datadog Agent with Helm. It runs as a DaemonSet on every node and collects metrics and container logs, and the Cluster Agent adds Kubernetes state like restarts and unavailable replicas. I wrote four alert monitors as JSON and created them through the Datadog API, for high CPU, crash loops, unavailable replicas and error logs."

## Common questions

**Q: Pod vs Deployment vs ReplicaSet?**
A pod is the smallest unit: one or more containers. A ReplicaSet keeps N identical pods running. A Deployment manages ReplicaSets and adds rolling updates and rollbacks. You normally only create Deployments.

**Q: Service types?**
ClusterIP: internal only (default). NodePort: opens a port (30000–32767) on every node. LoadBalancer: creates a cloud load balancer (for example, AWS ELB). I used NodePort for Minikube; on EKS I'd use LoadBalancer or an Ingress.

**Q: ConfigMap vs Secret?**
Both hold key-value config. Secrets are for sensitive data: they're stored separately, can be encrypted at rest, and access is controlled by RBAC. Secrets are only base64-encoded, not encrypted, so in production I'd enable KMS encryption or use AWS Secrets Manager or Vault with External Secrets.

**Q: Liveness vs readiness probe?**
Liveness failing → the container is restarted. Readiness failing → the pod is removed from the Service so it gets no traffic, but it isn't restarted. Readiness protects users during startup and deployments.

**Q: Requests vs limits?**
Requests are what the scheduler reserves when placing the pod. Limits are the maximum: CPU over the limit is throttled, and memory over the limit means the container is OOMKilled. The HPA calculates CPU % against the **request**.

**Q: Why does the Datadog Agent run as a DaemonSet?**
A DaemonSet runs exactly one pod per node, which is exactly what you need to collect node and container metrics and logs from each machine. New nodes get an agent automatically.

**Q: What does the Cluster Agent do?**
It talks to the Kubernetes API once for the whole cluster, instead of every node agent doing it. This reduces API server load and provides cluster-level metadata and metrics.

**Q: What is unified service tagging?**
The `env`, `service` and `version` labels on the pods. Datadog uses them to link metrics, logs and traces of the same service and version, so after a deploy you can compare errors between versions.

**Q: A pod is in CrashLoopBackOff. How do you debug it?**
`kubectl describe pod` (events, exit code, OOMKilled?), then `kubectl logs <pod> --previous` (logs of the crashed container), then check the probes, environment variables, ConfigMap/Secret names, and image tag. My pod-restart monitor alerts on this automatically.

**Q: How do you handle a rollback?**
`kubectl rollout undo deployment/demo-app -n demo-app`. The Deployment keeps old ReplicaSets (`revisionHistoryLimit: 5`). `kubectl rollout history` shows the revisions.

**Q: Why define monitors as JSON files?**
Monitoring as Code: alerts are reviewed and versioned in Git with the app and can be recreated in any account. The next step would be managing them with the Datadog Terraform provider.

**Q: What would you add next?**
APM tracing with `ddtrace`, SLOs (for example, 99.9% of requests return non-5xx), an Ingress with TLS, PodDisruptionBudgets, NetworkPolicies, and deployment through a CI/CD pipeline or Argo CD.
