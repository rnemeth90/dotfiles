#!/bin/bash
set -e

PROJECT_NAME=$1
PROJECT_DIRECTORY=$2
GITHUB_USERNAME=${GITHUB_USERNAME:-rnemeth90}

# Extract directory-friendly project name from full module path
PROJECT_DIR_NAME=$(basename "$PROJECT_NAME")

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
echo "2) Command-line tool (pflag)"
echo "3) Microservice"
echo "4) Command-line tool (Cobra CLI)"
read -p "Enter the number of your choice: " TEMPLATE_CHOICE

# Determine the working directory based on input
if [ $PROJECT_DIRECTORY ]; then
  echo "Creating ${PROJECT_DIR_NAME} directory at ${PROJECT_DIRECTORY}"
  mkdir -p $PROJECT_DIRECTORY
  WORKING_DIRECTORY=$PROJECT_DIRECTORY/$PROJECT_DIR_NAME
else
  echo "Creating ${PROJECT_DIR_NAME} at ${GOPATH}"
  mkdir -p $GOPATH/$PROJECT_DIR_NAME
  WORKING_DIRECTORY=$GOPATH/$PROJECT_DIR_NAME
fi

# Create root project structure
mkdir -p $WORKING_DIRECTORY
cd $WORKING_DIRECTORY

echo "Initializing new Go module..."
go mod init $PROJECT_NAME

case "$TEMPLATE_CHOICE" in
  1)
    echo "Generating HTTP server project template..."
    mkdir -p internal pkg/logic test

    cat >main.go <<EOF
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
    echo "Generating Command-line tool project template (pflag)..."
    mkdir -p internal pkg/logic test
    go get github.com/spf13/pflag

    cat >main.go <<EOF
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
    mkdir -p internal pkg/logic test

    cat >main.go <<EOF
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
  4)
    echo "Generating Cobra CLI project template..."

    go get github.com/spf13/cobra@latest
    go install github.com/spf13/cobra-cli@latest
    cobra-cli init
    ;;
  *)
    echo "Invalid choice, exiting."
    exit 1
    ;;
esac

# Shared internal and test scaffolding for all templates except Cobra
if [ "$TEMPLATE_CHOICE" != "4" ]; then
  mkdir -p internal pkg/logic test

  cat >pkg/logic/app.go <<EOF
package logic

// Placeholder for core logic
EOF

  cat >internal/utils.go <<EOF
package internal

// Placeholder for internal utility logic
EOF

  cat >test/main_test.go <<EOF
package main_test

import (
        "fmt"
        "os"
        "os/exec"
        "runtime"
        "testing"
)

var (
        binName string = "$PROJECT_DIR_NAME"
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
fi

# Optional Dockerfile
read -p "Do you want to add Docker support? (y/n): " docker_support
if [ "$docker_support" == "y" ]; then
  echo "Creating Dockerfile..."
  cat >Dockerfile <<EOF
FROM golang:1.19 as builder

WORKDIR /app
COPY . .
RUN go build -o /app/$PROJECT_DIR_NAME .

FROM debian:bullseye-slim
WORKDIR /root/
COPY --from=builder /app/$PROJECT_DIR_NAME .
EXPOSE 8080
CMD ["./$PROJECT_DIR_NAME"]
EOF
fi

# GitHub Actions Workflow
mkdir -p .github/workflows
cat >.github/workflows/build.yaml <<'EOF'
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

# Git init
git init
git add .
git commit -m 'Initial commit of project'
