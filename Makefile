NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
ATTN_COLOR=\033[33;01m

ROOT_DIR=$(shell pwd)
BIN_DIR=./bin

GOPKGS=$(shell go list -f '{{.ImportPath}}' ./...)
PKGSDIRS=$(shell go list -f '{{.Dir}}' ./... | grep -v "^vendor\/")

GOOS :=
ifeq ($(OS),Windows_NT)
	GOOS = windows
else 
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		GOOS = linux
	endif
	ifeq ($(UNAME_S),Darwin)
		GOOS = darwin
	endif
endif

GOARCH=amd64

.PHONY: all get clean init build test check install
all: build check test

clean: 
	@echo "$(WARN_COLOR)==> Clean $(BIN_DIR) $(NO_COLOR)"
	@rm -rf ./bin

get:
	@echo "$(OK_COLOR)Get toolchain $(NO_COLOR)"
	dep ensure

init:
	@echo "$(WARN_COLOR)==> init $(NO_COLOR)"
	@[[ -d $(BIN_DIR) ]] || mkdir $(BIN_DIR)

build: init
	@echo "$(WARN_COLOR)==> build GOOS=$(GOOS) GOARCH=$(GOARCH) $(ROOT_DIR) $(NO_COLOR)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BIN_DIR)/aws-ctl ./

install: 
	@echo "$(WARN_COLOR)==> install $(NO_COLOR)"
	@GOOS=$(GOOS) GOARCH=$(GOARCH) go install ./

test:
	@echo "$(WARN_COLOR)==> test $(NO_COLOR)"
	@go test ./...

check: format lint vet

format:
	@echo "$(ATTN_COLOR)==> format$(NO_COLOR)"
	@echo $(PKGSDIRS) | xargs -I '{p}' -n1 goimports -e -l {p} | sed "s/^/Failed: /"
	@echo "$(NO_COLOR)\c"

lint:
	@echo "$(ATTN_COLOR)==> lint$(NO_COLOR)"
	@echo $(PKGSDIRS) | xargs -I '{p}' -n1 golint {p}  | sed "s/^/Failed: /"
	@echo "$(NO_COLOR)\c"

vet:
	@echo "$(ATTN_COLOR)==> vet$(NO_COLOR)"
	@echo $(GOPKGS) | xargs -I '{p}' -n1 go vet {p}  | sed "s/^/Failed: /"
	@echo "$(NO_COLOR)\c"
