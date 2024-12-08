#!/bin/bash
set -e

PROJECT_NAME=$1
PROJECT_DIRECTORY=$2
GOPATH=$GOPATH

# Ensure there are no leading slashes in the project name
PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/^\///')

if [ -z $PROJECT_NAME ]; then
  echo "You must specify a project name at arg1"
  exit 1
fi

if [ -z $GOPATH ] && [ -z $PROJECT_DIRECTORY ]; then
  echo "GOPATH not set and project directory not set"
  exit 1
fi

# Prompt the user to choose a project template
echo "Choose a project template:"
echo "1) HTTP server"
echo "2) Command-line tool"
echo "3) Microservice"
read -p "Enter the number of your choice: " TEMPLATE_CHOICE

# Determine the working directory based on input
if [ $PROJECT_DIRECTORY ]; then
  echo "Creating ${PROJECT_NAME} directory at ${PROJECT_DIRECTORY}"
  mkdir -p $PROJECT_DIRECTORY
  WORKING_DIRECTORY=$PROJECT_DIRECTORY/$PROJECT_NAME
else
  echo "Creating ${PROJECT_NAME} at ${GOPATH}"
  mkdir -p $GOPATH/src/$PROJECT_NAME
  WORKING_DIRECTORY=$GOPATH/src/$PROJECT_NAME
fi

# Define additional directories for better structure
SRC_DIRECTORY=$WORKING_DIRECTORY/src
TEST_DIRECTORY=$WORKING_DIRECTORY/test
PKG_DIRECTORY=$WORKING_DIRECTORY/pkg
CMD_DIRECTORY=$SRC_DIRECTORY/cmd/$PROJECT
INTERNAL_DIRECTORY=$WORKING_DIRECTORY/internal

# Create directories for src, cmd, internal, and pkg
echo "Setting up project structure in $WORKING_DIRECTORY"
mkdir -p $CMD_DIRECTORY $TEST_DIRECTORY $PKG_DIRECTORY $INTERNAL_DIRECTORY

# Initialize Go module, but only if no existing go.mod file is found
if [ ! -f "$WORKING_DIRECTORY/go.mod" ]; then
  echo "Initializing new Go module..."
  cd $WORKING_DIRECTORY
  go mod init $PROJECT_NAME
else
  echo "Go module already exists, skipping go mod init..."
fi

# Install pflag for CLI if the template is a command-line tool
if [ "$TEMPLATE_CHOICE" == "2" ]; then
  echo "Adding pflag as a dependency for the command-line tool..."
  go get github.com/spf13/pflag
fi

# Generate the selected template structure and files
case "$TEMPLATE_CHOICE" in
  1)
    echo "Generating HTTP server project template..."
    # Main.go for HTTP server
    cat >$CMD_DIRECTORY/main.go <<EOF
package main

import (
    "fmt"
    "log"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello, World!")
}

func main() {
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF
    ;;
  2)
    echo "Generating Command-line tool project template..."
    # Main.go for CLI
    cat >$CMD_DIRECTORY/main.go <<EOF
package main

import (
    "fmt"
    "github.com/spf13/pflag"
)

func main() {
    var name string
    pflag.StringVarP(&name, "name", "n", "", "Your name")
    pflag.Parse()

    if name == "" {
        fmt.Println("Please provide your name using the --name flag.")
        return
    }

    fmt.Printf("Hello, %s!\n", name)
}
EOF
    ;;
  3)
    echo "Generating Microservice project template..."
    # Main.go for Microservice
    cat >$CMD_DIRECTORY/main.go <<EOF
package main

import (
    "fmt"
    "log"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Microservice is up and running!")
}

func main() {
    fmt.Println("Starting microservice on port 8080...")
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
EOF
    ;;
  *)
    echo "Invalid choice, exiting."
    exit 1
    ;;
esac

# Logic package for future modularization
mkdir -p $PKG_DIRECTORY/logic
cat >$PKG_DIRECTORY/logic/app.go <<EOF
package logic

// Placeholder for core logic
EOF

