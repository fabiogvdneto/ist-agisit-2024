# ################################################################################################
# Create the Redis Service
resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"

    labels = {
      app  = "redis"
    }
  }

  spec {
    selector = {
      app  = "redis"
    }

    cluster_ip = "None"

    port {
      port = 6379
      target_port = 6379
    }
  }
}

# ################################################################################################
# Create the Redis Config Map
resource "kubernetes_config_map" "redis" {
  metadata {
    name = "redis-config"
  }

  data = {
    "leader.conf" = "${file("${path.module}/redis/leader.conf")}"
    "follower.conf"  = "${file("${path.module}/redis/follower.conf")}"
  }
}

# ################################################################################################
# Create the Redis Stateful Set
resource "kubernetes_stateful_set" "redis-ss" {
  metadata {
    name = "redis-ss"
  }

  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }

  spec {
    replicas = 2 # 0 is the leader, 1..n are followers

    selector {
      match_labels = {
        app = "redis"
      }
    }

    service_name = kubernetes_service.redis.metadata.0.name

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        init_container {
          name = "init-redis"
          image = "redis:7.4.1"
          image_pull_policy = "IfNotPresent"
          command = ["/bin/bash", "-c", ]
          args = [<<-EOF
            set -ex
            # Generate redis server-id from pod ordinal index.
            [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
            ordinal=$${BASH_REMATCH[1]}
            # Copy appropriate redis config files from config-map to respective directories.
            if [[ $ordinal -eq 0 ]]; then
                cp /mnt/leader.conf /etc/redis-config.conf
            else
                cp /mnt/follower.conf /etc/redis-config.conf
            fi
            EOF
          ]

          volume_mount {
            name = "redis-claim"
            mount_path = "/etc"
          }
          volume_mount {
            name = "config-map"
            mount_path = "/mnt/"
          }
        }

        container {
          name = "redis"
          image = "redis:7.4.1"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 6379
          }
          command = ["redis-server", "/etc/redis-config.conf"]

          volume_mount {
            name = "redis-data"
            mount_path = "/data"
          }
          volume_mount {
            name = "redis-claim"
            mount_path = "/etc"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
        }
        volume {
          name = "config-map"
          config_map {
            name = kubernetes_config_map.redis.metadata.0.name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "redis-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "redis-claim"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
  }
}
