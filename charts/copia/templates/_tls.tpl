{{/*
TLS for Copia and conversion manager. See the tls block in values.yaml.
*/}}

{{- define "copia.tls.copiaSecretName" -}}
{{- $t := .Values.tls | default dict -}}
{{- $c := $t.copia | default dict -}}
{{- if $c.secretName -}}
{{- $c.secretName -}}
{{- else if or $c.certificate $c.privateKey -}}
{{- printf "%s-tls" (include "app.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Falls back to the Copia Secret when conversion manager sets nothing. */}}
{{- define "copia.tls.cmSecretName" -}}
{{- $t := .Values.tls | default dict -}}
{{- $m := $t.conversionManager | default dict -}}
{{- if $m.secretName -}}
{{- $m.secretName -}}
{{- else if or $m.certificate $m.privateKey -}}
{{- printf "%s-tls" (include "app.conversion-manager.fullname" .) -}}
{{- else -}}
{{- include "copia.tls.copiaSecretName" . -}}
{{- end -}}
{{- end -}}

{{- define "copia.tls.termination" -}}
{{- if include "copia.tls.copiaSecretName" . -}}
{{- dig "termination" "pod" (.Values.tls | default dict) -}}
{{- end -}}
{{- end -}}

{{- define "copia.tls.pod" -}}
{{- eq (include "copia.tls.termination" .) "pod" -}}
{{- end -}}

{{- define "copia.tls.ingress" -}}
{{- eq (include "copia.tls.termination" .) "ingress" -}}
{{- end -}}

{{- define "copia.tls.copiaMountPath" -}}/etc/copia/tls{{- end -}}
{{- define "copia.tls.cmMountPath" -}}/etc/conversion-manager/tls{{- end -}}

{{/*
Pod annotation value that changes when the certificate changes. A Secret the
chart does not create is read from the cluster at deploy time. A Secret the
chart creates is hashed from values only, because the cluster still holds the
previous certificate during the upgrade that replaces it.
*/}}
{{- define "copia.tls.checksum" -}}
{{- $data := dict -}}
{{- if not .certificate -}}
{{- $data = dig "data" dict (lookup "v1" "Secret" .root.Release.Namespace .secretName) -}}
{{- end -}}
{{- toJson (dict "name" .secretName "certificate" (.certificate | default "") "privateKey" (.privateKey | default "") "data" $data) | sha256sum -}}
{{- end -}}

{{- define "copia.tls.copiaChecksum" -}}
{{- $c := (.Values.tls | default dict).copia | default dict -}}
{{- include "copia.tls.checksum" (dict "root" . "secretName" (include "copia.tls.copiaSecretName" .) "certificate" $c.certificate "privateKey" $c.privateKey) -}}
{{- end -}}

{{- define "copia.tls.cmChecksum" -}}
{{- $t := .Values.tls | default dict -}}
{{- $m := $t.conversionManager | default dict -}}
{{- if not (or $m.secretName $m.certificate $m.privateKey) -}}
{{- $m = $t.copia | default dict -}}
{{- end -}}
{{- include "copia.tls.checksum" (dict "root" . "secretName" (include "copia.tls.cmSecretName" .) "certificate" $m.certificate "privateKey" $m.privateKey) -}}
{{- end -}}

{{/* An httpGet probe with its scheme set to .scheme. Other probes pass through. */}}
{{- define "copia.tls.probe" -}}
{{- $p := deepCopy .probe -}}
{{- if $p.httpGet -}}
{{- $_ := set $p.httpGet "scheme" .scheme -}}
{{- end -}}
{{- toYaml $p -}}
{{- end -}}

{{- define "copia.tls.isTrue" -}}
{{- eq (toString .) "true" -}}
{{- end -}}

{{/*
Fails the render on settings that would leave TLS broken or terminated in two
places at once. Only the tls block is checked, so installs without it render
as they did before it existed.
*/}}
{{- define "copia.tls.validate" -}}
{{- $t := .Values.tls | default dict -}}
{{- $c := $t.copia | default dict -}}
{{- $m := $t.conversionManager | default dict -}}
{{- $cm := .Values.conversion_manager_service | default dict -}}
{{- $cmOn := eq (toString $cm.enabled) "true" -}}
{{- $cmIngress := $cm.ingress | default dict -}}
{{- $ingress := .Values.ingress | default dict -}}
{{- $gatewayApi := .Values.gatewayApi | default dict -}}
{{- $gatewayApiOn := eq (toString $gatewayApi.enabled) "true" -}}
{{- $service := .Values.service | default dict -}}
{{- $serviceHttp := $service.http | default dict -}}
{{- $cmService := $cm.service | default dict -}}
{{- $cmServiceHttp := $cmService.http | default dict -}}
{{- $server := dig "config" "server" dict (.Values.copia | default dict) -}}
{{- $copiaHttps := eq (lower (toString (index $server "PROTOCOL" | default ""))) "https" -}}
{{- $cmHttps := eq "true" (include "copia.tls.isTrue" (dig "configmap" "ENABLE_HTTPS" false $cm)) -}}
{{- $termination := include "copia.tls.termination" . -}}
{{- range $pair := list (list "tls.copia" $c) (list "tls.conversionManager" $m) -}}
{{- $path := index $pair 0 -}}
{{- $v := index $pair 1 -}}
{{- if and $v.certificate (not $v.privateKey) -}}
{{- fail (printf "%s.certificate is set without %s.privateKey." $path $path) -}}
{{- end -}}
{{- if and $v.privateKey (not $v.certificate) -}}
{{- fail (printf "%s.privateKey is set without %s.certificate." $path $path) -}}
{{- end -}}
{{- end -}}
{{- if and (or $m.secretName $m.certificate) (not (include "copia.tls.copiaSecretName" .)) -}}
{{- fail "tls.conversionManager requires tls.copia. Set tls.copia.secretName, or tls.copia.certificate and tls.copia.privateKey." -}}
{{- end -}}
{{- if and $termination (not (has $termination (list "pod" "ingress"))) -}}
{{- fail (printf "tls.termination must be pod or ingress, not %q." $termination) -}}
{{- end -}}
{{- if and $c.certificate $m.certificate (eq (include "copia.tls.copiaSecretName" .) (include "copia.tls.cmSecretName" .)) -}}
{{- if or (ne $c.certificate $m.certificate) (ne $c.privateKey $m.privateKey) -}}
{{- fail (printf "TLS secret %s is set twice with different certificate material. Give tls.conversionManager its own secretName, or leave it empty to share the Copia certificate." (include "copia.tls.copiaSecretName" .)) -}}
{{- end -}}
{{- end -}}
{{- if eq $termination "pod" -}}
{{- if not (hasKey (.Values.copia | default dict) "config") -}}
{{- fail "tls.termination pod requires copia.config, because the chart writes PROTOCOL, CERT_FILE and KEY_FILE into app.ini." -}}
{{- end -}}
{{- if $ingress.tls -}}
{{- fail "tls.termination is pod, so ingress.tls must be empty. TLS terminates in one place only: remove ingress.tls, or set tls.termination to ingress. An Ingress in front of pod termination must pass TLS through to the pods." -}}
{{- end -}}
{{- if and $cmOn $cmIngress.tls -}}
{{- fail "tls.termination is pod, so conversion_manager_service.ingress.tls must be empty. TLS terminates in one place only: remove it, or set tls.termination to ingress. An Ingress in front of pod termination must pass TLS through to the pods." -}}
{{- end -}}
{{- else if eq $termination "ingress" -}}
{{- if not $ingress.enabled -}}
{{- fail "tls.termination ingress requires ingress.enabled." -}}
{{- end -}}
{{- if $ingress.tls -}}
{{- fail "tls.termination ingress builds the Ingress tls entry from tls.copia, so ingress.tls must be empty." -}}
{{- end -}}
{{- if $cmOn -}}
{{- if not $cmIngress.enabled -}}
{{- fail "tls.termination ingress requires conversion_manager_service.ingress.enabled when conversion manager is enabled." -}}
{{- end -}}
{{- if $cmIngress.tls -}}
{{- fail "tls.termination ingress builds the Ingress tls entry from tls.conversionManager, so conversion_manager_service.ingress.tls must be empty." -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if and (eq $termination "ingress") $copiaHttps -}}
{{- fail "Copia TLS terminates at the Ingress, so copia.config.server.PROTOCOL must not be https. TLS terminates in one place only." -}}
{{- end -}}
{{- if and $cmOn (eq $termination "ingress") $cmHttps -}}
{{- fail "Conversion manager TLS terminates at the Ingress, so conversion_manager_service.configmap.ENABLE_HTTPS must be false. TLS terminates in one place only." -}}
{{- end -}}
{{- if and $cmOn $termination -}}
{{- range $e := (dig "deployment" "env" list $cm) -}}
{{- if and (kindIs "map" $e) (eq (toString $e.name) "ENABLE_HTTPS") -}}
{{- $want := ternary "true" "false" (eq $termination "pod") -}}
{{- if or (hasKey $e "valueFrom") (ne (toString $e.value) $want) -}}
{{- fail (printf "tls.termination is %s, so ENABLE_HTTPS in conversion_manager_service.deployment.env must be the literal %s. Remove it; the chart sets ENABLE_HTTPS." $termination $want) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $gatewayApiOn -}}
{{- if ne $termination "pod" -}}
{{- fail "gatewayApi.enabled requires pod TLS termination. Set tls.copia.secretName, or tls.copia.certificate and tls.copia.privateKey." -}}
{{- end -}}
{{- if not $cmOn -}}
{{- fail "gatewayApi.enabled requires conversion_manager_service.enabled." -}}
{{- end -}}
{{- if $ingress.enabled -}}
{{- fail "gatewayApi.enabled cannot be combined with ingress.enabled." -}}
{{- end -}}
{{- if $cmIngress.enabled -}}
{{- fail "gatewayApi.enabled cannot be combined with conversion_manager_service.ingress.enabled." -}}
{{- end -}}
{{- if ne (toString ($serviceHttp.type | default "")) "ClusterIP" -}}
{{- fail "gatewayApi.enabled requires service.http.type: ClusterIP." -}}
{{- end -}}
{{- if ne (toString ($cmServiceHttp.type | default "")) "ClusterIP" -}}
{{- fail "gatewayApi.enabled requires conversion_manager_service.service.http.type: ClusterIP." -}}
{{- end -}}
{{- $cmSecret := .Values.conversion_manager_service.secret | default dict -}}
{{- if hasKey $cmSecret "HOST" -}}
{{- $bind := toString $cmSecret.HOST -}}
{{- if or (eq $bind "") (eq $bind "localhost") (eq $bind "127.0.0.1") (eq $bind "::1") -}}
{{- fail "gatewayApi.enabled requires conversion_manager_service.secret.HOST to be a non-loopback address." -}}
{{- end -}}
{{- end -}}
{{- range $env := (.Values.conversion_manager_service.deployment.env | default list) -}}
{{- if and (kindIs "map" $env) (eq (toString ($env.name | default "")) "HOST") -}}
{{- if hasKey $env "valueFrom" -}}
{{- fail "gatewayApi.enabled does not support conversion_manager_service.deployment.env HOST from valueFrom." -}}
{{- end -}}
{{- $bind := toString ($env.value | default "") -}}
{{- if or (eq $bind "") (eq $bind "localhost") (eq $bind "127.0.0.1") (eq $bind "::1") -}}
{{- fail "gatewayApi.enabled requires conversion_manager_service.deployment.env HOST to be a non-loopback address." -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