# Test structure in the test directory
cat >$TEST_DIRECTORY/main_test.go <<EOF
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

# Internal directory for shared utilities or core logic
cat >$INTERNAL_DIRECTORY/utils.go <<EOF
package internal

// Placeholder for internal utility logic
EOF

# Root Makefile
cat >$WORKING_DIRECTORY/Makefile <<EOF
TARGETS = linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 windows-386 windows-amd64
COMMAND_NAME = ${PROJECT}
PACKAGE_NAME = github.com/rnemeth90/\$(COMMAND_NAME)/src/cmd/\$(COMMAND_NAME)
LDFLAGS = -ldflags=-X=main.version=\$(VERSION)
OBJECTS = \$(patsubst \$(COMMAND_NAME)-windows-amd64%,\$(COMMAND_NAME)-windows-amd64%.exe, \$(patsubst \$(COMMAND_NAME)-windows-386%,\$(COMMAND_NAME)-windows-386%.exe, \$(patsubst %,\$(COMMAND_NAME)-%-v\$(VERSION), \$(TARGETS))))

release: format createbuilddir check-env \$(OBJECTS) ## Build release binaries (requires VERSION)

clean: check-env ## Remove release binaries
        rm -rf build

format:
        gofmt -w -s src/**/*.go

createbuilddir:
        mkdir -p build/bin

\$(OBJECTS): \$(wildcard src/cmd/${PROJECT}/*.go)
        env GOOS=\$(echo \$@ | cut -d'-' -f2) GOARCH=\$(echo \$$@ | cut -d'-' -f3 | cut -d'.' -f 1) go build -o build/bin/\$@ \$(LDFLAGS) \$(PACKAGE_NAME)

.PHONY: help check-env

check-env:
ifndef VERSION
        \$(error VERSION is undefined)
endif

help:
        @grep -E '^[a-zA-Z_-]+:.*?## .*\$\$' \$(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", \$$1, \$$2}'

.DEFAULT_GOAL := help
EOF

# Optional Dockerfile
read -p "Do you want to add Docker support? (y/n): " docker_support

if [ "$docker_support" == "y" ]; then
  echo "Creating Dockerfile..."

  # Create Dockerfile in the project root
  cat >$WORKING_DIRECTORY/Dockerfile <<EOF
# Stage 1: Build the Go binary
FROM golang:1.19 as builder

WORKDIR /app

COPY . .

# Build the Go app
RUN cd src/cmd/${PROJECT} && go build -o /app/${PROJECT}

# Stage 2: Run the Go app
FROM debian:bullseye-slim

WORKDIR /root/

# Copy the Go binary from the builder stage
COPY --from=builder /app/${PROJECT} .

# Expose port 8080 (or whichever port your app uses)
EXPOSE 8080

# Run the Go app
CMD ["./${PROJECT}"]
EOF

  echo "Dockerfile created in the project root"
fi

# GitHub Workflow: Build Docker Image and Push to GHCR
mkdir -p $WORKING_DIRECTORY/.github/workflows
cat >$WORKING_DIRECTORY/.github/workflows/build.yaml <<'EOF'
name: Build Go Project

on:
  push:
    tags:
      - 'v*'

env:
  GO_VERSION: '1.19'

jobs:
  build:
    runs-on: ubuntu-22.04
    strategy:
      matrix:
        goos: [linux, windows, darwin]
        goarch: [amd64, 386, arm64]

    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Set up Go
        uses: actions/setup-go@v3
        with:
          go-version: ${{ env.GO_VERSION }}

      - name: Build Go binary for ${{ matrix.goos }}/${{ matrix.goarch }}
        run: |
          mkdir -p build/${{ matrix.goos }}-${{ matrix.goarch }}
          GOOS=${{ matrix.goos }} GOARCH=${{ matrix.goarch }} go build -o build/${{ matrix.goos }}-${{ matrix.goarch }}/app .

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-${{ matrix.goos }}-${{ matrix.goarch }}
          path: build/${{ matrix.goos }}-${{ matrix.goarch }}/
EOF

# Git setup
git init
git add .
git commit -m 'initial commit of project'
