#! /usr/bin/env bash

set -euo pipefail

loggit() {
  echo "$@" 1>&2
}

check_clean() {
  git update-index --refresh --ignore-submodules 2>&1 >> /dev/null
  git diff --quiet --ignore-submodules
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

if check_clean ; then
  loggit "✨ — working copy clean; no changes detected"
else
  loggit "changes detected; update repo"
  loggit "📝 — configure git"
  config_git
  loggit "💾 — creating pull-request"
  create_pr
  
  loggit ⏳ — give GH some time ...
  sleep 10

  loggit "✅ — auto-approve pull-request"
  approve_pr
fi