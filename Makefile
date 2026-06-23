IMAGE ?= rocky10-plasma.sif
DEF ?= rocky10-plasma.def
APPTAINER ?= apptainer

.PHONY: build clean

build:
	$(APPTAINER) build --force $(IMAGE) $(DEF)

clean:
	rm -f $(IMAGE)
