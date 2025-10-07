{{- /*
Render container volumeMounts for given context (container or sidecar). Usage:

  - in containers/sidecars
  {{ include "stateless-svc.renderVolumeMounts" (dict "root" $root "values" .Values) }}

  - for the overall deployment volumes
  {{ include "stateless-svc.renderVolumes" (dict "root" $root "values" .Values) }}
*/ -}}

{{- /* Logic for volume mounts in both container and sidecars */ -}}
{{- define "renderMounts.volume" -}}
- name: {{ index . 0 }}
  mountPath: {{ index . 1 }}
  {{- if index . 2 }}
  readOnly: {{ index . 2 }}
  {{- end }}
{{- end -}}

{{- /* main container */ -}}
{{- define "stateless-svc.renderVolumeMounts" -}}
  {{- $root := index . "root" -}}
  {{- $vals := index . "values" -}}

  {{if or
    (gt (len $vals.mountEmptyDirs) 0)
    (gt (len $vals.mountSecrets) 0)
  }}
  volumeMounts:
    {{- /* top-level emptyDirs */ -}}
    {{ range $ei, $emptyDir := $vals.mountEmptyDirs }}
      {{- $emptyDirVolName := "" -}}
      {{- $path := $emptyDir.name | lower | replace "_" "-" -}}

      {{- if $emptyDir.shared }}
        {{- $emptyDirVolName = $path -}}
      {{- else }}
        {{- $emptyDirVolName := (printf "%s-%s" (include "stateless-svc.fullname" $root) $path) -}}
      {{- end }}

      {{- $mountPath := $emptyDir.path | default (printf "/tmp/%s" $path) -}}

      {{- include "renderMounts.volume" (list $emptyDirVolName $mountPath "") | nindent 4 }}
    {{- end }}

    {{- /* top-level secret mounts */ -}}
    {{- range $i, $secretsVolume := $vals.mountSecrets }}
      {{- $secretsVolName := "" -}}
      {{- $mountPath := "" -}}
      {{- $readOnly := "" -}}
      {{- $path := "" -}}

      {{- if kindIs "string" $secretsVolume }}
        {{- $path = $secretsVolume | lower | replace "_" "-" -}}
        {{- $secretsVolName = printf "%s-%s" (include "stateless-svc.fullname" $root) $path -}}
        {{- $mountPath = printf "/tmp/%s" $path -}}
      {{- else }}
        {{- $path = $secretsVolume.name | lower | replace "_" "-" -}}
        {{- $secretsVolName = printf "%s-%s" (include "stateless-svc.fullname" $root) $path -}}
        {{- $mountPath = $secretsVolume.path | default (printf "/tmp/%s" $path) -}}
        {{- if hasKey $secretsVolume "readOnly" }}
          {{- $readOnly = $secretsVolume.readOnly -}}
        {{- end -}}
      {{- end }}

      {{- include "renderMounts.volume" (list $secretsVolName $mountPath $readOnly) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "stateless-svc.hasSidecarMounts" -}}
  {{- $ctx := . -}}
  {{- $found := false -}}
  {{- range $idx, $sidecar := $ctx.Values.sidecars }}
    {{- if or (gt (len (default list $sidecar.mountEmptyDirs)) 0) (gt (len (default list $sidecar.mountSecrets)) 0) }}
      {{- $found = true -}}
      {{- break -}}
    {{- end }}
  {{- end }}
  {{- if $found }}true{{- else }}false{{- end }}
{{- end -}}

