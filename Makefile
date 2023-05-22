GIT_ROOT ?= $(shell git rev-parse --show-toplevel)

help: ## Show all Makefile targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[33m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: format lint type style clean run-benchmarks
format: ## Running code formatter: black and isort
	@echo "(isort) Ordering imports..."
	@isort .
	@echo "(black) Formatting codebase..."
	@black --config pyproject.toml zipfai tests examples
	@echo "(black) Formatting stubs..."
	@find zipfai -name "*.pyi" ! -name "*_pb2*" -exec black --pyi --config pyproject.toml {} \;
	@echo "(ruff) Running fix only..."
	@ruff check zipfai examples tests --fix-only
lint: ## Running lint checker: ruff
	@echo "(ruff) Linting development project..."
	@ruff check zipfai examples tests
type: ## Running type checker: pyright
	@echo "(pyright) Typechecking codebase..."
	@pyright zipfai
clean: ## Clean all generated files
	@echo "Cleaning all generated files..."
	@cd $(GIT_ROOT)/docs && make clean
	@cd $(GIT_ROOT) || exit 1
	@find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
run-ci: format lint type ## Running all CI checks
run-benchmarks: ## Run benchmarks
	@echo "Running benchmarks..."
	@cd $(GIT_ROOT)/tests/benchmarks && python benchmark.py 
