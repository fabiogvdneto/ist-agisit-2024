variable "project" {
  type = string
}

variable "gcr-repo" {
  type = string
}

variable "gcr-region" {
  type = string
}
# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes

#################################################################
# Definition of the Pods
#################################################################

# The Backend Pods for Data Store deployment with REDIS
# Defines 1 Leader (not replicated)
# Defines 2 Followers (replicated) 
# see: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/replication_controller

# Defines 1 REDIS Leader (not replicated)
resource "kubernetes_deployment" "redis-leader" {
  metadata {
    name = "redis-leader"
    labels = {
      app  = "redis"
      role = "leader"
      tier = "backend"
    }
  }

  spec {
    progress_deadline_seconds = 1200 # In case of taking longer than 9 minutes
    replicas = 1
    selector {
      match_labels = {
        app  = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redis"
          role = "leader"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "docker.io/redis:6.0.5"
          name  = "leader"

          port {
            container_port = 6379
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
# Defines 2 REDIS Follower (replicated)
resource "kubernetes_deployment" "redis-follower" {
  metadata {
    name = "redis-follower"

    labels = {
      app  = "redis"
      role = "follower"
      tier = "backend"
    }
  }

  spec {
    progress_deadline_seconds = 1200 # In case of taking longer than 9 minutes
    replicas = 2
    selector {
      match_labels = {
        app  = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redis"
          role = "follower"
          tier = "backend"
        }
      }
      spec {
        container {
          image = "gcr.io/google_samples/gb-redis-follower:v2"
          name  = "follower"

          port {
            container_port = 6379
          }

          env {
            name  = "GET_HOSTS_FROM"
            value = "dns"
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
# Defines the Frontend Pods for the Project
# Only 3 replicas that will be Load balanced
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app  = "application-frontend"
      tier = "frontend"
    }
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
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-frontend"
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
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-comparator"
          name  = "app-comparator"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-leader:6379"
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
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-generator"
          name  = "app-generator"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-leader:6379"
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
          image = "${var.gcr-region}-docker.pkg.dev/${var.project}/${var.gcr-repo}/app-leaderboard"
          name  = "app-leaderboard"

          port {
            container_port = 8000
          }

          env {
            name  = "REDIS_URL"
            value = "redis://redis-leader:6379"
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