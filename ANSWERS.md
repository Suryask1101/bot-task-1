# Part 5 — Written Answer

## Q1. Migrating from Ingress to Kubernetes Gateway API Without Downtime

I would start by reviewing all existing Ingress resources, their hostnames, paths, TLS certificates, annotations, and dependencies. I would identify which features are specific to ingress-nginx and check whether they are supported by the selected Gateway API implementation.

Next, I would install a Gateway API controller and configure the required GatewayClass, Gateway, listeners, TLS settings, and HTTPRoutes in parallel with the existing Ingress setup.

I would test the new routes in a non-production environment first. I would verify routing, TLS, authentication, redirects, health checks, and application behavior. I would also compare the new configuration against the existing Ingress rules.

For production, I would migrate a small number of low-risk services first. I would gradually move traffic to the new Gateway using controlled DNS or load-balancer changes, depending on the environment. I would monitor errors, latency, availability, and application logs throughout the migration.

I would keep the original Ingress configuration available during the migration so that traffic can be switched back if a problem occurs. I would not remove the old controller until all routes have been verified and the rollback window has passed.

Possible issues include unsupported annotations, differences in routing behavior, TLS configuration errors, DNS propagation delays, and controller-specific features that require redesign.

The priority would be to validate each change, reduce risk through gradual migration, and maintain a tested rollback plan.
