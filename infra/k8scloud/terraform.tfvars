
#####################################################################
# the terraform.tfvars file is ignored in git Repo
#####################################################################
# How to define variables in terraform:
# https://www.terraform.io/docs/configuration/variables.html

# Define the Project ID
project = "agisit-ist"

project_name = "number-guesser"

gcr-repo="number-guesser"
gcr-region="europe-central2"

# Define the default number of Nodes for the cluster
workers_count = "5"

# Define the Region/Zone
# Regions list is found at:
# https://cloud.google.com/compute/docs/regions-zones/regions-zones?hl=en_US
region = "europe-central2-a"

