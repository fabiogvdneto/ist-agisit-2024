# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud Native on a Cloud-Hosted Kubernetes

#################################################################
# Definition of the Services
#################################################################

# The Service for the REDIS Leader Pods
resource "kubernetes_service" "redis-leader" {
  metadata {
    name = "redis-leader"

    labels = {
      app  = "redis"
      role = "leader"
      tier = "backend"
    }
  }

  spec {
    selector = {
      app  = "redis"
      role = "leader"
      tier = "backend"
    }

    port {
      port = 6379
      target_port = 6379
    }
  }
}
# The Service for the REDIS Follower Pods
resource "kubernetes_service" "redis-follower" {
  metadata {
    name = "redis-follower"

    labels = {
      app  = "redis"
      role = "follower"
      tier = "backend"
    }
  }

  spec {
    selector = {
      app  = "redis"
      role = "follower"
      tier = "backend"
    }

    port {
      port = 6379
    }
  }

  depends_on = [ 
    kubernetes_service.redis-leader
  ]
}

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
    kubernetes_service.redis-leader,
    kubernetes_service.redis-follower
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
    kubernetes_service.redis-leader,
    kubernetes_service.redis-follower
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
    kubernetes_service.redis-leader,
    kubernetes_service.redis-follower
  ]
}