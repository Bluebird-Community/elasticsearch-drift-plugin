.DEFAULT_GOAL := build

SHELL               := /bin/bash -o nounset -o pipefail -o errexit
MAVEN_SETTINGS_XML  ?= ""
ES_VERSION          := 9.1.1
ROOT_CHECK          := $(shell if [ "$$(id -u)" = "0" ]; then echo "root"; else echo "not_root"; fi)
PACKAGE_PROFILE     ?= build.fpm.usr.local
PACKAGE_VERSION     ?= 0
VERSION             ?= $(shell git describe --tags --abbrev=0 | grep -oE '([0-9]+\.[0-9]+.[0-9]+)' | head -n 1)
VERSION             := $(if $(VERSION),$(VERSION),2.0.5-SNAPSHOT)

.PHONY help:
help:
	@echo ""
	@echo "Build Drift plugin for NetFlow data in Elasticsearch."
	@echo "Goals:"
	@echo "  mvn-download: Resolve and download Maven dependencies"
	@echo "  help:         Show this help with explaining the build goals"
	@echo "  build:        Compile the plugin against a given Elasticsearch version, default is $(ES_VERSION)"
	@echo "                You can set a version with make build ES_VERSION=7.17.5"
	@echo "  tests:        Run unit tests and integration test suites, IMPORTANT: They can't run as root and will fail."
	@echo "  packages:     Create RPM and Debian packages using fpm in /usr/local/bin/fpm"
	@echo "                If you have fpm in /usr/bin/fpm use set the PACKAGE_PROFILE=build.fpm.usr instead"
	@echo "  clean:        Clean the build artifacts"
	@echo ""

.PHONY deps-build:
deps-build:
	command -v java
	command -v javac
	command -v mvn

.PHONY deps-packages:
deps-packages:
	command -v fpm

.PHONY build:
build: deps-build
	mvn compile -Delasticsearch.version=$(ES_VERSION)

.PHONY tests:
tests: deps-build
ifeq ($(ROOT_CHECK),root)
	@echo "The Elasticsearch tests can't be run as root" >&2
	@false
else
	@echo "Running as non-root user"
	mvn test integration-test -Delasticsearch.version=$(ES_VERSION)
endif

.PHONY packages:
packages: deps-build deps-packages
	mvn package -P $(PACKAGE_PROFILE) -DpackageVersion=$(VERSION) -Drevision=$(VERSION) -DpackageRevision=$(PACKAGE_VERSION) -Delasticsearch.version=$(ES_VERSION)

.PHONY clean:
clean: deps-build
	mvn clean
