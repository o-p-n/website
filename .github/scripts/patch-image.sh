#! /usr/bin/env bash

set -euo pipefail

loggit() {
  echo "$@" >> /dev/stderr
}

check_dirty() {
  git update-index --refresh
  git diff --quiet
}

config_git() {
  git config user.name "${GIT_USER_NAME}"
  git config user.email "${GIT_USER_EMAIL}"
  git checkout -b "deploy-${GIT_SHA}"
}

create_pr() {
  git add --all
  git commit -am "chore: deploy ${GIT_SHA}"
  git push -u origin "deploy-${GIT_SHA}"
  gh pr create --title="chore: deploy ${GIT_SHA}" --body=""
}

approve_pr() {
  gh pr merge --auto --squash
}

if [[ check_dirty ]] ; then
  loggit "changes detected; update repo"
  echo loggit "📝 configure git"
  echo config_git
  echo loggit "💾 creating pull-request"
  echo create_pr
  echo sleep 10
  echo loggit "✔ auto-approve pull-request"
  echo approve_pr
else
  loggit "working copy clean; no changes detected"
fi