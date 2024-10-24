# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes

#################################################################
# The Service for the Frontend Load Balancer Ingress
resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app  = "application-frontend"
      tier = "frontend"
    }
  }

  spec {
    selector = {
      app  = "application-frontend"
      tier = "frontend"
    }

    type = "LoadBalancer"

    port {
      port = 80
      target_port = 80
    }
  }

  depends_on = [ 
    kubernetes_service.comparator,
    kubernetes_service.generator,
    kubernetes_service.leaderboard
  ]
}

#################################################################
# The Service for the Comparator nodes
resource "kubernetes_service" "comparator" {
  metadata {
    name = "comparator"

    labels = {
      app  = "comparator"
      tier = "backend"
    }
  }

  spec {
    selector = {
      app  = "comparator"
      tier = "backend"
    }

    port {
      port = 80
      target_port = 8000
    }
  }

  depends_on = [ 
    kubernetes_service.redis
  ]
}

#################################################################
# The Service for the Generator nodes
resource "kubernetes_service" "generator" {
  metadata {
    name = "generator"

    labels = {
      app  = "generator"
      tier = "backend"
    }
  }

  spec {
    selector = {
      app  = "generator"
      tier = "backend"
    }

    port {
      port = 80
      target_port = 8000
    }
  }

  depends_on = [ 
    kubernetes_service.redis
  ]
}

#################################################################
# The Service for the Leaderboard nodes
resource "kubernetes_service" "leaderboard" {
  metadata {
    name = "leaderboard"

    labels = {
      app  = "leaderboard"
      tier = "backend"
    }
  }

  spec {
    selector = {
      app  = "leaderboard"
      tier = "backend"
    }

    port {
      port = 80
      target_port = 8000
    }
  }

  depends_on = [ 
    kubernetes_service.redis
  ]
}