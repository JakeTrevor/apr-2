.PHONY: clean all presentation report diagram watch-presentation

all: build/report.pdf
presentation: build/presentation.pdf
report: build/report.pdf
diagram: build/diagram.png
scratch: build/lattice.pdf
diagram-ex: build/diagram-extended.png

# Report
build/report.pdf: report/*.tex report/**/*.tex report/refs.bib
	@latexmk -g -pdf -outdir=build -f report/report.tex


# Diagram
build/diagram.pdf: report/diagrams/ccf-diagram.tex report/diagrams/diagram.tex
	@latexmk -g -pdf -outdir=build -f report/diagrams/diagram.tex

build/diagram.png: build/diagram.pdf
	magick -density 300 $< -quality 90 $@;

build/diagram-extended.pdf: report/diagrams/ccf-extended.tex report/diagrams/diagram-extended.tex
	@latexmk -g -pdf -outdir=build -f report/diagrams/diagram-extended.tex

build/diagram-extended.png: build/diagram-extended.pdf
	magick -density 300 $< -quality 90 $@;


# Presentation
build/presentation.pdf: presentation/apr-presentation.md diagram
	marp --allow-local-files --pdf -o $@ $<

watch-presentation:
	marp --allow-local-files --pdf -o build/presentation.pdf --watch presentation/apr-presentation.md


# Scratch:
build/lattice.pdf: presentation/lattice-point.md diagram
	marp --allow-local-files --pdf -o $@ $<

watch-lattice: 
	marp --allow-local-files --pdf -o build/lattice.pdf --watch presentation/lattice-point.md

# Clean
clean: 
	@latexmk -outdir=build -C report.pdf
	@rm -f paper.bbl