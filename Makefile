packages := $(shell go list ./...)

LINTER_BIN ?= golangci-lint

GO111MODULE := on
export GO111MODULE

TEST_CREDENTIALS_DIR ?= $(PWD)/.azure
TEST_CREDENTIALS_JSON ?= $(TEST_CREDENTIALS_DIR)/credentials.json
TEST_LOGANALYTICS_JSON ?= $(TEST_CREDENTIALS_DIR)/loganalytics.json
export TEST_CREDENTIALS_JSON TEST_LOGANALYTICS_JSON

.PHONY: test
test:
	@echo running tests
	@AZURE_AUTH_LOCATION=$(TEST_CREDENTIALS_JSON) LOG_ANALYTICS_AUTH_LOCATION=$(TEST_LOGANALYTICS_JSON) go test -v $(packages)

.PHONY: vet
vet:
	@go vet $(packages)

.PHONY: lint
lint:
	@$(LINTER_BIN) run --new-from-rev "HEAD~$(git rev-list master.. --count)" ./...

.PHONY: mod
mod:
	@go mod tidy

.PHONY: testauth
testauth: $(TEST_CREDENTIALS_JSON) $(TEST_LOGANALYTICS_JSON)

$(TEST_CREDENTIALS_JSON):
	@echo Building test credentials
	@hack/ci/create_credentials.sh

$(TEST_LOGANALYTICS_JSON):
	@echo Building log analytics credentials
	@hack/ci/create_loganalytics_auth.sh
