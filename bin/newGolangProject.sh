#!/bin/bash
set -e

PROJECT_NAME=$1
PROJECT_DIRECTORY=$2
GOPATH=$GOPATH

if [ -z $PROJECT_NAME ]; then
  echo "You must specify a project name at arg1"
  exit 1
fi

if [ -z $GOPATH ] && [ -z $PROJECT_DIRECTORY ]; then
  echo "GOPATH not set and project directory not set"
  exit 1
fi

if [ $PROJECT_DIRECTORY ]; then
  echo "Creating ${PROJECT_NAME} directory at {$PROJECT_DIRECTORY}"
  mkdir -p $PROJECT_DIRECTORY
  WORKING_DIRECTORY=$PROJECT_DIRECTORY/$PROJECT_NAME
else
  echo "Creating ${PROJECT_NAME} at ${GOPATH}"
  mkdir -p $GOPATH/src/$PROJECT_NAME
  WORKING_DIRECTORY=$GOPATH/src/$PROJECT_NAME
fi

PROJECT=$(echo $PROJECT_NAME | rev | cut -d '/' -f1 | rev)
PROJECT_TEST=$PROJECT"_test"

mkdir -p $WORKING_DIRECTORY/cmd/$PROJECT

cat >$WORKING_DIRECTORY/LICENSE.md <<EOF
Copyright 2022 Ryan Nemeth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF

cat >$WORKING_DIRECTORY/cmd/$PROJECT/main.go <<EOF
package main

func main() {

}
EOF

cat >$WORKING_DIRECTORY/cmd/$PROJECT/main_test.go <<EOF
package main_test

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"testing"
)

var (
	binName string = "${PROJECT}"
)

func TestMain(m *testing.M) {
	fmt.Println("Building tool...")

	if runtime.GOOS == "windows" {
		binName += ".exe"
	}

	build := exec.Command("go", "build", "-o", binName)

	if err := build.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Cannot build tool %s: %s", binName, err)
		os.Exit(1)
	}

	fmt.Println("Running tests...")
	resultCode := m.Run()

	fmt.Println("Cleaning up...")
	os.Remove(binName)

	os.Exit(resultCode)
}
EOF

cat >$WORKING_DIRECTORY/$PROJECT.go <<EOF
package $PROJECT
EOF

cat >$WORKING_DIRECTORY/$PROJECT_TEST.go <<EOF
package $PROJECT_TEST
EOF

cat >$WORKING_DIRECTORY/cmd/$PROJECT/makefile <<EOF
TARGETS = linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 windows-386 windows-amd64
COMMAND_NAME = ${PROJECT}
PACKAGE_NAME = github.com/rnemeth90/\$(COMMAND_NAME)
LDFLAGS = -ldflags=-X=main.version=\$(VERSION)
OBJECTS = \$(patsubst \$(COMMAND_NAME)-windows-amd64%,\$(COMMAND_NAME)-windows-amd64%.exe, \$(patsubst \$(COMMAND_NAME)-windows-386%,\$(COMMAND_NAME)-windows-386%.exe, \$(patsubst %,\$(COMMAND_NAME)-%-v\$(VERSION), \$(TARGETS))))

release: format createbuilddir check-env \$(OBJECTS) ## Build release binaries (requires VERSION)

clean: check-env ## Remove release binaries
	rm -rf build

format:
	gofmt -w -s *.go

createbuilddir:
	mkdir -p build/bin

\$(OBJECTS): \$(wildcard *.go)
	env GOOS=$(echo $@ | cut -d'-' -f2) GOARCH=$(echo \$@ | cut -d'-' -f3 | cut -d'.' -f 1) go build -o build/bin/\$@ \$(LDFLAGS) \$(PACKAGE_NAME)

.PHONY: help check-env

check-env:
ifndef VERSION
	\$(error VERSION is undefined)
endif

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*\$\$' \$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", \$\$1, \$\$2}'

.DEFAULT_GOAL := help
EOF

cat >$WORKING_DIRECTORY/create_new_gh_release.sh <<EOF
#!/bin/bash
#
# Calculates new semantic veresion (e.g. v1.0.1) tag, builds Go Lang binary for release,
# generates release notes based on git commits, then creates new Github Release
#

# check for Go Lang compiler and Github CLI binaries
go_bin=\$(which go)
[ -n "\$go_bin" ] || {
  echo "ERROR GoLang binary not available, install it using $(sudo apt install go)"
  exit 2
}
gh_bin=\$(which gh)
[ -n "\$gh_bin" ] || {
  echo "ERROR Github CLI binary not available, https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
  exit 2
}

#
# CALCULATE NEW SEMANTIC TAG (vX.Y.Z)
#
if git tag --sort=committerdate | grep -q ^r; then

  # get latest semantic version tag, construct patch+1
  semantic_version=\$(git tag --sort=-committerdate | grep ^r | grep -Po '^r[0-9]*.[0-9]*.[0-9]*' | head -n1)
  [ -n "\$semantic_version" ] || {
    echo "ERROR could not find semantic version rX.Y.Z"
    exit 3
  }

  major_minor=\$(echo "$semantic_version" | cut -d'.' -f1-2)
  patch=$(echo "\$semantic_version" | cut -d'.' -f3)
  ((patch++))
  newtag="\${major_minor}.\${patch}"
else
  semantic_version=""
  newtag="r1.0.0"
fi
echo "old version: \$semantic_version new_version: \${newtag}"

