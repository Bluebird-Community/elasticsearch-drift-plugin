.DEFAULT_GOAL := build

SHELL               := /bin/bash -o nounset -o pipefail -o errexit
MAVEN_SETTINGS_XML  ?= ./.cicd-assets/settings.xml
ES_VERSION          := 7.17.22
ROOT_CHECK          := $(shell if [ "$$(id -u)" = "0" ]; then echo "root"; else echo "not_root"; fi)

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
	@echo "  clean:        Clean the build artifacts"
	@echo ""

.PHONY mvn-download:
mvn-download:
	mvn --settings=$(MAVEN_SETTINGS_XML) dependency:resolve-plugins dependency:go-offline

.PHONY build:
build: mvn-download
	mvn --settings=$(MAVEN_SETTINGS_XML) package -Delasticsearch.version=$(ES_VERSION)

.PHONY tests:
tests: mvn-download
ifeq ($(ROOT_CHECK),root)
	@echo "The Elasticsearch tests can't be run as root" >&2
	@false
else
	@echo "Running as non-root user"
	mvn --settings=$(MAVEN_SETTINGS_XML) test integration-test -Delasticsearch.version=$(ES_VERSION)
endif

.PHONY clean:
clean:
	mvn clean
