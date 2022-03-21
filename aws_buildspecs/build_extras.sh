#!/bin/bash

export CODEBUILD_GIT_BRANCH="$(git symbolic-ref HEAD --short 2>/dev/null)"
if [ "$CODEBUILD_GIT_BRANCH" = "" ] ; then
  export CODEBUILD_GIT_BRANCH="$(git rev-parse HEAD | xargs git name-rev | cut -d' ' -f2 | sed 's/remotes\/origin\///g')";
fi

export CODEBUILD_PULL_REQUEST=false
export CODEBUILD_GIT_MESSAGE="$(git log -1 --pretty=%B)"

REPO_URL=$(git remote get-url origin)
REPO_NAME=$(basename $REPO_URL .git)
REPO_OWNER=$(echo $REPO_URL | rev | cut -d'/' -f2 | rev)

export BUILD_APP1=true
export BUILD_APP2=true
export BUILD_APP3=true

echo $CODEBUILD_GIT_MESSAGE

# extract PE # from the commit
PR_NUMBER=$(echo $CODEBUILD_GIT_MESSAGE | grep -oE '^Merge pull request #[0-9]+ from' | awk {'print $4'} | cut -d'#' -f 2)

if [ "$PR_NUMBER" = "" ]; then
  echo no PR number, must be a squash and merge
  PR_NUMBER=$(echo $CODEBUILD_GIT_MESSAGE | grep -oE '\w*\(#[0-9]+\)$' | cut -d'#' -f 2 | rev | cut -d')' -f 2 | rev)
fi

if [ "$PR_NUMBER" = "" ]; then
  echo no PR number, must be a direct commit
fi

if [ "$PR_NUMBER" != "" ]; then
    echo commit via PR, going to get PR body
    
    export CODEBUILD_PULL_REQUEST=true

    echo curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER

    # get body of the PR
    PR_CURL=`curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER`
    # echo $PR_CURL
    
    export BUILD_APP1=$(echo " $PR_CURL " | grep -q "\[X\] Deploy App1" && echo true || echo false )
    export BUILD_APP2=$(echo " $PR_CURL " | grep -q "\[X\] Deploy App2" && echo true || echo false )
    export BUILD_APP3=$(echo " $PR_CURL " | grep -q "\[X\] Deploy App3" && echo true || echo false )
fi