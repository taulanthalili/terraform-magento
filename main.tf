resource "argocd_application" "magento" {
  metadata {
    name      = "magento-${var.environment}"
    namespace = var.namespace
    labels = {
      environment = var.environment
      namespace   = var.namespace
    }
  }
  wait = true
  timeouts {
    create = "20m"
    delete = "10m"
  }
  spec {
    project = var.argocd_project
    source {
      repo_url        = "https://charts.bitnami.com/bitnami"
      chart           = "magento"
      target_revision = var.magento_version.helm
      helm {
        value_files  = ["values.yaml"]
        release_name = var.environment

        parameter {
          name  = "magentoHost"
          value = var.magneto_domain
        }
        parameter {
          name  = "magentoPassword"
          value = var.magento_dev #TODO Dev env only
        }
        parameter {
          name  = "mariadb.auth.password"
          value = var.mariadb_password #
        }
        parameter {
          name  = "mariadb.auth.rootPassword"
          value = var.mariadb_root_password #
        }
        parameter {
          name  = "service.type"
          value = "ClusterIP"
        }
        parameter {
          name  = "service.ports.http"
          value = "80"
        }
        parameter {
          name  = "service.ports.https"
          value = "443"
        }
        parameter {
          name  = "magentoUseHttps"
          value = true
        }
        parameter {
          name  = "magentoUseSecureAdmin"
          value = true
        }
        parameter {
          name  = "ingress.enabled"
          value = true
        }
        parameter {
          name  = "ingress.ingressClassName"
          value = var.ingressClassName
        }
        parameter {
          name  = "ingress.hostname"
          value = var.magneto_domain
        }
        parameter {
          name  = "elasticsearch.ingest.replicaCount" #For Dev env
          value = 0
        }
        parameter {
          name  = "elasticsearch.coordinating.replicaCount" #For Dev env
          value = 0
        }
      }

    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = var.namespace
    }
    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      sync_options = ["Validate=false", "RespectIgnoreDifferences=true"]
      retry {
        limit = "5"
        backoff = {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
    ignore_difference {
      #respectExistingValue = true
      kind          = "Service"
      name          = "${var.environment}-elasticsearch-master-hl"
      json_pointers = ["/spec/clusterIP"]
    }
    ignore_difference {
      kind          = "Service"
      name          = "${var.environment}-elasticsearch-data-hl"
      json_pointers = ["/spec/clusterIP"]
    }
    # ignore_difference {
    #   kind          = "Service"
    #   name          = "${var.environment}-elasticsearch-ingest-hl"
    #   json_pointers = ["/spec/clusterIP"]
    # }
    # ignore_difference {
    #   kind          = "Service"
    #   name          = "${var.environment}-elasticsearch-coordinating-hl"
    #   json_pointers = ["/spec/clusterIP"]
    # }
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}
