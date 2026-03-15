AMLC:=../../target/amlc-latest.jar
CMD=java -jar $(AMLC)

.PHONY: all test build build-asm clean

test:
	@$(CMD) test . -bt linux-x64

build:
	@$(CMD) build . -bt linux-x64

build-asm:
	@$(CMD) build . -bt linux-x64 -asm

clean:
	@$(CMD) clean . -bt linux-x64

