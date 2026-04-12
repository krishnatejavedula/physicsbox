# =============================================================================
# Makefile — PhysicsBox
# =============================================================================
# Common tasks for managing the PhysicsBox container.
# Run `make help` to see all available commands.
# =============================================================================

CONTAINER = physicsbox
SETUP     = ./setup.sh

.DEFAULT_GOAL := help

# -----------------------------------------------------------------------------
# Container lifecycle
# -----------------------------------------------------------------------------

.PHONY: start
start: ## Start the container in the background
	docker compose up -d

.PHONY: stop
stop: ## Stop the container
	docker compose stop

.PHONY: restart
restart: ## Restart the container
	docker compose restart

.PHONY: shell
shell: ## Open a shell inside the container
	docker exec -it -u dev $(CONTAINER) bash

# -----------------------------------------------------------------------------
# Setup
# -----------------------------------------------------------------------------

.PHONY: install
install: ## First-time setup — lean build (default)
	$(SETUP) --install

.PHONY: install-full
install-full: ## First-time setup — full build
	$(SETUP) --install full

.PHONY: rebuild
rebuild: ## Rebuild the image using cache (lean)
	$(SETUP) --rebuild

.PHONY: rebuild-full
rebuild-full: ## Rebuild the image using cache (full)
	$(SETUP) --rebuild full

.PHONY: rebuild-clean
rebuild-clean: ## Full clean rebuild from scratch (lean)
	$(SETUP) --rebuild --clean

.PHONY: uninstall
uninstall: ## Remove container and image (files untouched)
	$(SETUP) --uninstall

# -----------------------------------------------------------------------------
# Development
# -----------------------------------------------------------------------------

.PHONY: notebook
notebook: ## Launch JupyterLab in the browser
	docker exec -it -u dev $(CONTAINER) bash -c \
		"conda run -n physicsbox jupyter lab --ip=0.0.0.0 --no-browser"

.PHONY: doctor
doctor: ## Check everything is installed and working
	$(SETUP) --doctor

# -----------------------------------------------------------------------------
# Tests
# -----------------------------------------------------------------------------

.PHONY: test
test: test-python test-c test-packages ## Run all tests

.PHONY: test-python
test-python: ## Test Python environment
	docker exec $(CONTAINER) bash /opt/physicsbox/tests/test_python.sh

.PHONY: test-c
test-c: ## Test C toolchain and GSL
	docker exec $(CONTAINER) bash /opt/physicsbox/tests/test_c.sh

.PHONY: test-packages
test-packages: ## Test conda package integrity
	docker exec $(CONTAINER) bash /opt/physicsbox/tests/test_packages.sh

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

.PHONY: clean
clean: ## Remove dangling Docker images
	docker image prune -f

.PHONY: status
status: ## Show container status and image size
	@echo "\n[ Container ]"
	@docker ps -a --filter name=$(CONTAINER) --format "  {{.Names}}  {{.Status}}"
	@echo "\n[ Image ]"
	@docker image ls $(CONTAINER) --format "  {{.Repository}}:{{.Tag}}  {{.Size}}"
	@echo ""

.PHONY: help
help: ## Show this help
	@echo ""
	@echo "  PhysicsBox — available commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-20s %s\n", $$1, $$2}'
	@echo ""