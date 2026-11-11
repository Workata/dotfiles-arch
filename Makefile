SHELL := /bin/bash

.PHONY: init
init:
	@echo -e "[Makefile] Initializing!\n"
	prek install

.PHONY: backup
ARGS ?=
backup:
	@echo -e "[Makefile] Running backup script!\n"
	@./scripts/backup.sh $(ARGS) 2>&1 | tee "logs/backup/run__$$(date '+%Y-%m-%d__%H-%M-%S').log"

.PHONY: restore
ARGS ?=
restore:
	@echo -e "[Makefile] Running restore script!\n"
	@./scripts/restore.sh $(ARGS) 2>&1 | tee "logs/restore/run__$$(date '+%Y-%m-%d__%H-%M-%S').log"

.PHONY: check
check:
	@echo -e "[Makefile] Checking scripts...\n"
	@echo "[Makefile] Running linter (shellcheck)..."
	@shellcheck scripts/*.sh
	@echo "[Makefile] Running formatter (shfmt)..."
	@shfmt -i 4 -ci -l -w -d ./scripts/


.PHONY: clear-logs
clear-logs:
	@echo -e "[Makefile] Clearing logs...\n"
	@./scripts/clear_logs.sh
