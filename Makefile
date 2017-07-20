# http://www.drchip.org/astronaut/src/index.html#MKVIMBALL
MKVIMBALL := mkvimball

FILES := $(wildcard */logbuch.*)
BASENAME = vim-logbuch

all: $(BASENAME).vba

$(BASENAME).vba: $(FILES)
	$(MKVIMBALL) $(BASENAME) $^

.PHONY: all
