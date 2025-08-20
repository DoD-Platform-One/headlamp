{{- /* Returns an SSO host */ -}}
{{- define "sso.host" -}}
  {{- regexReplaceAll ".*//([^/]*)/?.*" .Values.upstream.config.oidc.issuerURL "${1}" -}}
{{- end -}}