#
# GOLANG BUILD OF BINARY
#
CUR_DIR=\${PWD##*/}

mkdir -p build
cp cmd/${PROJECT}/main.go build/main.go
cd build
[ -f go.mod ] || go mod init rnemeth90/\$CUR_DIR
go mod tidy
set -x
go build -o ${PROJECT} -ldflags "-X main.Version=\$newtag -X main.BuiltBy=bash" main.go
set +x
cd ..
echo "GoLang binary built as build/main"

#
# GENERATE RELEASE NOTES FROM GIT COMMITS
#
if [ -n "\$semantic_version" ]; then
  git log HEAD...\${semantic_version} --pretty="- %s " >/tmp/\$newtag.log
  [ \$? -eq 0 ] || {
    echo "ERROR could not retrieve logs for 'git log HEAD...\${semantic_version}"
    exit 7
  }
else
  git log --pretty="- %s " >/tmp/\$newtag.log
fi

#
# PUSH, COMMIT NEW TAG, CREATE RELEASE
#
echo ""
echo "== RELEASE \$newtag =================================="
cat /tmp/\$newtag.log
echo "===================================="
echo ""
read -p "Push this new release \$newtag [y/n]? " -i y -e answer
if [[ "\$answer" == "y" ]]; then
  set -x
  git commit -a -m "changes for new tag \$newtag"
  git tag \$newtag && git push origin \$newtag
  git push
  gh release create \$newtag -F /tmp/\$newtag.log build/main.go
  set +x
else
  echo "aborted release creation"
fi
EOF

mkdir -p $WORKING_DIRECTORY/.github/workflows

cat >$WORKING_DIRECTORY/.github/workflows/build.yaml <<EOF
name: build-release-binary

run-name: Create Github Release for GoLang binary

on:
  push:
    #branches:
    #- main
    tags:
    - 'r*'

jobs:

  build:
    runs-on: ubuntu-22.04
    permissions:
      contents: write

    steps:

    # debug
    - name: Dump env
      run: env | sort
    - name: Dump GitHub context
      env:
        GITHUB_CONTEXT: \${{ toJson(github) }}
      run: echo "\$GITHUB_CONTEXT"

    - uses: actions/checkout@v3
      with:
        fetch-depth: 0 # get all tags, needed to get git log
        ref: main

    # Go environment
    - name: setup Go Lang
      id: build
      uses: actions/setup-go@v3
      with:
        go-version: '^1.19.2'
    - run: |
        go version
        cd ./cmd/${PROJECT}/
        mkdir builds
        ls -lisa
        if [ ! -e *.mod ]; then
          go mod init \${GITHUB_REPOSITORY}
        fi
        go mod tidy
        go build -o ${PROJECT} -ldflags "-X main.Version=\${GITHUB_REF_NAME} -X main.BuiltBy=github-actions" main.go
        mv ${PROJECT} builds/
        ls -lisa builds/

    - name: go test
      id: test
      run: |
        go test -v
        cd ./cmd/${PROJECT}/
        go test -v

    - run: git version
    - run: git branch
    - run: git tag

    - name: get semantic tag version and release notes from commit messages
      id: tag
      run: |
        currentTag=\${GITHUB_REF_NAME}
        major_minor=\$(echo "\$currentTag" | cut -d'.' -f1-2)
        patch=$(echo "\$currentTag" | cut -d'.' -f3)
        # avoid empty patch number
        [ -n "\$patch" ] && ((patch--)) || patch=".x"
        previousTag="\${major_minor}.\${patch}"

        echo "" > body.log
        if git tag | grep \$previousTag ; then
          git log -q \${currentTag}...\${previousTag} --pretty="- %s" -q --no-color >> body.log
        else
          git log --pretty="- %s" -q --no-color >> body.log
        fi
        line_count=\$(cat body.log | wc -l)

        echo "currentTag=\$currentTag" >> \$GITHUB_OUTPUT
        echo "previousTag=\$previousTag" >> \$GITHUB_OUTPUT
        echo "line_count=\$line_count" >> \$GITHUB_OUTPUT

    - run: echo currentTag is \${{ steps.tag.outputs.currentTag }}
    - run: echo previousTag is \${{ steps.tag.outputs.previousTag }}
    - run: echo line_count is \${{ steps.tag.outputs.line_count }}
    - run: cat body.log

    #  create Github release with release note from file and binary asset attached
    - uses: ncipollo/release-action@v1
      with:
        name: \${{ env.GITHUB_REF_NAME }}
        tag: \${{ env.GITHUB_REF_NAME }}
        artifacts: ./cmd/${PROJECT}/builds/${PROJECT}
        bodyFile: "body.log"
        token: \${{ secrets.GITHUB_TOKEN }}
        removeArtifacts: true
        allowUpdates: "true"

EOF

cat >$WORKING_DIRECTORY/.gitignore <<EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with \$(go test -c)
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
# vendor/
build/

# Go workspace file
go.work

# Local Builds
out/bin
out/build
EOF

cat >$WORKING_DIRECTORY/readme.md <<EOF
# ${PROJECT} [![build-release-binary](https://github.com/rnemeth90/${PROJECT}/actions/workflows/build.yaml/badge.svg)](https://github.com/rnemeth90/${PROJECT}/actions/workflows/build.yaml) [![Go Report Card](https://goreportcard.com/badge/github.com/rnemeth90/${PROJECT}/)](https://goreportcard.com/report/github.com/rnemeth90/${PROJECT}/)
## Description

## Getting Started

### Dependencies
* to build yourself, you must have Go v1.13+ installed

### Installing
$()$(
  go install github.com/rnemeth90/${PROJECT}@latest
)$()
Or download the latest release [here](https://github.com/rnemeth90/${PROJECT}/releases)

### Executing program
$()$(

)$()
## Help
If you need help, submit an issue

## To Do
- [ ]

## Version History
* 0.1
    * Initial Release

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
EOF

cd $WORKING_DIRECTORY
go mod init $PROJECT_NAME >>/dev/null 2>&1

git init
git add .
git commit -m 'initial commit of project'
