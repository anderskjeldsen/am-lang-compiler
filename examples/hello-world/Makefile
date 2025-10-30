AMLC = amlc.jar
CMD = java -jar $(AMLC)

.PHONY: build
build:
	$(CMD) build . -bt linux-x64

.PHONY: test
test:
	$(CMD) test . -bt linux-x64