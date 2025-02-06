# Change Log

## 0.42.0 

**Release date:** 2025-02-06

![AppVersion: v0.38.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.38.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Self-hosted release Copia v0.38.0 

### Default value changes

```diff
# No changes in this release
```

## 0.41.0 

**Release date:** 2025-01-21

![AppVersion: v0.37.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.37.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* self-hosted release copia v0.37.0 

### Default value changes

```diff
# No changes in this release
```

## 0.40.0 

**Release date:** 2025-01-07

![AppVersion: v0.36.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.36.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* [CU86a643dnt] Bump gitea to v0.36.0 and infra to v0.40.0 (#91) 

### Default value changes

```diff
# No changes in this release
```

## 0.39.2 

**Release date:** 2024-11-27

![AppVersion: v0.35.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.35.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Validations (ghcr secrets) (#87) 

### Default value changes

```diff
# No changes in this release
```

## 0.38.1 

**Release date:** 2024-11-18

![AppVersion: v0.35.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.35.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* update conversion manager container name (#84) 

### Default value changes

```diff
# No changes in this release
```

## 0.38.0 

**Release date:** 2024-11-18

![AppVersion: v0.35.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.35.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Chart.yaml for self-hosted release v0.35.0 (#83) 

### Default value changes

```diff
# No changes in this release
```

## 0.37.1 

**Release date:** 2024-11-15

![AppVersion: v0.34.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.34.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* add deployment env to conversion manager (#81) 

### Default value changes

```diff
# No changes in this release
```

## 0.37.0 

**Release date:** 2024-11-14

![AppVersion: v0.34.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.34.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Fixes conversion manager conditions (#80) 

### Default value changes

```diff
# No changes in this release
```

## 0.36.0 

**Release date:** 2024-10-15

![AppVersion: v0.34.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.34.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump gitea to v0.34.0 and infra to v0.36.0 (#78) 

### Default value changes

```diff
# No changes in this release
```

## 0.35.0 

**Release date:** 2024-10-09

![AppVersion: v0.33.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.33.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump gitea to v0.33.0 and infra to  v0.35.0 (#76) 

### Default value changes

```diff
# No changes in this release
```

## 0.34.0 

**Release date:** 2024-09-24

![AppVersion: v0.32.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.32.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump app and infra version. These two versions have diverged. (#73) 

### Default value changes

```diff
# No changes in this release
```

## 0.33.0 

**Release date:** 2024-09-04

![AppVersion: v0.31.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.31.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Adds preflight check init container (#71) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 1ebc769..0175e95 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -52,6 +52,7 @@ nodeSelector: {}
 tolerations: []
 affinity: {}
 deployment:
+  preflight: false
   configmap:
     SSH_LISTEN_PORT: 22
     GITEA_APP_INI: /data/gitea/conf/app.ini
```

## 0.32.0 

**Release date:** 2024-08-22

![AppVersion: v0.31.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.31.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Adds conversion manager templates (#66) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 3881b79..1ebc769 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -2,6 +2,7 @@ replicaCount: 1
 clusterDomain: cluster.local
 #Use this value "*copia_port" to reference the value of the copia_server_http_port when setting HTTP_PORT on the copia config.
 copia_server_http_port: &copia_port 4001
+conversion_manager_http_port: &cm_port 8888
 image:
   repository: ghcr.io/copia-automation/copia-web-app-selfhosted-releases
   pullPolicy: Always
@@ -136,3 +137,98 @@ copia:
   #     INTERNAL_TOKEN: <REQUIRED>
   #   copia:
   #     LICENSE_KEY: <REQUIRED>
+
+conversion_manager:
+  enabled: false
+  deployment:
+    port: *cm_port
+    image:
+      repository: ghcr.io/copia-automation/conversion-manager
+      imagePullPolicy: Always
+      tag: latest
+    # serviceAccountName: ""
+    # terminationGracePeriodSeconds: 60
+    replicaCount: 1
+    rollingUpdate:
+      maxSurge: 1
+      maxUnavailable: 0
+    podAnnotations: {}
+    labels: {}
+    imagePullSecrets:
+      - name: ghcr-login-secret
+    startupProbe:
+      httpGet:
+        path: /api/v1/ping
+        port: *cm_port
+        scheme: HTTPS
+      initialDelaySeconds: 20
+      periodSeconds: 10
+      timeoutSeconds: 5
+      failureThreshold: 10
+      successThreshold: 1
+    livenessProbe:
+      httpGet:
+        path: /api/v1/ping
+        port: *cm_port
+        scheme: HTTPS
+      periodSeconds: 10
+      timeoutSeconds: 5
+      failureThreshold: 2
+    readinessProbe: {}
+    nodeSelector: {}
+    affinity: {}
+    tolerations: []
+    volumeMounts: []
+    volumes: []
+    resources:
+      limits:
+        cpu: 2
+        memory: 512Mi
+      requests:
+        cpu: 0.5
+        memory: 128Mi
+  service:
+    #clusterIP: None
+    #loadBalancerIP:
+    #externalTrafficPolicy:
+    #externalIPs: []
+    loadBalancerSourceRanges: []
+    annotations: {}
+    http:
+      type: NodePort
+      port: 3010
+      targetPort: *cm_port
+      #nodePort:
+      annotations: {}
+  ingress:
+    enabled: false
+    # ingressClassName: nginx
+    annotations: {}
+      # kubernetes.io/ingress.class: nginx
+      # kubernetes.io/tls-acme: "true"
+    hosts:
+      - host: git.example.com
+        paths:
+          - path: /
+            pathType: Prefix
+    tls: []
+    #  - secretName: chart-example-tls
+    #    hosts:
+    #      - git.example.com
+  configmap:
+    LOGGER_LEVEL: debug
+    NODE_ENV: production
+    PORT: *cm_port
+    HOST: localhost
+    ADMIN_ID: admin
+    COPIA_USER_ID: copiaUser
+    COPIA_TEAM_ID: copiaTeam
+    DB_USER: postgres
+    DB_HOST: localhost:5441
+    DATABASE_URL: "postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/conversion_manager?schema=public"
+    ENABLE_HTTPS: false
+  secret:
+    DB_PASSWORD: password
+    ADMIN_KEY: testAdminKey
+    COPIA_USER_KEY: testCopiaUserKey
+    COPIA_TEAM_KEY: testCopiaTeamKey
```

## 0.31.0 

**Release date:** 2024-08-21

![AppVersion: v0.31.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.31.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump gitea and infra to 0.31.0 (#68) 
* Fixes the tls issue (#65) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 9aae29a..3881b79 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -31,7 +31,7 @@ ingress:
       paths:
         - path: /
           pathType: Prefix
-  tls: {}
+  tls: []
   #  - secretName: chart-example-tls
   #    hosts:
   #      - git.example.com
```

## 0.30.0 

**Release date:** 2024-08-01

![AppVersion: v0.30.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.30.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump gitea and infra to 0.30.0 (#64) 
* Changing registry to GHCR (#45) 
* Pre-Flight Checks & Support Bundles (#38) 
* Adds Unit Tests for default values (#61) 
* Adds Unit Tests (#60) 
* Helm chart improvements (#56) 
* Fixes issues encountered when deploying to an actual environment (#59) 
* Fixes values schema file (#58) 
* Adds values.schema.json file to enforce value types and format (#55) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 2c282e0..9aae29a 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -1,21 +1,25 @@
 replicaCount: 1
 clusterDomain: cluster.local
+#Use this value "*copia_port" to reference the value of the copia_server_http_port when setting HTTP_PORT on the copia config.
+copia_server_http_port: &copia_port 4001
 image:
-  repository: copiaio/copia
+  repository: ghcr.io/copia-automation/copia-web-app-selfhosted-releases
   pullPolicy: Always
-imagePullSecrets: []
+imagePullSecrets:
+  - name: ghcr-login-secret
 service:
+  #clusterIP: None
+  #loadBalancerIP:
+  #externalTrafficPolicy:
+  #externalIPs: []
+  loadBalancerSourceRanges: []
+  annotations: {}
   http:
     type: NodePort
     port: 3000
-    targetPort: 4001
-    # clusterIP: None
-    #loadBalancerIP:
+    targetPort: *copia_port
     #nodePort:
-    #externalTrafficPolicy:
-    #externalIPs:
-    loadBalancerSourceRanges: []
-    annotations:
+    annotations: {}
 ingress:
   enabled: false
   # ingressClassName: nginx
@@ -27,7 +31,7 @@ ingress:
       paths:
         - path: /
           pathType: Prefix
-  tls: []
+  tls: {}
   #  - secretName: chart-example-tls
   #    hosts:
   #      - git.example.com
@@ -42,45 +46,38 @@ resources: {}
 ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
 ##
 # schedulerName:
+securityContext: {}
 nodeSelector: {}
 tolerations: []
 affinity: {}
 deployment:
-  env:
-    # - name: ACD_CONVERSION_URL
-    #   value: https://rockwell-tools.copia.io/convertOctetStream
-    # - name: ROCKWELL_V35_CONVERSION_URL
-    #   value: https://rockwell-v35.copia.io/convertOctetStream
-    # - name: ROCKWELL_V35_IMPORT_CONVERSION_URL
-    #   value: https://rockwell-v35.copia.io/convertL5xToAcd
-    # - name: ZAP14_CONVERSION_URL
-    #   value: http://zap2zipv14.copia.io:9694
-    # - name: ZAP15_0_CONVERSION_URL
-    #   value: http://zap2zipv15-0.copia.io:9695
-    # - name: ZAP15_CONVERSION_URL
-    #   value: http://zap2zipv15.copia.io:9695
-    # - name: ZAP16_CONVERSION_URL
-    #   value: http://zap2zip.copia.io:9696
-    # - name: ZAP17_CONVERSION_URL
-    #   value: http://zap2zipv17.copia.io:9697
-    # - name: ACD_IMPORT_CONVERSION_URL
-    #   value: https://rockwell-tools.copia.io/convertL5xToAcd
-    # - name: ZAP14_IMPORT_CONVERSION_URL
-    #   value: http://zap2zipv14.copia.io:9694/import
-    # - name: ZAP15_0_IMPORT_CONVERSION_URL
-    #   value: http://zap2zipv15-0.copia.io:9695/import
-    # - name: ZAP15_IMPORT_CONVERSION_URL
-    #   value: http://zap2zipv15.copia.io:9695/import
-    # - name: ZAP16_IMPORT_CONVERSION_URL
-    #   value: http://zap2zip.copia.io:9696/import
-    # - name: ZAP17_IMPORT_CONVERSION_URL
-    #   value: http://zap2zipv17.copia.io:9697/import
-    # - name: CODESYS_CONVERSION_URL
-    #   value: http://codesys.copia.io:8888/export
-    # - name: CODESYS_IMPORT_CONVERSION_URL
-    #   value: http://codesys.copia.io:8888/import
-    # - name: CONTROL_EXPERT_CONVERSION_URL
-    #   value: http://control-expert.copia.io:9696/export
+  configmap:
+    SSH_LISTEN_PORT: 22
+    GITEA_APP_INI: /data/gitea/conf/app.ini
+    GITEA_CUSTOM: /data/gitea
+    GITEA_WORK_DIR: /data
+    GITEA_TEMP: /tmp/gitea
+    TMPDIR: /tmp/gitea
+    ENABLE_PPROF: false
+    PPROF_PORT: 6060
+    # ACD_CONVERSION_URL: https://rockwell-tools.copia.io/convertOctetStream
+    # ROCKWELL_V35_CONVERSION_URL: https://rockwell-v35.copia.io/convertOctetStream
+    # ROCKWELL_V35_IMPORT_CONVERSION_URL: https://rockwell-v35.copia.io/convertL5xToAcd
+    # ZAP14_CONVERSION_URL: http://zap2zipv14.copia.io:9694
+    # ZAP15_0_CONVERSION_URL: http://zap2zipv15-0.copia.io:9695
+    # ZAP15_CONVERSION_URL: http://zap2zipv15.copia.io:9695
+    # ZAP16_CONVERSION_URL: http://zap2zip.copia.io:9696
+    # ZAP17_CONVERSION_URL: http://zap2zipv17.copia.io:9697
+    # ACD_IMPORT_CONVERSION_URL: https://rockwell-tools.copia.io/convertL5xToAcd
+    # ZAP14_IMPORT_CONVERSION_URL: http://zap2zipv14.copia.io:9694/import
+    # ZAP15_0_IMPORT_CONVERSION_URL: http://zap2zipv15-0.copia.io:9695/import
+    # ZAP15_IMPORT_CONVERSION_URL: http://zap2zipv15.copia.io:9695/import
+    # ZAP16_IMPORT_CONVERSION_URL: http://zap2zip.copia.io:9696/import
+    # ZAP17_IMPORT_CONVERSION_URL: http://zap2zipv17.copia.io:9697/import
+    # CODESYS_CONVERSION_URL: http://codesys.copia.io:8888/export
+    # CODESYS_IMPORT_CONVERSION_URL: http://codesys.copia.io:8888/import
+    # CONTROL_EXPERT_CONVERSION_URL: http://control-expert.copia.io:9696/export
+  env: []
   terminationGracePeriodSeconds: 60
   labels: {}
   rollingUpdate:
@@ -88,16 +85,16 @@ deployment:
     maxUnavailable: 0
 persistence:
   enabled: true
-  existingClaim:
+  existingClaim: ""
   size: 10Gi
   accessModes:
     - ReadWriteOnce
   labels: {}
   annotations: {}
-  # storageClass:
+  #storageClassName:
 # additional volumes to add to the deployment.
-extraVolumes:
-extraVolumeMounts:
+extraVolumes: []
+extraVolumeMounts: []
 # bash shell script copied verbatim to the start of the init-container.
 initPreScript: ""
 # Configure commit/action signing prerequisites
@@ -114,7 +111,7 @@ copia:
   customStartupProbe:
     httpGet:
       path: /
-      port: 4001
+      port: *copia_port
     initialDelaySeconds: 10
     periodSeconds      : 5
     timeoutSeconds     : 2
@@ -122,18 +119,20 @@ copia:
   customLivenessProbe:
     httpGet:
       path: /
-      port: 4001
+      port: *copia_port
     periodSeconds   : 10
     timeoutSeconds  : 2
     failureThreshold: 2
   # config:
+  #   server:
+  #     SSH_PORT: 22
+  #     HTTP_PORT: *copia_port
+  #     LFS_JWT_SECRET: <REQUIRED>
   #   APP_NAME: "Copia"
   #   RUN_MODE: production
   #   oauth2:
   #     JWT_SECRET: <REQUIRED>
   #   security:
   #     INTERNAL_TOKEN: <REQUIRED>
-  #   server:
-  #     LFS_JWT_SECRET: <REQUIRED>
   #   copia:
   #     LICENSE_KEY: <REQUIRED>
```

## 0.29.0 

**Release date:** 2024-06-10

![AppVersion: v0.29.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.29.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump gitea and infra to 0.29.0 (#47) 

### Default value changes

```diff
# No changes in this release
```

## 0.28.0 

**Release date:** 2024-05-16

![AppVersion: v0.28.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.28.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump infra and gitea version to 0.28.0 (#46) 

### Default value changes

```diff
# No changes in this release
```

## 0.27.0 

**Release date:** 2024-04-02

![AppVersion: v0.27.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.27.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump infra and gitea version to 0.27.0 (#44) 

### Default value changes

```diff
# No changes in this release
```

## 0.26.0 

**Release date:** 2024-02-14

![AppVersion: v0.26.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.26.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump infra and gitea version to 0.26.0 (#43) 

### Default value changes

```diff
# No changes in this release
```

## 0.25.0 

**Release date:** 2024-01-29

![AppVersion: v0.25.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.25.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Bump infra and gitea version to 0,.25.0 (#42) 

### Default value changes

```diff
# No changes in this release
```

## 0.24.0 

**Release date:** 2024-01-02

![AppVersion: v0.24.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.24.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Helm Chart for v0.24.0 release (#41) 

### Default value changes

```diff
# No changes in this release
```

## 0.23.0 

**Release date:** 2023-12-05

![AppVersion: v0.23.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.23.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Helm Chart for v0.23.0 release (#40) 

### Default value changes

```diff
# No changes in this release
```

## 0.22.0 

**Release date:** 2023-11-07

![AppVersion: v0.22.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.22.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update helm chart for v0.22.0 self-hosted release (#39) 

### Default value changes

```diff
# No changes in this release
```

## 0.21.0 

**Release date:** 2023-10-18

![AppVersion: v0.21.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.21.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update helm chart for v0.21.0 self-hosted release (#36) 

### Default value changes

```diff
# No changes in this release
```

## 0.20.0 

**Release date:** 2023-09-08

![AppVersion: v0.20.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.20.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update helm chart for v0.20.0 self-hosted release (#34) 

### Default value changes

```diff
# No changes in this release
```

## 0.19.0 

**Release date:** 2023-08-08

![AppVersion: v0.19.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.19.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update to v0.19.0 release (#32) 

### Default value changes

```diff
# No changes in this release
```

## 0.18.1 

**Release date:** 2023-07-20

![AppVersion: v0.18.1](https://img.shields.io/static/v1?label=AppVersion&message=v0.18.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update infra and gitea version to v0.18.1 (#31) 

### Default value changes

```diff
# No changes in this release
```

## 0.17.2 

**Release date:** 2023-06-22

![AppVersion: v0.17.1](https://img.shields.io/static/v1?label=AppVersion&message=v0.17.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Release 0.17.2 (#30) 

### Default value changes

```diff
# No changes in this release
```

## 0.17.1 

**Release date:** 2023-06-14

![AppVersion: v0.17.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.17.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Release v0.17.1 (#29) 

### Default value changes

```diff
# No changes in this release
```

## 0.16.1 

**Release date:** 2023-04-28

![AppVersion: v0.16.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.16.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Release 0.16.1 (#27) 
* Add ingressClassName parameter (#26) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index beb0138..2c282e0 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -18,6 +18,7 @@ service:
     annotations:
 ingress:
   enabled: false
+  # ingressClassName: nginx
   annotations: {}
     # kubernetes.io/ingress.class: nginx
     # kubernetes.io/tls-acme: "true"
```

## 0.16.0 

**Release date:** 2023-03-16

![AppVersion: v0.16.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.16.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.16.0 release (#25) 

### Default value changes

```diff
# No changes in this release
```

## 0.15.2 

**Release date:** 2023-03-06

![AppVersion: v0.15.2](https://img.shields.io/static/v1?label=AppVersion&message=v0.15.2&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update for self-hosted v0.15.2 release (#23) 

### Default value changes

```diff
# No changes in this release
```

## 0.15.1 

**Release date:** 2023-03-06

![AppVersion: v0.15.1](https://img.shields.io/static/v1?label=AppVersion&message=v0.15.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update for self-hosted v0.15.1 release (#22) 

### Default value changes

```diff
# No changes in this release
```

## 0.15.0 

**Release date:** 2023-02-28

![AppVersion: v0.15.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.15.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* [CU-8669mx4d9] Updating helm-chart for v0.15.0 release (#20) 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index a49f23d..beb0138 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -48,6 +48,10 @@ deployment:
   env:
     # - name: ACD_CONVERSION_URL
     #   value: https://rockwell-tools.copia.io/convertOctetStream
+    # - name: ROCKWELL_V35_CONVERSION_URL
+    #   value: https://rockwell-v35.copia.io/convertOctetStream
+    # - name: ROCKWELL_V35_IMPORT_CONVERSION_URL
+    #   value: https://rockwell-v35.copia.io/convertL5xToAcd
     # - name: ZAP14_CONVERSION_URL
     #   value: http://zap2zipv14.copia.io:9694
     # - name: ZAP15_0_CONVERSION_URL
```

## 0.14.0 

**Release date:** 2023-02-01

![AppVersion: v0.14.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.14.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update for v0.14.0 release (#18) 

### Default value changes

```diff
# No changes in this release
```

## 0.13.0 

**Release date:** 2022-12-16

![AppVersion: v0.13.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.13.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.13.0 

### Default value changes

```diff
# No changes in this release
```

## 0.12.0 

**Release date:** 2022-11-30

![AppVersion: v0.12.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.12.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Version 0.12.0 

### Default value changes

```diff
# No changes in this release
```

## 0.11.1 

**Release date:** 2022-11-04

![AppVersion: v0.11.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.11.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Use simpler conditional for serviceAccountName 

### Default value changes

```diff
# No changes in this release
```

## 0.11.0 

**Release date:** 2022-10-05

![AppVersion: v0.11.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.11.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Version 0.11.0 

### Default value changes

```diff
# No changes in this release
```

## 0.10.1 

**Release date:** 2022-09-16

![AppVersion: v0.10.1](https://img.shields.io/static/v1?label=AppVersion&message=v0.10.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update version to 0.10.1 (#15) 

### Default value changes

```diff
# No changes in this release
```

## 0.10.0 

**Release date:** 2022-09-14

![AppVersion: v0.10.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.10.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Chart.yaml 

### Default value changes

```diff
# No changes in this release
```

## 0.6.1 

**Release date:** 2022-07-13

![AppVersion: v0.6.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.6.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Allow Recreate deployment (#14) 

### Default value changes

```diff
# No changes in this release
```

## 0.6.0 

**Release date:** 2022-06-21

![AppVersion: v0.6.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.6.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update to 0.6.0 

### Default value changes

```diff
# No changes in this release
```

## 0.5.0 

**Release date:** 2022-06-03

![AppVersion: v0.5.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.5.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.5.0 (#13) 

### Default value changes

```diff
# No changes in this release
```

## 0.2.16 

**Release date:** 2022-05-06

![AppVersion: v0.2.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.2.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Chart.yaml 

### Default value changes

```diff
# No changes in this release
```

## 0.2.15 

**Release date:** 2022-05-06

![AppVersion: v0.2.0](https://img.shields.io/static/v1?label=AppVersion&message=v0.2.0&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.2.0 

### Default value changes

```diff
# No changes in this release
```

## 0.2.14 

**Release date:** 2022-04-07

![AppVersion: v0.1.21](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.21&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.2.14, copia v0.1.21 

### Default value changes

```diff
# No changes in this release
```

## 0.2.13 

**Release date:** 2022-04-01

![AppVersion: v0.1.20](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.20&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.2.13 

### Default value changes

```diff
# No changes in this release
```

## 0.2.12 

**Release date:** 2022-03-31

![AppVersion: v0.1.19](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.19&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v 0.2.12 
* change v15.0, not 15.1 
* v15 support 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 2747a34..a49f23d 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -50,6 +50,8 @@ deployment:
     #   value: https://rockwell-tools.copia.io/convertOctetStream
     # - name: ZAP14_CONVERSION_URL
     #   value: http://zap2zipv14.copia.io:9694
+    # - name: ZAP15_0_CONVERSION_URL
+    #   value: http://zap2zipv15-0.copia.io:9695
     # - name: ZAP15_CONVERSION_URL
     #   value: http://zap2zipv15.copia.io:9695
     # - name: ZAP16_CONVERSION_URL
@@ -60,6 +62,8 @@ deployment:
     #   value: https://rockwell-tools.copia.io/convertL5xToAcd
     # - name: ZAP14_IMPORT_CONVERSION_URL
     #   value: http://zap2zipv14.copia.io:9694/import
+    # - name: ZAP15_0_IMPORT_CONVERSION_URL
+    #   value: http://zap2zipv15-0.copia.io:9695/import
     # - name: ZAP15_IMPORT_CONVERSION_URL
     #   value: http://zap2zipv15.copia.io:9695/import
     # - name: ZAP16_IMPORT_CONVERSION_URL
```

## 0.2.11 

**Release date:** 2022-03-24

![AppVersion: v0.1.19](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.19&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* v0.2.11 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 0ac19ae..2747a34 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -100,6 +100,8 @@ copia:
     enabled: false
   readinessProbe:
     enabled: false
+  startupProbe:
+    enabled: false
   customStartupProbe:
     httpGet:
       path: /
```

## 0.2.10 

**Release date:** 2022-03-24

![AppVersion: v0.1.19](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.19&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment application version 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index f9bd685..0ac19ae 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -98,25 +98,23 @@ signing:
 copia:
   livenessProbe:
     enabled: false
-    initialDelaySeconds: 200
-    timeoutSeconds: 1
-    periodSeconds: 10
-    successThreshold: 1
-    failureThreshold: 10
   readinessProbe:
     enabled: false
-    initialDelaySeconds: 5
-    timeoutSeconds: 1
-    periodSeconds: 10
-    successThreshold: 1
-    failureThreshold: 3
-  startupProbe:
-    enabled: false
-    initialDelaySeconds: 60
-    timeoutSeconds: 1
-    periodSeconds: 10
-    successThreshold: 1
-    failureThreshold: 10
+  customStartupProbe:
+    httpGet:
+      path: /
+      port: 4001
+    initialDelaySeconds: 10
+    periodSeconds      : 5
+    timeoutSeconds     : 2
+    failureThreshold   : 10
+  customLivenessProbe:
+    httpGet:
+      path: /
+      port: 4001
+    periodSeconds   : 10
+    timeoutSeconds  : 2
+    failureThreshold: 2
   # config:
   #   APP_NAME: "Copia"
   #   RUN_MODE: production
```

## 0.2.9 

**Release date:** 2022-03-15

![AppVersion: v0.1.18](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.18&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Version 0.2.8 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 80cae2e..f9bd685 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -45,9 +45,33 @@ nodeSelector: {}
 tolerations: []
 affinity: {}
 deployment:
-  env: []
-    # - name: VARIABLE
-    #   value: my-value
+  env:
+    # - name: ACD_CONVERSION_URL
+    #   value: https://rockwell-tools.copia.io/convertOctetStream
+    # - name: ZAP14_CONVERSION_URL
+    #   value: http://zap2zipv14.copia.io:9694
+    # - name: ZAP15_CONVERSION_URL
+    #   value: http://zap2zipv15.copia.io:9695
+    # - name: ZAP16_CONVERSION_URL
+    #   value: http://zap2zip.copia.io:9696
+    # - name: ZAP17_CONVERSION_URL
+    #   value: http://zap2zipv17.copia.io:9697
+    # - name: ACD_IMPORT_CONVERSION_URL
+    #   value: https://rockwell-tools.copia.io/convertL5xToAcd
+    # - name: ZAP14_IMPORT_CONVERSION_URL
+    #   value: http://zap2zipv14.copia.io:9694/import
+    # - name: ZAP15_IMPORT_CONVERSION_URL
+    #   value: http://zap2zipv15.copia.io:9695/import
+    # - name: ZAP16_IMPORT_CONVERSION_URL
+    #   value: http://zap2zip.copia.io:9696/import
+    # - name: ZAP17_IMPORT_CONVERSION_URL
+    #   value: http://zap2zipv17.copia.io:9697/import
+    # - name: CODESYS_CONVERSION_URL
+    #   value: http://codesys.copia.io:8888/export
+    # - name: CODESYS_IMPORT_CONVERSION_URL
+    #   value: http://codesys.copia.io:8888/import
+    # - name: CONTROL_EXPERT_CONVERSION_URL
+    #   value: http://control-expert.copia.io:9696/export
   terminationGracePeriodSeconds: 60
   labels: {}
   rollingUpdate:
```

## 0.2.8 

**Release date:** 2022-01-16

![AppVersion: v0.1.17](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.17&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment chart version 
* Adding preStop hook 

### Default value changes

```diff
# No changes in this release
```

## 0.2.7 

**Release date:** 2022-01-16

![AppVersion: v0.1.17](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.17&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Adding terminationGracePeriodSeconds 

### Default value changes

```diff
# No changes in this release
```

## 0.2.6 

**Release date:** 2022-01-16

![AppVersion: v0.1.17](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.17&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Parameterize rollingUpdate parameters 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 433c0e0..80cae2e 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -50,6 +50,9 @@ deployment:
     #   value: my-value
   terminationGracePeriodSeconds: 60
   labels: {}
+  rollingUpdate:
+    maxSurge: 1
+    maxUnavailable: 0
 persistence:
   enabled: true
   existingClaim:
```

## 0.2.5 

**Release date:** 2022-01-16

![AppVersion: v0.1.17](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.17&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Parameterize replicaCount 

### Default value changes

```diff
# No changes in this release
```

## 0.2.4 

**Release date:** 2021-12-07

![AppVersion: v0.1.16](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.16&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update app to 0.1.16 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index fdfc495..433c0e0 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -2,7 +2,6 @@ replicaCount: 1
 clusterDomain: cluster.local
 image:
   repository: copiaio/copia
-  tag: v0.1.12
   pullPolicy: Always
 imagePullSecrets: []
 service:
```

## 0.2.3 

**Release date:** 2021-11-21

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Version increment 
* Remove extra labels from matchLabels 

### Default value changes

```diff
# No changes in this release
```

## 0.2.2 

**Release date:** 2021-11-21

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment chart version 
* Change "statefulset" to "deployment" 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index f361ccc..fdfc495 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -45,7 +45,7 @@ resources: {}
 nodeSelector: {}
 tolerations: []
 affinity: {}
-statefulset:
+deployment:
   env: []
     # - name: VARIABLE
     #   value: my-value
@@ -60,7 +60,7 @@ persistence:
   labels: {}
   annotations: {}
   # storageClass:
-# additional volumes to add to the statefulset.
+# additional volumes to add to the deployment.
 extraVolumes:
 extraVolumeMounts:
 # bash shell script copied verbatim to the start of the init-container.
```

## 0.2.1 

**Release date:** 2021-11-21

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Properly determine app version to use 

### Default value changes

```diff
# No changes in this release
```

## 0.2.0 

**Release date:** 2021-11-21

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Use deployment vs. statefulset 

### Default value changes

```diff
# No changes in this release
```

## 0.1.1 

**Release date:** 2021-11-20

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Using subPath for app.ini 

### Default value changes

```diff
# No changes in this release
```

## 0.1.0 

**Release date:** 2021-11-18

![AppVersion: v0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=v0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Template configuration 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index b2a0907..f361ccc 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -91,14 +91,14 @@ copia:
     periodSeconds: 10
     successThreshold: 1
     failureThreshold: 10
-  config:
-    APP_NAME: "Copia"
-    RUN_MODE: production
-    oauth2:
-      JWT_SECRET: <REQUIRED>
-    security:
-      INTERNAL_TOKEN: <REQUIRED>
-    server:
-      LFS_JWT_SECRET: <REQUIRED>
-    copia:
-      LICENSE_KEY: <REQUIRED>
+  # config:
+  #   APP_NAME: "Copia"
+  #   RUN_MODE: production
+  #   oauth2:
+  #     JWT_SECRET: <REQUIRED>
+  #   security:
+  #     INTERNAL_TOKEN: <REQUIRED>
+  #   server:
+  #     LFS_JWT_SECRET: <REQUIRED>
+  #   copia:
+  #     LICENSE_KEY: <REQUIRED>
```

## 0.0.12 

**Release date:** 2021-11-11

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment chart version 
* Alllow custom path configs 

### Default value changes

```diff
# No changes in this release
```

## 0.0.11 

**Release date:** 2021-11-10

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Still include extra configuration 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index f361ccc..b2a0907 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -91,14 +91,14 @@ copia:
     periodSeconds: 10
     successThreshold: 1
     failureThreshold: 10
-  # config:
-  #   APP_NAME: "Copia"
-  #   RUN_MODE: production
-  #   oauth2:
-  #     JWT_SECRET: <REQUIRED>
-  #   security:
-  #     INTERNAL_TOKEN: <REQUIRED>
-  #   server:
-  #     LFS_JWT_SECRET: <REQUIRED>
-  #   copia:
-  #     LICENSE_KEY: <REQUIRED>
+  config:
+    APP_NAME: "Copia"
+    RUN_MODE: production
+    oauth2:
+      JWT_SECRET: <REQUIRED>
+    security:
+      INTERNAL_TOKEN: <REQUIRED>
+    server:
+      LFS_JWT_SECRET: <REQUIRED>
+    copia:
+      LICENSE_KEY: <REQUIRED>
```

## 0.0.10 

**Release date:** 2021-11-10

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Default to NodePort type 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index df63dd2..f361ccc 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -7,12 +7,12 @@ image:
 imagePullSecrets: []
 service:
   http:
-    type: ClusterIP
+    type: NodePort
     port: 3000
-    clusterIP: None
+    targetPort: 4001
+    # clusterIP: None
     #loadBalancerIP:
     #nodePort:
-    #targetPort: 4001
     #externalTrafficPolicy:
     #externalIPs:
     loadBalancerSourceRanges: []
@@ -91,14 +91,14 @@ copia:
     periodSeconds: 10
     successThreshold: 1
     failureThreshold: 10
-  config:
-    APP_NAME: "Copia"
-    RUN_MODE: production
-    oauth2:
-      JWT_SECRET: <REQUIRED>
-    security:
-      INTERNAL_TOKEN: <REQUIRED>
-    server:
-      LFS_JWT_SECRET: <REQUIRED>
-    copia:
-      LICENSE_KEY: <REQUIRED>
+  # config:
+  #   APP_NAME: "Copia"
+  #   RUN_MODE: production
+  #   oauth2:
+  #     JWT_SECRET: <REQUIRED>
+  #   security:
+  #     INTERNAL_TOKEN: <REQUIRED>
+  #   server:
+  #     LFS_JWT_SECRET: <REQUIRED>
+  #   copia:
+  #     LICENSE_KEY: <REQUIRED>
```

## 0.0.9 

**Release date:** 2021-11-10

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment app version in both places 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 89bedee..df63dd2 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -2,7 +2,7 @@ replicaCount: 1
 clusterDomain: cluster.local
 image:
   repository: copiaio/copia
-  tag: v0.1.11
+  tag: v0.1.12
   pullPolicy: Always
 imagePullSecrets: []
 service:
```

## 0.0.8 

**Release date:** 2021-11-10

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Increment version 

### Default value changes

```diff
# No changes in this release
```

## 0.0.7 

**Release date:** 2021-11-10

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Merge branch 'main' of github.com:copia-automation/copia-helm-chart 

### Default value changes

```diff
# No changes in this release
```

## 0.0.6 

**Release date:** 2021-11-10

![AppVersion: 0.1.11](https://img.shields.io/static/v1?label=AppVersion&message=0.1.11&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Use targetPort if configured 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index 33af68e..89bedee 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -12,6 +12,7 @@ service:
     clusterIP: None
     #loadBalancerIP:
     #nodePort:
+    #targetPort: 4001
     #externalTrafficPolicy:
     #externalIPs:
     loadBalancerSourceRanges: []
```

## 0.0.7 

**Release date:** 2021-10-25

![AppVersion: 0.1.12](https://img.shields.io/static/v1?label=AppVersion&message=0.1.12&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Update Chart.yaml 

### Default value changes

```diff
# No changes in this release
```

## 0.0.6 

**Release date:** 2021-10-21

![AppVersion: 0.1.11](https://img.shields.io/static/v1?label=AppVersion&message=0.1.11&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Attempt fixing persistent volume 

### Default value changes

```diff
# No changes in this release
```

## 0.0.5 

**Release date:** 2021-10-19

![AppVersion: 0.1.11](https://img.shields.io/static/v1?label=AppVersion&message=0.1.11&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Upgrade helm chart version 

### Default value changes

```diff
diff --git a/charts/copia/values.yaml b/charts/copia/values.yaml
index b125adc..33af68e 100644
--- a/charts/copia/values.yaml
+++ b/charts/copia/values.yaml
@@ -2,7 +2,7 @@ replicaCount: 1
 clusterDomain: cluster.local
 image:
   repository: copiaio/copia
-  tag: latest
+  tag: v0.1.11
   pullPolicy: Always
 imagePullSecrets: []
 service:
```

## 0.0.4 

**Release date:** 2021-09-29

![AppVersion: 0.0.1](https://img.shields.io/static/v1?label=AppVersion&message=0.0.1&color=success&logo=)
![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)


* Add to charts subfolder 

### Default value changes

```diff
replicaCount: 1
clusterDomain: cluster.local
image:
  repository: copiaio/copia
  tag: latest
  pullPolicy: Always
imagePullSecrets: []
service:
  http:
    type: ClusterIP
    port: 3000
    clusterIP: None
    #loadBalancerIP:
    #nodePort:
    #externalTrafficPolicy:
    #externalIPs:
    loadBalancerSourceRanges: []
    annotations:
ingress:
  enabled: false
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: git.example.com
      paths:
        - path: /
          pathType: Prefix
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - git.example.com
resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi
## Use an alternate scheduler, e.g. "stork".
## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
##
# schedulerName:
nodeSelector: {}
tolerations: []
affinity: {}
statefulset:
  env: []
    # - name: VARIABLE
    #   value: my-value
  terminationGracePeriodSeconds: 60
  labels: {}
persistence:
  enabled: true
  existingClaim:
  size: 10Gi
  accessModes:
    - ReadWriteOnce
  labels: {}
  annotations: {}
  # storageClass:
# additional volumes to add to the statefulset.
extraVolumes:
extraVolumeMounts:
# bash shell script copied verbatim to the start of the init-container.
initPreScript: ""
# Configure commit/action signing prerequisites
signing:
  enabled: false
  gpgHome: /data/git/.gnupg
copia:
  livenessProbe:
    enabled: false
    initialDelaySeconds: 200
    timeoutSeconds: 1
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 10
  readinessProbe:
    enabled: false
    initialDelaySeconds: 5
    timeoutSeconds: 1
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 3
  startupProbe:
    enabled: false
    initialDelaySeconds: 60
    timeoutSeconds: 1
    periodSeconds: 10
    successThreshold: 1
    failureThreshold: 10
  config:
    APP_NAME: "Copia"
    RUN_MODE: production
    oauth2:
      JWT_SECRET: <REQUIRED>
    security:
      INTERNAL_TOKEN: <REQUIRED>
    server:
      LFS_JWT_SECRET: <REQUIRED>
    copia:
      LICENSE_KEY: <REQUIRED>
```

---
Autogenerated from Helm Chart and git history using [helm-changelog](https://github.com/mogensen/helm-changelog)
