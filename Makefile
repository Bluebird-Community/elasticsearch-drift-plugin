.DEFAULT_GOAL := build

SHELL               := /bin/bash -o nounset -o pipefail -o errexit
MAVEN_SETTINGS_XML  ?= ./.cicd-assets/settings.xml
ES_VERSION          := 7.17.22

.PHONY help:
help:
	@echo ""
	@echo "Build Drift plugin for NetFlow data in Elasticsearch."
	@echo "Goals:"
	@echo "  help:   Show this help with explaining the build goals"
	@echo "  build:  Compile the plugin against a given Elasticsearch version, default is $(ES_VERSION)"
	@echo "          You can set a version with make build ES_VERSION=7.17.5"
	@echo "  tests:  Run unit tests and integration test suites, IMPORTANT: They can't run as root and will fail."
	@echo "  clean:  Clean the build artifacts"
	@echo ""

.PHONY build:
build:
	mvn --settings=$(MAVEN_SETTINGS_XML) package -Delasticsearch.version=$(ES_VERSION)

.PHONY tests:
tests:
	 mvn --settings=$(MAVEN_SETTINGS_XML) clean test integration-test -Delasticsearch.version=$(ES_VERSION)

.PHONY clean:
clean:
	mvn clean
