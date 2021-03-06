# GitOps Committer

Creates a commit in a github repo for CI/CD using a docker container that knows what to commit. The contract the access to the repo and the gitops metadata is created. Extra metadata can be provided by the user via volumes+env vars. That is, the `gitops` object is generated with the trigger information and addition metadata provided.

* It generates a commit with the file `.gitops-committer.yaml` with the object `gitops`
  * You can provide extra metadata, here appended as `deployer.yaml`
* It will create a commit and push to the repo you select
  * Provided you also mount the `.ssh` dir with the pem with access to the git repo.

```yaml
# Generated by Gitops-Committer
gitops:
  trigger:
    pipeline: https://gitlab.com/supercash/services/reverse-proxy-resource/-/pipelines/256841576
    repo: git@github.com:marcellodesales/iot-observability.git
    branch: main
    version: 101020304

# User-provided metadata via volumes
deployer:
  compose:
    service: orchestrator-service
```

# Setup

* Just create a `gitops.yaml` with a docker-compose structure and provide the parameters
  * All parameters are env vars
  * If providing extra metadata, you need to provide it via volume mount and indicate the path for it to be merged.
* `supercash-deployer.yaml` is the metadata stored in the trigger repo.
  * It can be static or generated, but it needs to exist and provided as volume to `/metadata`

```yaml
version: "3.8"

services:

  gitops-committer:
    image: supercash/resources/gitops-committer
    volumes:
      - ${HOME}/.ssh:/root/.ssh
      - ./gitops:/metadata
    environment:
      - GITOPS_TRIGGER_REPO=git@github.com:marcellodesales/iot-observability.git
      - GITOPS_TRIGGER_PIPELINE_URL=https://gitlab.com/supercash/services/reverse-proxy-resource/-/pipelines/256841576
      - GITOPS_TRIGGER_BRANCH=main
      - GITOPS_TRIGGER_SHA=101020304
      - GITOPS_EXECUTOR_SCRIPT=/gitops/executor.sh
      - GITOPS_EXECUTOR_COMMIT_MSG="Supercash GitOps"
      - GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME="Marcello de Sales"
      - GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL=marcello.desales@gmail.com
      - GITOPS_METADATA_VALUES_FILE=/metadata/supercash-deployer.yaml
```

# Run

* Just run with the parameters and a GitOps commit will run the provided executor.

