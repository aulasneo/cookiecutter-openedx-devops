
## @param tolerations Tolerations for pod assignment. Evaluated as a template.
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: node-group
            operator: In
            values:
            - wordpress
tolerations:
- key: {{ cookiecutter.global_root_domain }}/wordpress-only
  operator: Exists
  effect: NoSchedule
## Database configuration
##
db:
  ## @param db.allowArbitraryServer Enable connection to arbitrary MySQL server
  ## If you do not want the user to be able to specify an arbitrary MySQL server at login time, set this to false
  ##
  allowArbitraryServer: false
  ## @param db.port Database port to use to connect
  ##
  port: ${externalDatabasePort}
  ## @param db.host Database Hostname. Ignored when `db.chartName` is set.
  ## e.g:
  ## host: foo
  ##
  host: ${externalDatabaseHost}
  ## @param db.bundleTestDB Deploy a MariaDB instance for testing purposes
  ##

## Service account for PhpMyAdmin to use.
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
##
serviceAccount:
  create: true
