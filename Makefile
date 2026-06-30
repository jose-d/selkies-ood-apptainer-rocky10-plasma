BASE_IMAGE ?= rocky10-plasma-base.sif
BASE_DEF ?= rocky10-plasma-base.def
IMAGE ?= rocky10-plasma.sif
DEF ?= rocky10-plasma.def
APPTAINER ?= apptainer

.PHONY: build base final clean

build: base final

base:
	$(APPTAINER) build --force $(BASE_IMAGE) $(BASE_DEF)

final: $(BASE_IMAGE)
	$(APPTAINER) build --force $(IMAGE) $(DEF)

clean:
	rm -f $(IMAGE) $(BASE_IMAGE)
