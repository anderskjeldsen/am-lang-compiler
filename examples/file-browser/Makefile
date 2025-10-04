AMLC = amlc.jar
CMD = java -jar $(AMLC)

.PHONY: build
build:
	$(CMD) build . -bt amigaos-docker

.PHONY: test
test:
	$(CMD) test . -bt linux-x64