```console
$ docker-compose -f gitops.yaml up
Creating iot-observability_gitops-committer_1 ... done
Attaching to iot-observability_gitops-committer_1
gitops-committer_1  |
gitops-committer_1  |   __   _   _____       __    ___    __
gitops-committer_1  |  / _] | | |_   _|     /__\  | _,\ /' _/
gitops-committer_1  | | [/\ | |   | |   __ | \/ | | v_/ `._`.    @marcellodesales
gitops-committer_1  |  \__/ |_|   |_|   \/  \__/  |_|   |___/
gitops-committer_1  |   ___   __    __ __   __ __   _   _____   _____   ___   ___
gitops-committer_1  |  / _/  /__\  |  V  | |  V  | | | |_   _| |_   _| | __| | _ \
gitops-committer_1  | | \__ | \/ | | \_/ | | \_/ | | |   | |     | |   | _|  | v /
gitops-committer_1  |  \__/  \__/  |_| |_| |_| |_| |_|   |_|     |_|   |___| |_|_\
gitops-committer_1  |
gitops-committer_1  |
gitops-committer_1  | ###############################
gitops-committer_1  | ######## Starting CI/CD in Repo...
gitops-committer_1  | ###############################
gitops-committer_1  |
gitops-committer_1  | * Local commit for CI/CD
gitops-committer_1  | * Triggered by https://gitlab.com/supercash/services/reverse-proxy-resource/-/pipelines/256841576
gitops-committer_1  |
gitops-committer_1  | #################
gitops-committer_1  | #### Current env
gitops-committer_1  | #################
gitops-committer_1  |
gitops-committer_1  | GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME="Marcello de Sales"
gitops-committer_1  | GITOPS_EXECUTOR_SCRIPT=/gitops/executor.sh
gitops-committer_1  | HOSTNAME=704bdc28fa75
gitops-committer_1  | GITOPS_EXECUTOR_COMMIT_MSG="Supercash GitOps"
gitops-committer_1  | SHLVL=1
gitops-committer_1  | HOME=/root
gitops-committer_1  | GITOPS_TRIGGER_SHA=101020304
gitops-committer_1  | PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
gitops-committer_1  | GITOPS_METADATA_VALUES_FILE=/metadata/supercash-deployer.yaml
gitops-committer_1  | GITOPS_TRIGGER_REPO=git@github.com:marcellodesales/iot-observability.git
gitops-committer_1  | GITOPS_TRIGGER_PIPELINE_URL=https://gitlab.com/supercash/services/reverse-proxy-resource/-/pipelines/256841576
gitops-committer_1  | GITOPS_TRIGGER_BRANCH=main
gitops-committer_1  | GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL=marcello.desales@gmail.com
gitops-committer_1  | PWD=/gitops
gitops-committer_1  |
gitops-committer_1  | ###############################
gitops-committer_1  | ######## GitOps Update
gitops-committer_1  | ###############################
gitops-committer_1  |
gitops-committer_1  | * Git clone the repo git@github.com:marcellodesales/iot-observability.git@main
gitops-committer_1  |
gitops-committer_1  | Cloning into '/gitops/workspace'...
gitops-committer_1  | commit a94da457e82cd4d73dccd87fa33976c379902837
gitops-committer_1  | Author: Jairo Barros <jbarros@platformscience.com>
gitops-committer_1  | Date:   Wed Feb 17 22:52:35 2021 -0800
gitops-committer_1  |
gitops-committer_1  |     :tada: Adding initial files
gitops-committer_1  |
gitops-committer_1  | * Current state of the repo
gitops-committer_1  |
gitops-committer_1  | total 32
gitops-committer_1  | drwxr-xr-x    6 root     root          4096 Feb 23 16:55 .
gitops-committer_1  | drwxr-xr-x    1 root     root          4096 Feb 23 16:55 ..
gitops-committer_1  | drwxr-xr-x    8 root     root          4096 Feb 23 16:55 .git
gitops-committer_1  | -rw-r--r--    1 root     root             4 Feb 23 16:55 .gitignore
gitops-committer_1  | drwxr-xr-x    2 root     root          4096 Feb 23 16:55 config
gitops-committer_1  | drwxr-xr-x    2 root     root          4096 Feb 23 16:55 dashboard
gitops-committer_1  | -rw-r--r--    1 root     root           784 Feb 23 16:55 docker-compose.yaml
gitops-committer_1  | drwxr-xr-x    2 root     root          4096 Feb 23 16:55 host
gitops-committer_1  |
gitops-committer_1  | * remote origin
gitops-committer_1  |   Fetch URL: git@github.com:marcellodesales/iot-observability.git
gitops-committer_1  |   Push  URL: git@github.com:marcellodesales/iot-observability.git
gitops-committer_1  |   HEAD branch: main
gitops-committer_1  |   Remote branch:
gitops-committer_1  |     main tracked
gitops-committer_1  |   Local branch configured for 'git pull':
gitops-committer_1  |     main merges with remote main
gitops-committer_1  |   Local ref configured for 'git push':
gitops-committer_1  |     main pushes to main (up to date)
gitops-committer_1  |
gitops-committer_1  | * Writing the gitops file .gitops-committer.yaml
gitops-committer_1  | * Appending the metadata values file provided '/metadata/supercash-deployer.yaml'
gitops-committer_1  |
gitops-committer_1  | -----------
gitops-committer_1  | # User-provided metadata via volumes
gitops-committer_1  | deployer:
gitops-committer_1  |   compose:
gitops-committer_1  |     service: orchestrator-service
gitops-committer_1  | -----------
gitops-committer_1  |
gitops-committer_1  | Verifying the status of the repo...
gitops-committer_1  |
gitops-committer_1  |
gitops-committer_1  | ###############################
gitops-committer_1  | ######## GitOps Update
gitops-committer_1  | ###############################
gitops-committer_1  |
gitops-committer_1  | * Setting the committer...
gitops-committer_1  | - Name: "Marcello de Sales"
gitops-committer_1  | - Email: marcello.desales@gmail.com
gitops-committer_1  |
gitops-committer_1  | * Writing the GITOPS commit '"Supercash GitOps"'
gitops-committer_1  |
gitops-committer_1  | [main 7a8ffcc] :building_construction: GitOps git@github.com:marcellodesales/iot-observability.git@101020304
gitops-committer_1  |  1 file changed, 4 insertions(+)
gitops-committer_1  |  create mode 100644 .gitops-committer.yaml
gitops-committer_1  | commit 7a8ffcc72de058cf232b3498eaf8601cebf0d905
gitops-committer_1  | Author: Marcello de Sales <marcello.desales@gmail.com>
gitops-committer_1  | Date:   Tue Feb 23 16:55:54 2021 +0000
gitops-committer_1  |
gitops-committer_1  |     :building_construction: GitOps git@github.com:marcellodesales/iot-observability.git@101020304
gitops-committer_1  |
gitops-committer_1  |     "Supercash GitOps"
gitops-committer_1  |
gitops-committer_1  | diff --git a/.gitops-committer.yaml b/.gitops-committer.yaml
gitops-committer_1  | new file mode 100644
gitops-committer_1  | index 0000000..b10afac
gitops-committer_1  | --- /dev/null
gitops-committer_1  | +++ b/.gitops-committer.yaml
gitops-committer_1  | @@ -0,0 +1,4 @@
gitops-committer_1  | +# User-provided metadata via volumes
gitops-committer_1  | +deployer:
gitops-committer_1  | +  compose:
gitops-committer_1  | +    service: orchestrator-service
gitops-committer_1  |
gitops-committer_1  | * Pushing the GITOPS commit '"Supercash GitOps" with branch main'
gitops-committer_1  |
gitops-committer_1  | To github.com:marcellodesales/iot-observability.git
gitops-committer_1  |    a94da45..7a8ffcc  main -> main
gitops-committer_1  |
gitops-committer_1  | DONE!
gitops-committer_1  |
iot-observability_gitops-committer_1 exited with code 0
```