{{- /* sidecars */ -}}
{{- define "stateless-svc.renderSidecars" -}}
  {{- $root := index . "root" -}}
  {{- $vals := index . "values" -}}

  {{- if eq (include "stateless-svc.hasSidecarMounts" $root) "true" -}}
    {{ "" }}
    {{- range $si, $sidecarFromValues := $vals.sidecars }}
      {{- $sidecar := dict -}}
      {{- range $key, $value := $sidecarFromValues }}
        {{- if and
          (ne $key "mountEmptyDirs")
          (ne $key "mountSecrets")
        }}
          {{- $_ := set $sidecar $key $value -}}
        {{- end }}
      {{- end -}}

      {{- $yaml := toYaml $sidecar | trim -}}
      {{- $lines := splitList "\n" $yaml -}}

      {{- if gt (len $lines) 0 }}
      - {{ index $lines 0 }}
          {{- range $si, $line := rest $lines }}
        {{ $line | printf "%s" }}
          {{- end }}
      {{- end -}}

      {{- if or $sidecarFromValues.mountEmptyDirs $sidecarFromValues.mountSecrets }}
        volumeMounts:
        {{- range $sidecarEmptyDir := $sidecarFromValues.mountEmptyDirs -}}
          {{- $emptyDirVolName := "" -}}
          {{- $path := $sidecarEmptyDir.name | lower | replace "_" "-" -}}

          {{- if $sidecarEmptyDir.shared }}
            {{- $emptyDirVolName = $path -}}
          {{- else }}
            {{- $emptyDirVolName := (printf "%s-%s"
              $sidecarFromValues.name
              ($sidecarEmptyDir.name | lower | replace "_" "-")
            ) -}}
          {{- end -}}

          {{- $mountPath := $sidecarEmptyDir.path | default (printf "/tmp/%s" $path) -}}

          {{- include "renderMounts.volume" (list $emptyDirVolName $mountPath "") | nindent 8 -}}
        {{- end }}

        {{- range $j, $sidecarSecretsVolume := $sidecarFromValues.mountSecrets }}
          {{- $sidecarSecretsVolName := "" -}}
          {{- $mountPath := "" -}}
          {{- $readOnly := "" -}}
          {{- $path := "" -}}

          {{- if kindIs "string" $sidecarSecretsVolume }}
            {{- $path = $sidecarSecretsVolume | lower | replace "_" "-" -}}
            {{- $sidecarSecretsVolName = printf "%s-%s" $sidecarFromValues.name $path -}}
            {{- $mountPath = printf "/tmp/%s" $path -}}
          {{- else }}
            {{- $path = $sidecarSecretsVolume.name | lower | replace "_" "-" -}}
            {{- $sidecarSecretsVolName = (printf "%s-%s"
              $sidecarFromValues.name
              ($sidecarSecretsVolume.name | lower | replace "_" "-")
            ) -}}
            {{- $mountPath = ($sidecarSecretsVolume.path |
              default (printf "/tmp/%s"
                ($sidecarSecretsVolume.secret.secretName | lower | replace "_" "-") |
                default $path
              )
            ) -}}
            {{- if hasKey $sidecarSecretsVolume "readOnly" }}
              {{- $readOnly = $sidecarSecretsVolume.readOnly -}}
            {{- end }}
          {{- end -}}

          {{- include "renderMounts.volume" (list $sidecarSecretsVolName $mountPath $readOnly) | nindent 8 -}}
        {{- end }}
      {{- end }}
      {{ "" }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /* Render initContainers for copying files into emptyDir volumes */ -}}
{{- define "stateless-svc.renderInitContainers" -}}
  {{- $root := index . "root" -}}
  {{- $vals := index . "values" -}}

  {{- $needsInit := false -}}
  {{- range $emptyDir := $vals.mountEmptyDirs }}
    {{- if or $emptyDir.preserveOriginal $emptyDir.copyFromAltPath }}
      {{- $needsInit = true -}}
    {{- end }}
  {{- end }}

  {{- /* Render initContainers for copying files into emptyDir volumes */ -}}
  {{- if $needsInit }}
  {{- /* this conditional logic may change later if we wanted to allow
       * initContainers for other purposes like DB migrations, theming, etc. */ -}}
  initContainers:
    {{- range $ei, $emptyDir := $vals.mountEmptyDirs -}}
      {{- if or $emptyDir.preserveOriginal $emptyDir.copyFromAltPath }}
        {{- $path := $emptyDir.name | lower | replace "_" "-" }}
        {{- $mountPath := $emptyDir.path | default (printf "/tmp/%s" $path) }}
        {{- $emptyDirVolName := "" -}}

        {{- if $emptyDir.shared }}
          {{- $emptyDirVolName = $path -}}
        {{- else }}
          {{- $emptyDirVolName = (printf "%s-%s" (include "stateless-svc.fullname" $root) $path) -}}
        {{- end }}
      {{- "" }}
    - name: copy-{{ $path }}
      image: {{ $vals.image.repository }}:{{ $vals.image.tag | default $root.Chart.AppVersion }}
      command: ['sh', '-c']
      args:
        - |
          {{- if $emptyDir.preserveOriginal }}
          if [ -d "{{ $mountPath }}" ]; then
            echo "Copying original contents from {{ $mountPath }} to /init-data/..."
            cp -r {{ $mountPath }}/. /init-data/
            echo "Original contents copied successfully"
          else
            echo "Original directory {{ $mountPath }} does not exist, skipping"
          fi
          {{- end }}
          {{- if $emptyDir.copyFromAltPath }}
          if [ -d "{{ $emptyDir.copyFromAltPath }}" ]; then
            echo "Copying alternate contents from {{ $emptyDir.copyFromAltPath }} to /init-data/..."
            cp -rp {{ $emptyDir.copyFromAltPath }}/. /init-data/ || cp -r {{ $emptyDir.copyFromAltPath }}/. /init-data/
            echo "Alternate contents copied successfully (overwrites any duplicates)"
          else
            echo "Alternate directory {{ $emptyDir.copyFromAltPath }} does not exist, skipping"
          fi
          {{- end }}
      volumeMounts:
        - name: {{ $emptyDirVolName }}
          mountPath: /init-data

      {{- if $vals.securityContext }}
      securityContext:
        {{- toYaml $vals.securityContext | nindent 8 }}
      {{- end }}

      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /* logic for volumes */ -}}

