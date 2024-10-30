#!/bin/bash
latestVersion=$1;
echo "latest tag available in github: $latestVersion"
buildTag=$2; #required for non-prod build
#get commitId, To get only hash value of commit
commitId=$(git log -n 1 --pretty=format:"%H")
#get current year to set major version
currentYear=$(date +%y)
#get current quarter to set minor version
currentQuarter=$(( ($(date +%-m)-1)/3+1 ))
preFix=tplgy-api
minor=0
patch=0

if [ -z "$latestVersion" ]
then
  echo "Latest tag does not exists"
  echo "Creating new tag."
  #get current year to set major version
  majorReset=1
  releaseVersion="$majorReset"."$minor"."$patch"-"$preFix"."$currentYear"."$currentQuarter"
  if [ "$buildTag" == 'SNAPSHOT' ]
  then
  releaseVersion="$releaseVersion"."$commitId"
  echo "Bumped Tag: $releaseVersion"
  echo "::set-output name=new-artifact-tag::$releaseVersion"
  echo "new-artifact-tag=$releaseVersion" >> "${GITHUB_ENV}"
  exit
  fi
fi

echo "Latest Tag: ${latestVersion}"
#Using Internal Field Seperator to split prefix and version
IFS=' - '
read -ra logic <<< "$latestVersion"
versionId="${logic[0]}"
echo "current versionId: ${versionId}"
if [ -z "$versionId" ]
then
  #Handle exception here..
  echo "Latest version does not exists"
  exit
else
  IFS='.' read -r -a array <<< "$versionId"
  major="${array[0]}"
  echo "current major: ${major}"
fi
#set prefix
preFixVersion="${logic[1]}"
echo "current preFixVersion: ${preFixVersion}"
IFS='.' read -r -a array <<< "$preFixVersion"
versionYear="${array[1]}"
echo "current versionYear: ${versionYear}"
versionQuarter="${array[2]}"
echo "current versionQuarter: ${versionQuarter}"

majorIncrement=$((major+1))
if [ "$currentYear" == "$versionYear" ] && [ "$currentQuarter" == "$versionQuarter" ]
 then
    releaseVersion="$majorIncrement"."$minor"."$patch"-"$preFix"."$versionYear"."$versionQuarter"
elif [ "$currentYear" == "$versionYear" ] && [ "$currentQuarter" != "$versionQuarter" ]
 then
    releaseVersion="$majorIncrement"."$minor"."$patch"-"$preFix"."$versionYear"."$currentQuarter"
else
    majorReset=1
    releaseVersion="$majorReset"."$minor"."$patch"-"$preFix"."$currentYear"."$currentQuarter"
fi

#set release Version tag
if [ "$buildTag" == 'SNAPSHOT' ]
then
  releaseVersion="$releaseVersion"."$commitId"
  echo "Bumped Tag: $releaseVersion"
  echo "::set-output name=new-artifact-tag::$releaseVersion"
  echo "new-artifact-tag=$releaseVersion" >> "${GITHUB_ENV}"
else
  echo "Bumped Tag: $releaseVersion"
  echo "::set-output name=new-artifact-tag::$releaseVersion"
  echo "new-artifact-tag=$releaseVersion" >> "${GITHUB_ENV}"
fi