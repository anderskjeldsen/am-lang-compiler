AMLC:=../../target/amlc-latest.jar
CMD=java -jar $(AMLC)

PERF_ITERATIONS ?= 1000
PERF_COUNT ?= 100000
PERF_MODULO ?= 7
PERF_ARGS := $(PERF_ITERATIONS) $(PERF_COUNT) $(PERF_MODULO)
PERF_BIN_DIR := .perf-bin

.PHONY: all test build build-asm clean perf-all perf-c perf-cs perf-go perf-java perf-rs

test:
	@$(CMD) test . -bt linux-x64

build:
	@$(CMD) build . -bt linux-x64

build-amigaos:
	@$(CMD) build . -bt amigaos-docker

build-amigaos-c:
	docker run -v $(PWD)/builds:/host amiga-gcc:latest make -j4 -f amigaos.makefile -C /host all PROGRAM=bin/amigaos/appc


build-asm:
	@$(CMD) build . -bt linux-x64 -asm

clean:
	@$(CMD) clean . -bt linux-x64

perf-all: perf-c perf-cs perf-go perf-java perf-rs
	@echo "Completed performance runs for C, C#, Go, Java, and Rust"

perf-c:
	@mkdir -p $(PERF_BIN_DIR)
	@echo "[C] Building and running with args: $(PERF_ARGS)"
	@cc -O3 Program.c -o $(PERF_BIN_DIR)/program_c
	@$(PERF_BIN_DIR)/program_c $(PERF_ARGS)

perf-cs:
	@echo "[C#] Running with args: $(PERF_ARGS)"
	@if command -v dotnet >/dev/null 2>&1; then \
		mkdir -p $(PERF_BIN_DIR)/cs; \
		if [ ! -f "$(PERF_BIN_DIR)/cs/perf-cs.csproj" ]; then \
			dotnet new console --framework net8.0 --output $(PERF_BIN_DIR)/cs --name perf-cs --force >/dev/null; \
		fi; \
		cp Program.cs $(PERF_BIN_DIR)/cs/Program.cs; \
		dotnet run --project $(PERF_BIN_DIR)/cs/perf-cs.csproj -c Release -- $(PERF_ARGS); \
	else \
		echo "dotnet not found. Install .NET SDK to run C# benchmark."; \
		exit 1; \
	fi

perf-go:
	@mkdir -p $(PERF_BIN_DIR)
	@echo "[Go] Building and running with args: $(PERF_ARGS)"
	@if command -v go >/dev/null 2>&1; then \
		go build -o $(PERF_BIN_DIR)/program_go Program.go; \
		$(PERF_BIN_DIR)/program_go $(PERF_ARGS); \
	else \
		echo "go not found. Install Go to run Go benchmark."; \
		exit 1; \
	fi

perf-java:
	@mkdir -p $(PERF_BIN_DIR)
	@echo "[Java] Building and running with args: $(PERF_ARGS)"
	@if command -v javac >/dev/null 2>&1 && command -v java >/dev/null 2>&1; then \
		javac -d $(PERF_BIN_DIR) Program.java; \
		java -cp $(PERF_BIN_DIR) Program $(PERF_ARGS); \
	else \
		echo "javac/java not found. Install JDK to run Java benchmark."; \
		exit 1; \
	fi

perf-rs:
	@mkdir -p $(PERF_BIN_DIR)
	@echo "[Rust] Building and running with args: $(PERF_ARGS)"
	@if command -v rustc >/dev/null 2>&1; then \
		rustc -C opt-level=2 Program.rs -o $(PERF_BIN_DIR)/program_rs; \
		$(PERF_BIN_DIR)/program_rs $(PERF_ARGS); \
	else \
		echo "rustc not found. Install Rust to run Rust benchmark."; \
		exit 1; \
	fi