{{- define "renderVolumes.emptyDir" -}}
- name: {{ index . 0 }}
  emptyDir: {}
{{- end -}}

{{- define "renderVolumes.secret" -}}
- name: {{ index . 0 }}
  secret:
    secretName: {{ index . 1 }}
    defaultMode: {{ index . 2 }}
{{- end -}}

{{- define "stateless-svc.renderVolumes" -}}
  {{- $root := index . "root" -}}
  {{- $vals := index . "values" -}}

  {{- /* build volumes only if any mounts or sidecars exist */ -}}
  {{- if or
    (gt (len $vals.mountEmptyDirs) 0)
    (gt (len $vals.mountSecrets) 0)
    (gt (len $vals.sidecars) 0)
  }}
  volumes:
    {{- $seen := dict -}}

    {{- range $ei, $emptyDir := $vals.mountEmptyDirs }}
      {{- $emptyDirVolName := "" -}}
      {{- $givenName := ($emptyDir.name | lower | replace "_" "-") -}}

      {{- if $emptyDir.shared }}
        {{- $emptyDirVolName = $givenName -}}
      {{- else }}
        {{- $emptyDirVolName = (printf "%s-%s"
          (include "stateless-svc.fullname" $root)
          $givenName
        ) | nindent 4 -}}
      {{- end -}}

      {{- if not (hasKey $seen $emptyDirVolName) }}
        {{- $_ := set $seen $emptyDirVolName true -}}
        {{- include "renderVolumes.emptyDir" (list $emptyDirVolName) | nindent 4 }}
      {{- end }}
    {{- end }}

    {{- range $i, $secretsVolume := $vals.mountSecrets }}
      {{- $secretsVolName := "" -}}
      {{- $secretName := "" -}}
      {{- $mode := "0644" -}}

      {{- if kindIs "string" $secretsVolume }}
        {{- $secretsVolName = (printf "%s-%s"
          (include "stateless-svc.fullname" $root)
          ($secretsVolume | lower | replace "_" "-")
        ) -}}
        {{- $secretName = $secretsVolume -}}
      {{- else }}
        {{- $secretsVolName := (printf "%s-%s"
          (include "stateless-svc.fullname" $root)
          ($secretsVolume.name | lower | replace "_" "-")
        ) -}}
        {{- $secretName = $secretsVolume.secret.secretName | default $secretsVolume.name -}}
        {{- $mode = ($secretsVolume.defaultMode | default "0644") -}}
      {{- end }}

      {{- if not (hasKey $seen $secretsVolName) }}
        {{- $_ := set $seen $secretsVolName true -}}
        {{- include "stateless-svc.renderVolumes" (list $secretsVolName $secretName $mode) | nindent 4 }}
      {{- end }}
    {{- end }}

    {{- range $si, $sidecar := $vals.sidecars }}
      {{- range $sidecarEmptyDir := $sidecar.mountEmptyDirs }}
        {{- $emptyDirVolName := "" -}}
        {{- $givenName := ($sidecarEmptyDir.name | lower | replace "_" "-") -}}

        {{- if $sidecarEmptyDir.shared }}
          {{- $emptyDirVolName = $givenName -}}
        {{- else }}
          {{- $emptyDirVolName = (printf "%s-%s" $sidecar.name $givenName) -}}
        {{- end }}

        {{- if not (hasKey $seen $emptyDirVolName) }}
          {{- $_ := set $seen $emptyDirVolName true -}}
          {{- include "renderVolumes.emptyDir" (list $emptyDirVolName) | nindent 4 }}
        {{- end }}
      {{- end }}

      {{- range $sidecarSecretsVolume := $sidecar.mountSecrets }}
        {{- $sidecarSecretsVolName := "" -}}
        {{- $secretName := "" -}}
        {{- $mode := "0644" -}}

        {{- if kindIs "string" $sidecarSecretsVolume }}
          {{- $sidecarSecretsVolName = (printf "%s-%s"
            $sidecar.name
            ($sidecarSecretsVolume | lower | replace "_" "-")
          ) -}}
          {{- $secretName = $sidecarSecretsVolume -}}
        {{- else }}
          {{- $sidecarSecretsVolName = (printf "%s-%s"
            $sidecar.name
            ($sidecarSecretsVolume.name | lower | replace "_" "-")
          ) -}}
          {{- $secretName = $sidecarSecretsVolume.secret.secretName | default $sidecarSecretsVolume.name -}}
          {{- $mode = ($sidecarSecretsVolume.defaultMode | default "0644") -}}
        {{- end }}

        {{- if not (hasKey $seen $sidecarSecretsVolName) }}
          {{- $_ := set $seen $sidecarSecretsVolName true -}}
          {{- include "stateless-svc.renderVolumes" (list $sidecarSecretsVolName $secretName $mode) | nindent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
