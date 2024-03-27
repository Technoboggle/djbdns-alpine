
BASENAME=djbdns
BUILDNAME=$(BASENAME)-buildx

.PHONY: all builder prune delete clean distclean

all: ./build_now.sh

clean: prune

distclean: clean delete

builder:
	docker buildx create --use --name=$(BUILDNAME)

prune:
	docker buildx prune -f

delete:
	docker buildx rm $(BUILDNAME)
