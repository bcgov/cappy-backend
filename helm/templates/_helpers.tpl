{{/*
Expand the name of the chart.
*/}}
{{- define "laravel-octane.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "laravel-octane.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "laravel-octane.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "laravel-octane.labels" -}}
helm.sh/chart: {{ include "laravel-octane.chart" . }}
{{ include "laravel-octane.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "laravel-octane.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laravel-octane.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Redis labels
*/}}
{{- define "laravel-octane.redis.labels" -}}
helm.sh/chart: {{ include "laravel-octane.chart" . }}
{{ include "laravel-octane.redis.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Redis selector labels
*/}}
{{- define "laravel-octane.redis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "laravel-octane.name" . }}-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}