# Findings — Part 4 debug lab

I investigated the broken Kubernetes deployment using `kubectl`, `helm`, application logs, and the provided verification script. I fixed the issues I could identify in the Helm chart and verified the results using the scenario checks.

The application image was prebuilt, and its source code was not provided. I did not change the image or its source code.

---

## Defect 1 — Migration Job restart policy

**Symptom** (actual output):

The migration Job could not be created successfully because its pod restart policy was invalid for a Kubernetes Job.

Paste the actual output from the Job description or Helm error here.

**Cause:**

The migration Job was configured with `restartPolicy: Always`. Kubernetes Jobs require a restart policy of `Never` or `OnFailure`.

**Fix:**

I changed the restart policy to `Never` in `templates/migrate-job.yaml`. This allows the Job to finish instead of restarting the container continuously.

**How I found it:**

I checked the Job using `kubectl describe job` and inspected the migration Job template. After correcting the policy, I reapplied the Helm chart and confirmed that the migration Job completed successfully.

---

## Defect 2 — Metrics CPU resources

**Symptom** (actual output):

The metrics deployment was not becoming ready because its CPU resource request was too high for the available cluster resources.

Paste the actual output from `kubectl describe pod` here.

**Cause:**

The metrics container requested 2 CPU cores and had a limit of 4 CPU cores. These settings were unnecessarily high for this local lab and prevented the pod from being scheduled successfully.

**Fix:**

I reduced the CPU request to `50m` and the CPU limit to `200m` in `values.yaml`. This gives the container a smaller resource allocation suitable for this lab.

**How I found it:**

I inspected the pod status, events, and resource settings using `kubectl describe pod`. I then updated the values and reran the scenario verification.

---

## Defect 3 — Numeric user ID

**Symptom** (actual output):

The application containers could not start correctly with the configured non-root security settings.

Paste the actual container event or error message here.

**Cause:**

The image specified the user as `nonroot`, but Kubernetes needed a numeric user ID to verify the non-root execution setting reliably.

**Fix:**

I inspected the supplied image using Docker and checked the user information available in the image. The image identified the non-root user with UID `65532`.

I added `runAsUser: 65532` alongside `runAsNonRoot: true` in the affected workload templates. This keeps the containers running as a non-root user.

**How I found it:**

I inspected the pod events and security context, then used Docker image inspection and the image's user information to identify the correct UID. After updating the templates, I checked the deployments again.

---

## Defect 4 — Application and Service port configuration

**Symptom** (actual output):

The backend health check could not reach the application through the expected Service port.

Paste the actual failed health-check output here.

**Cause:**

The application listens on port `8081`, but the backend Service needed to expose port `8080` to match the address used by the verification script.

**Fix:**

I configured the backend Service to expose port `8080` and forward traffic to target port `8081`. I also updated the shared application port setting to `8081` where the containers need to listen on that port.

This keeps the application listening port separate from the Service port.

**How I found it:**

I checked the backend deployment, Service configuration, and health-check result. I compared the container port with the Service port and target port, then updated the Helm template and reran verification.

---

## Defect 5 — Gateway backend address

**Symptom** (actual output):

The gateway could not successfully communicate with the backend, and the gateway status did not report the backend as healthy.

Paste the actual gateway status response or relevant log output here.

**Cause:**

The gateway's backend URL used `backend.default.svc`, which pointed to the wrong namespace. The backend Service was deployed in the `debug-lab` namespace.

**Fix:**

I changed the backend URL to `http://backend.debug-lab.svc:8081`, so the gateway can resolve the backend Service in the correct namespace and reach its application port.

**How I found it:**

I checked the gateway logs and status endpoint, then inspected the backend Service and the gateway environment settings. The namespace mismatch explained why the configured address was incorrect.

---

## Defect 6 — Worker cache and reporter configuration

**Symptom** (actual output):

The worker could not initialize its cache directory with the read-only root filesystem enabled.

The reporter's `/report` endpoint also continued returning HTTP 503 with this error:

`{"error":"parse pod list: unexpected end of JSON input","status":"unhealthy"}`

**Cause:**

The worker needed a writable location for its cache, even though the root filesystem was read-only.

For the reporter, I corrected the RoleBinding to reference the `reporter` service account in the `debug-lab` namespace. However, the reporter's `/report` failure remains unresolved. The exact cause has not been confirmed.

**Fix:**

For the worker, I mounted an `emptyDir` volume at `/var/cache/app`, providing a writable cache directory without making the entire root filesystem writable.

For the reporter, I corrected the RoleBinding subject to use the `reporter` service account and the release namespace.

I also checked the reporter's token mount, namespace setting, and permissions. A separate test pod using the same service account successfully queried the Kubernetes API and received HTTP 200 with valid JSON. However, the reporter application still returned HTTP 503.

**How I found it:**

I inspected the worker logs and security settings to identify the cache problem. For the reporter, I checked the deployment, service account, RoleBinding, logs, and `/report` response. I also tested the Kubernetes API from a separate pod using the reporter service account.

The reporter issue remains under investigation. Since the image is prebuilt and its source code is unavailable, I would investigate the remaining deployment-level causes before escalating it as an application issue.

---

## Remaining work

The scenario verification currently passes 10 checks and fails the reporter pod-count check. I have not claimed that Part 4 is fully passing.

The next step would be to continue investigating the reporter's request and response handling, using the available logs and Kubernetes debugging tools. If the cause requires a code change in the supplied application, I would document the evidence and raise it with the application development team.
