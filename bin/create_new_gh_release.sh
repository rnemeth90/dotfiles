#!/bin/bash
#
# Calculates new semantic veresion (e.g. v1.0.1) tag, builds Go Lang binary for release,
# generates release notes based on git commits, then creates new Github Release
#

# check for Go Lang compiler and Github CLI binaries
go_bin=$(which go)
[ -n "$go_bin" ] || { echo "ERROR GoLang binary not available, install it using `sudo apt install go`"; exit 2; }
gh_bin=$(which gh)
[ -n "$gh_bin" ] || { echo "ERROR Github CLI binary not available, https://github.com/cli/cli/blob/trunk/docs/install_linux.md"; exit 2; }

#
# CALCULATE NEW SEMANTIC TAG (vX.Y.Z)
#
if git tag --sort=committerdate | grep -q ^r ; then

  # get latest semantic version tag, construct patch+1
  semantic_version=$(git tag --sort=-committerdate | grep ^r | grep -Po '^r[0-9]*.[0-9]*.[0-9]*' | head -n1)
  [ -n "$semantic_version" ] || { echo "ERROR could not find semantic version rX.Y.Z"; exit 3; }

  major_minor=$(echo "$semantic_version" | cut -d'.' -f1-2)
  patch=$(echo "$semantic_version" | cut -d'.' -f3)
  ((patch++))
  newtag="${major_minor}.${patch}"
else
  semantic_version=""
  newtag="r1.0.0"
fi
echo "old version: $semantic_version new_version: ${newtag}"

#
# GOLANG BUILD OF BINARY
#
CUR_DIR=${PWD##*/}

mkdir -p build
cp src/main.go build/main.go
cd build
[ -f go.mod ] || go mod init rnemeth90/$CUR_DIR
go mod tidy
set -x
go build -ldflags "-X main.Version=$newtag -X main.BuiltBy=bash" main.go
set +x
cd ..
echo "GoLang binary built as build/main"


#
# GENERATE RELEASE NOTES FROM GIT COMMITS
#
if [ -n "$semantic_version" ]; then
  git log HEAD...${semantic_version} --pretty="- %s " > /tmp/$newtag.log
  [ $? -eq 0 ] || { echo "ERROR could not retrieve logs for 'git log HEAD...${semantic_version}"; exit 7; }
else
  git log --pretty="- %s " > /tmp/$newtag.log
fi



#
# PUSH, COMMIT NEW TAG, CREATE RELEASE
#
echo ""
echo "== RELEASE $newtag =================================="
cat /tmp/$newtag.log
echo "===================================="
echo ""
read -p "Push this new release $newtag [y/n]? " -i y -e answer
if [[ "$answer" == "y" ]]; then
  set -x
  git commit -a -m "changes for new tag $newtag"
  git tag $newtag && git push origin $newtag
  git push
  gh release create $newtag -F /tmp/$newtag.log build/main
  set +x
else
  echo "aborted release creation"
fi
