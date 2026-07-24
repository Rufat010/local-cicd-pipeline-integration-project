# Local CI/CD Pipeline Integration Project

A local, automated deployment pipeline tying together Git/GitHub, Jenkins, Terraform, and Docker.

## Architecture

- **`app/`** — a tiny Flask app (`app.py`, `requirements.txt`, `Dockerfile`).
- **`Jenkinsfile`** — pipeline that checks out the repo, builds the app's Docker image, and runs `terraform apply`.
- **`terraform/`** — `kreuzwerker/docker` provider config that deploys the image Jenkins just built as a container.
- **`jenkins/Dockerfile`** + **`docker-compose.yml`** — builds and runs Jenkins itself in Docker, with the Docker CLI and Terraform CLI installed inside it.

## How it fits together locally

Docker is the only "infrastructure" in play — it hosts both Jenkins and the deployed app.

- Jenkins runs as a container (`jenkins/Dockerfile`, built via `docker-compose.yml`). That image has the `docker` CLI and `terraform` CLI installed, but no Docker daemon of its own.
- The host's Docker socket (`/var/run/docker.sock`) is bind-mounted into the Jenkins container. This is the "Docker-outside-of-Docker" pattern: when the Jenkinsfile runs `docker build` or Terraform's `kreuzwerker/docker` provider talks to the daemon, both are actually talking to the **host's** Docker daemon through that socket. That's why the app container Terraform creates shows up in `docker ps` on your Mac, not nested inside the Jenkins container.
- The Jenkins container runs as `root` (see `docker-compose.yml`) purely so it has permission to read/write that socket — a fine shortcut for a local class project.
- Terraform's state file (`terraform/terraform.tfstate`) lives in the Jenkins job workspace, which persists across builds because `jenkins_home` is a named Docker volume. That's the "local state" the pipeline reads on every run — it's how Terraform knows to replace the existing `local-cicd-app` container instead of erroring out on a name conflict.
- CI trigger is **SCM polling** (`pollSCM('H/2 * * * *')` in the `Jenkinsfile`), checking the repo every 2 minutes — no webhook/networking setup needed for a local Jenkins instance.

## One-time setup

### 1. Start Jenkins

```bash
docker compose up -d --build
```

### 2. Unlock Jenkins

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Open http://localhost:8080, paste that password, install the "suggested plugins," and create an admin user.

### 3. Create the pipeline job

- New Item → name it (e.g. `local-cicd-pipeline`) → **Pipeline**.
- Under **Build Triggers**, check **Poll SCM** (the schedule is already set in the `Jenkinsfile`, this just needs to be enabled).
- Under **Pipeline**, set **Definition** to "Pipeline script from SCM," **SCM** to Git, and point it at this repo's URL (GitHub URL once pushed, or a local `file:///...` path for testing before you push).
- Save.

### 4. Trigger a build

Push a commit to the repo (or click **Build Now** for the first run). Within 2 minutes, Jenkins' next poll will pick up new commits automatically and:

1. Check out the repo.
2. `docker build` the app image, tagged `local-cicd-app:<BUILD_NUMBER>`.
3. `terraform init` in `terraform/`.
4. `terraform apply -auto-approve` to (re)deploy that image as the `local-cicd-app` container.

### 5. Verify

```bash
curl http://localhost:5001
```

You should get back JSON with a `hostname` matching the running container's ID, confirming the newly built image is what's live.

## Report checklist

For the assignment report, capture:

- Jenkins **Build History** for `local-cicd-pipeline` showing a build triggered by SCM polling after a commit (not just a manual "Build Now").
- `docker ps` (or the app responding at `http://localhost:5001`) showing the deployed container running.
