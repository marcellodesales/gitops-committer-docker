#!/bin/sh

# Options used to clone the repo
GITOPS_TRIGGER_PIPELINE_URL=${GITOPS_TRIGGER_PIPELINE_URL?"You must provide the trigger pipeline URL"}
GITOPS_TRIGGER_REPO=${GITOPS_TRIGGER_REPO?"You must provide the gitops repo to clone"}
GITOPS_TRIGGER_BRANCH=${GITOPS_TRIGGER_BRANCH?"You must provide repo's branch to clone"}
GITOPS_TRIGGER_SHA=${GITOPS_TRIGGER_SHA?"You must provide the SHA of the version triggering this commit"}
# Options used to execute and verify the changes to commit
GITOPS_EXECUTOR_COMMIT_MSG=${GITOPS_EXECUTOR_COMMIT_MSG?"The commit message to use as the body of the change"}
GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME=${GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME?"You must provide the commit author's name"}
GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL=${GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL?"You must provide the commit author's email"}
GITOPS_METADATA_VALUES_DIR=${GITOPS_METADATA_VALUES_DIR:""}
GITOPS_EXECUTOR_REPO_PUSH_USERNAME=${GITOPS_EXECUTOR_REPO_PUSH_USERNAME?"You must provide the passwrod to write to the repo"}
GITOPS_EXECUTOR_REPO_PUSH_TOKEN=${GITOPS_EXECUTOR_REPO_PUSH_TOKEN?"You must provide the value of the deployer's token"}
GITOPS_EXECUTOR_REPO_PUSH_INCLUDE_FILES=${GITOPS_EXECUTOR_REPO_PUSH_INCLUDE_FILES?"You must provide the list of files to add in the commit"}

echo ""
cat banner.txt
echo ""
echo ""
echo "###############################"
echo "######## Starting CI/CD in Repo..."
echo "###############################"
echo ""
echo "* Local commit for CI/CD"
echo "* Triggered by ${GITOPS_TRIGGER_PIPELINE_URL}"
echo ""
echo "#################"
echo "#### Current env "
echo "#################"
echo ""

env

echo ""
echo "###############################"
echo "######## GitOps Update         "
echo "###############################"
echo ""
echo "* Validating the workspace dir at /workspace"
echo ""

# Just clone the latest commit
# https://stackoverflow.com/questions/1209999/using-git-to-get-just-the-latest-revision/1210012#1210012
# if ! git clone --depth 1 --branch ${GITOPS_TRIGGER_BRANCH} ${GITOPS_TRIGGER_REPO} /gitops/workspace; then
#   echo "ERROR: Can't clone the provided repo."
#   echo "ERROR: Make sure you have the right repo, branch, credentials at /root/.ssh"
#   exit 1
# fi

# The directory containing the repo that will receive the gitops commit
cd /gitops/workspace

echo "* Current state of the trigger repo"
echo ""
ls -la
echo ""

git remote show origin

echo ""
echo "############### HEAD COMMIT ###############"
echo ""

# Show the contents first
git --no-pager show --quiet HEAD

echo ""
echo "###############"
echo ""
echo "* Writing the gitops file .gitops-committer.yaml"

cat > .gitops-committer.yaml << EOF
# Generated by Gitops-Committer
gitops:
  trigger:
    pipeline: ${GITOPS_TRIGGER_PIPELINE_URL}
    repo: ${GITOPS_TRIGGER_REPO}
    branch: ${GITOPS_TRIGGER_BRANCH}
    version: ${GITOPS_TRIGGER_SHA}
EOF

if [ ! -d "${GITOPS_METADATA_VALUES_DIR}" ]; then
  echo "* WARN: Not using any metadata dir. GITOPS_METADATA_VALUES_DIR needs to be set!"

else
  GITOPS_METADATA_VALUES_DIR=/workspace/${GITOPS_METADATA_VALUES_DIR}
  echo "* Appending the metadata values file provided in resolved GITOPS_METADATA_VALUES_DIR='${GITOPS_METADATA_VALUES_DIR}'"
  echo "* Files are as follows:"
  ls -la ${GITOPS_METADATA_VALUES_DIR}

  # Appending docs and appending all files
  echo "" >> .gitops-committer.yaml
  echo "# User-provided metadata via volumes" >> .gitops-committer.yaml
  cat ${GITOPS_METADATA_VALUES_DIR}/* >> .gitops-committer.yaml
fi

echo ""
echo "-----------"
cat .gitops-committer.yaml
echo "-----------"

echo ""
echo "Verifying the status of the repo..."
echo ""

git status

# https://unix.stackexchange.com/questions/155046/determine-if-git-working-directory-is-clean-from-a-script/155077#155077
STATUS="$(git status --porcelain)"
if [ -z "${STATUS}" ]; then
  echo 'INFO: No changes were made to the metadata...'
  exit 0
fi

echo ""
# Convert the comma-delimited list with new lines for the for-each
echo "# Adding files '${GITOPS_EXECUTOR_REPO_PUSH_INCLUDE_FILES}'"
export FILES=$(echo ${GITOPS_EXECUTOR_REPO_PUSH_INCLUDE_FILES} | tr ',' '\n')
for FILE in ${FILES}; do
  echo "+ Adding gitops file '${FILE}'"
  git add ${FILE}
done

echo ""
echo "---- Git Ops Committer Diff -------"
git --no-pager diff .gitops-committer.yaml
echo "-----------"

echo ""
echo "###############################"
echo "######## GitOps Update         "
echo "###############################"
echo ""
echo "* Setting the committer..."
echo "- Name: ${GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME}"
echo "- Email: ${GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL}"

# https://docs.github.com/en/github/using-git/setting-your-username-in-git
# Just change for the current repo locally
git config user.name "${GITOPS_EXECUTOR_COMMIT_AUTHOR_NAME}"
git config user.email "${GITOPS_EXECUTOR_COMMIT_AUTHOR_EMAIL}"

echo ""
echo "* Writing the GITOPS commit '${GITOPS_EXECUTOR_COMMIT_MSG}'"
echo ""

git add -A
git commit -m ":building_construction: GitOps ${GITOPS_TRIGGER_REPO}@${GITOPS_TRIGGER_SHA}" -m "${GITOPS_EXECUTOR_COMMIT_MSG}"

# https://stackoverflow.com/questions/1828252/how-to-display-metadata-about-single-commit-in-git/1828259#1828259
git --no-pager show HEAD

echo ""
echo "* Pushing the GITOPS commit '${GITOPS_EXECUTOR_COMMIT_MSG} with branch ${GITOPS_TRIGGER_BRANCH}'"
echo ""

# Tokens are created per project https://gitlab.com/supercash/services/parking-lot-service/-/settings/ci_cd
# Getting the repo URL and using token instead https://stackoverflow.com/questions/46472250/cannot-push-from-gitlab-ci-yml/55344804#55344804
export REPO_URL=$(git remote show origin  | grep Fetch | awk '{ print $3 }')
export PUSH_URL="git push https://${GITOPS_EXECUTOR_REPO_PUSH_USERNAME}:${GITOPS_EXECUTOR_REPO_PUSH_TOKEN}@${REPO_URL#*@} head:${GITOPS_TRIGGER_BRANCH}"
echo "Ready to push: git push ${PUSH_URL}"
if ! git push ${PUSH_URL}; then
  echo "ERROR: Can't push changes... Make sure you have the ssh keys mounted!"
  exit 4
fi

echo ""
echo "DONE! "
echo ""
