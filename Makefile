MARKDOWN:=immutable-infrastructure-persistence.md

all: cleaver
	cleaver $(MARKDOWN)

watch: cleaver
	cleaver watch $(MARKDOWN)

cleaver:
	which cleaver || npm install -g cleaver

