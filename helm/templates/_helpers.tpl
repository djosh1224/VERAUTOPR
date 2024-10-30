{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rtm-topology-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rtm-topology-api.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rtm-topology-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "rtm-topology-api.labels" -}}
helm.sh/chart: {{ include "rtm-topology-api.chart" . }}
{{ include "rtm-topology-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rtm-topology-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rtm-topology-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Define Market Label
*/}}
{{- define "rtm-topology-api.market" }}
{{- if .Values.market }}
{{- printf .Values.market }}
{{- end }}
{{- end }}

{{/*
Define Environment Label
*/}}
{{- define "rtm-topology-api.env" }}
{{- if .Values.env }}
{{- printf .Values.env }}
{{- end }}
{{- end }}

{{/*
New Relic Labels
*/}}
{{- define "rtm-topology-api.newRelicLabels" -}}
appName: {{ include "rtm-topology-api.name" . }}
market: {{ include "rtm-topology-api.market" . }}
environment: {{ include "rtm-topology-api.env" . }}
{{- end }}

{{/*
EKS Namespace
*/}}
{{- define "rtm-topology-api.namespace" -}}
{{- default "rtm-topology-api-namespace" .Values.namespace | quote -}}
{{- end -}}

{{/*
New Relic insights key
*/}}
{{- define "rtm-topology-api.nrapikey" -}}
{{- .Values.newRelic.apikey | b64enc | quote -}}
{{- end -}}

{{/*
Custom Metric annotations
*/}}
{{- define "rtm-topology-api.customMetric" -}}
{{- $customMetric := (.Values).customMetrics }}
{{- if $customMetric.path }}
prometheus.io/path: {{ $customMetric.path }}
{{- end }}
{{- if $customMetric.enabled }}
prometheus.io/scrape: {{ $customMetric.enabled | quote }}
{{- end }}
{{- if $customMetric.port }}
prometheus.io/port: {{ $customMetric.port | quote }}
{{- end }}
{{- end }}

{{/*
Artifactory credentials to pull docker image
*/}}
{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}