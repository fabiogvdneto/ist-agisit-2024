variable "project" {
  type = string
}

variable "gcr-repo" {
  type = string
}

variable "gcr-region" {
  type = string
}

#################################################################
# Defines the Frontend Pods for the Project
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app  = "application-frontend"
      tier = "frontend"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
    delete = "2m"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "application-frontend"
        tier = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "application-frontend"
          tier = "frontend"
        }
      }
      spec {
        container {
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-frontend@sha256:2b078ca2beee6d08deadc4765a20278516a1254563719178ac73b74884a35385"
          name  = "app-frontend"

          port {
            container_port = 80
          }

          env {
            name  = "GENERATOR_HOST"
            value = "http://generator:80"
          }

          env {
            name  = "COMPARATOR_HOST"
            value = "http://comparator:80"
          }

          env {
            name  = "LEADERBOARD_HOST"
            value = "http://leaderboard:80"
          }

          env {
            name  = "PORT"
            value = "80"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}

#################################################################
# Defines the Pods for the Comparator
resource "kubernetes_deployment" "comparator" {
  metadata {
    name = "comparator"

    labels = {
      app  = "comparator"
      tier = "backend"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
    delete = "2m"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "comparator"
        tier = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "comparator"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-comparator@sha256:24afdac0c691e038e034260099eff95dac6061c3dbdd842d8b9b49e0c2a60b50"
          name  = "app-comparator"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-ss-0.redis:6379"
          }

          env {
            name  = "REDIS_FOLLOWER"
            value = "redis://redis:6379"
          }

          env {
            name  = "LEADERBOARD_URL"
            value = "http://leaderboard:80"
          }

          env {
            name  = "PORT"
            value = "8000"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}

#################################################################
# Defines the Pods for the Generator
resource "kubernetes_deployment" "generator" {
  metadata {
    name = "generator"

    labels = {
      app  = "generator"
      tier = "backend"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
    delete = "2m"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "generator"
        tier = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "generator"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-generator@sha256:afa063f2ed42337337e5fcc440d0cd9a330bfb61de0aaf81ae672add207d079b"
          name  = "app-generator"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-ss-0.redis:6379"
          }

          env {
            name  = "REDIS_FOLLOWER"
            value = "redis://redis:6379"
          }

          env {
            name  = "PORT"
            value = "8000"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}

#################################################################
# Defines the Pods for the Leaderboard
resource "kubernetes_deployment" "leaderboard" {
  metadata {
    name = "leaderboard"

    labels = {
      app  = "leaderboard"
      tier = "backend"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
    delete = "2m"
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "leaderboard"
        tier = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "leaderboard"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-leaderboard@sha256:9508f4e720b9b6bc3b8df0ddf0b53586546febb025fa5021a47d6f764a3bead6"
          name  = "app-leaderboard"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-ss-0.redis:6379"
          }

          env {
            name  = "REDIS_FOLLOWER"
            value = "redis://redis:6379"
          }

          env {
            name  = "PORT"
            value = "8000"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
      }
    }
  }
}