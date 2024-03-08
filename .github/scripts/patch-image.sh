#! /usr/bin/env bash

git config user.name "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"
git checkout -b "deploy-${GIT_SHA}"
git add --all
git commit -am "chore: deploy ${GIT_SHA}"
git push -u origin "deploy-${GIT_SHA}"
gh pr create --title="chore: deploy ${GIT_SHA}" --body=""
sleep 5
gh pr merge --auto --squash
