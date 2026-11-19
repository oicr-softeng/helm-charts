{{- /*
Refuses `configMaps` values that Kubernetes would reject, or that would mount files where the user
did not mean them, naming the rule each one breaks. The volume is named `configmap-<name>`, and a
volume name holds at most 63 characters, so an entry's name holds at most 53.
*/ -}}
{{- define "stateless-svc.validateConfigMaps" -}}
  {{- $entriesByPath := dict -}}
  {{- range $name, $entry := .Values.configMaps }}
    {{- if not (regexMatch "^[a-z0-9]([-a-z0-9]{0,51}[a-z0-9])?$" $name) }}
      {{- fail (printf "configMaps.%s: an entry's name uses lowercase letters, digits and '-', starts and ends with a letter or digit, and holds at most 53 characters" $name) }}
    {{- end }}

    {{- $path := $entry.path | default "" | toString -}}
    {{- if not (hasPrefix "/" $path) }}
      {{- fail (printf "configMaps.%s.path must be an absolute directory, such as /app/configs" $name) }}
    {{- end }}
    {{- if hasKey $entriesByPath $path }}
      {{- fail (printf "configMaps.%s and configMaps.%s share the path %s; each entry needs a directory of its own" (get $entriesByPath $path) $name $path) }}
    {{- end }}
    {{- $_ := set $entriesByPath $path $name -}}

    {{- if not $entry.files }}
      {{- fail (printf "configMaps.%s lists no files" $name) }}
    {{- end }}
    {{- range $file, $content := $entry.files }}
      {{- if or (not (regexMatch "^[-._a-zA-Z0-9]+$" $file)) (eq $file ".") (eq $file "..") }}
        {{- fail (printf "configMaps.%s.files: %s is not a file name a ConfigMap can hold; use letters, digits, '-', '_' and '.', and put a subdirectory in an entry of its own" $name $file) }}
      {{- end }}
      {{- if not (kindIs "string" $content) }}
        {{- fail (printf "configMaps.%s.files.%s must be text; quote the value" $name $file) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}
