<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://gitlab.rnl.tecnico.ulisboa.pt/agisit/agisit24-g31">
    <img src="docs/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Number Guesser</h3>

  <p align="center">
    An awesome Kubernetes game for guessing a number
    <br />
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#deploying-to-gke">Deploying to GKE</a></li>
        <ul>
          <li><a href="#gcr">Google Artifact Registry</a></li>
          <li><a href="#terraform">Terraform</a></li>
        </ul>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

![Product Name Screen Shot][product-screenshot]

Number Guesser is a number guessing game, where the system generates a random number that remains hidden from the player.

For simplicity, the game only generates numbers in the interval 1 to 100. Then, the player must place guesses, and the system will provide feedback in the form of "lower", "higher", or "correct". The less guesses a player needs to find the number, the better. There is a leaderboard on how many guesses it took the players to guess some numbers. A strategy for better results could be to employ binary search.

A demonstration of the system working is available on [YouTube](https://youtu.be/123456)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

The web application was built with the following technologies.

* [![Bun][Bun-img]][Bun-url]
* [![Deno][Deno-img]][Deno-url] with [![Hono][Hono-img]][Hono-url]
* [![Python][Python-img]][Python-url] with [![Django][Django-img]][Django-url]
* [![Redis][Redis-img]][Redis-url]

And the infrastructure was built on
* [![Docker][Docker-img]][Docker-url]
* [![Google Cloud][GCloud-img]][GCloud-url]
* [![Grafana][Grafana-img]][Grafana-url]
* [![Helm][Helm-img]][Helm-url]
* [![Kubernetes][Kubernetes-img]][Kubernetes-url]
* [![Prometheus][Prometheus-img]][Prometheus-url]
* [![Terraform][Terraform-img]][Terraform-url]

![Architecture][architecture-img]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

Each microservice has a Dockerfile that can be used to run the microservice. App-level docker compose is also available to run the application locally.


### Deploying to GKE
1. Get a [Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) from Google Cloud. It needs certain permissions for building the cluster. To be safe from further troubleshooting, you can make the service account and **Owner**.
2. Put the _credentials_ in [infra/k8scloud/credentials.json](infra/k8scloud/credentials.json)

#### GCR
The project uses [Google Artifact Registry](https://gcr.io), so you have to authenticate on Docker and push the Docker images to it. You can read the documentation [here](https://cloud.google.com/artifact-registry/docs/docker/authentication#json-key).

1. Authenticate docker. Considering _location_ being **europe-central2**: `cat credentials.json | docker login -u _json_key --password-stdin \
https://europe-central2-docker.pkg.dev`
2. Build the images with `docker compose build`
3. Use the [app/push-all.sh](app/push-all.sh) to help you tag and push the Docker images

    You can use [app/push.sh](app/push.sh) to push a single image. It takes as argument the image name.


#### Terraform
Go to [infra/k8scloud](infra/k8scloud/).
1. Change [terraform variables](infra/k8scloud/terraform.tfvars) if needed
2. Run `terraform init`. 
    
    You can use the Vagrantfile (`vagrant up` then `vragrant ssh`) to start a VM with the necessary dependencies or `nix develop` if on nixos
3. Run `terraform apply` and wait for the cluster to create. Generally takes about 8 minutes
4. Setup kubectl to use the created cluster by running [infra/k8scloud/scripts/connect.kubectl.sh](infra/k8scloud/scripts/connect.kubectl.sh)
5. Get the _frontend_ service IP: `kubectl get services`. By placing it on your browser you can now use the application.

If you wish to connect to Grafana to see the dashboards, you have to portforward.
This can be achieved by running the [infra/k8scloud/scripts/grafana.sh](infra/k8scloud/scripts/grafana.sh) script. The same applies to Prometheus.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

- Fábio Neto - ist1104126 - fabiogvdneto@tecnico.ulisboa.pt
- Lucas Pinto - ist1110813 - lucas.f.pinto@tecnico.ulisboa.pt
- João Ferreira - ist1110954 - joao.filipe.ferreira@tecnico.ulisboa.pt

Project Link: [Gitlab@RNL/agisit/agisit24-g31](https://gitlab.rnl.tecnico.ulisboa.pt/agisit/agisit24-g31)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[product-screenshot]: docs/app-screenshot.png
[architecture-img]: docs/architecture.png
[Bun-img]: https://img.shields.io/badge/Bun-000?logo=bun&logoColor=fff
[Bun-url]: https://bun.sh
[Deno-img]: https://img.shields.io/badge/Deno-000?logo=deno&logoColor=fff
[Deno-url]: https://deno.com
[Django-img]: https://img.shields.io/badge/Django-%23092E20.svg?logo=django&logoColor=fff
[Django-url]: https://www.djangoproject.com/
[Kubernetes-img]: https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff
[Kubernetes-url]: https://kubernetes.io/
[GCloud-img]: https://img.shields.io/badge/Google%20Cloud-%234285F4.svg?logo=google-cloud&logoColor=white
[GCloud-url]: https://cloud.google.com
[Redis-img]: https://img.shields.io/badge/Redis-%23DD0031.svg?logo=redis&logoColor=white
[Redis-url]: https://redis.io/
[Helm-img]: https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=fff
[Helm-url]: https://helm.sh/
[Hono-img]: https://img.shields.io/badge/Hono-E36002?logo=hono&logoColor=fff
[Hono-url]: https://hono.dev/
[Python-img]: https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff
[Python-url]: https://www.python.org/
[Prometheus-img]: https://img.shields.io/badge/Prometheus-E6522C?logo=Prometheus&logoColor=white
[Prometheus-url]: https://prometheus.io/
[Grafana-img]: https://img.shields.io/badge/grafana-%23F46800.svg?logo=Grafana&logoColor=white
[Grafana-url]: https://grafana.com/
[Docker-img]: https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff
[Docker-url]: https://www.docker.com/
[Terraform-img]: https://img.shields.io/badge/Terraform-623CE4?logo=terraform&logoColor=white
[Terraform-url]: https://www.terraform.io/