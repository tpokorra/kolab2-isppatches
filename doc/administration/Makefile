# Generates HTML, Postscript and PDF from SGML source.
#

NAME=		administration
DEST=		administration
SHELL=		/bin/bash
SGML_SRC=	administration.sgml

HTML_DST=	html/index.html
PS_DST=		$(NAME).ps
PDF_DST=	$(NAME).pdf
RTF_DST=	$(NAME).rtf

#HTML_CMD=	db2html -j -f/dev/null
HTML_CMD=	db2html
#PS_CMD=		db2ps -j -f/dev/null
PS_CMD=		/usr/bin/db2ps 
#PDF_CMD=	db2pdf -j -f/dev/null
RTF_CMD=	db2rtf


#$(DEST):	mkdir $(DEST)
all: html ps pdf rtf clean

html: $(HTML_DST)
ps:   $(PS_DST)
pdf: $(PDF_DST)
rtf: $(RTF_DST)

html/index.html: $(SGML_SRC)
	$(HTML_CMD) $(SGML_SRC)
	#gif2png.sh $(DEST)

$(NAME).ps: $(SGML_SRC)
	$(PS_CMD) $(SGML_SRC)

$(NAME).pdf: $(SGML_SRC) $(NAME).ps
	ps2pdf $(NAME).ps

$(NAME).rtf: $(SGML_SRC) frontend.rtf.sgml intro.rtf.sgml
	cat $< | \
    sed 's/^\(<!entity chapter-[a-z]* SYSTEM "[^<>"]\+\).sgml"/\1.rtf.sgml"/' \
		> $(NAME).rtf.sgml
	db2rtf $(NAME).rtf.sgml
	mv $(NAME).rtf.rtf $@
	

%.rtf.sgml: %.sgml
	cat $< | \
		sed 's/\(<inlinegraphic [^<>]* fileref="[^<>"]\+\)"/\1.png"/' \
		> $@
	

clean:
	rm -f *.tex *.dvi *.aux *.log
	rm -rf db2html*
	rm -rf $(NAME).junk
	-rm *.rtf.sgml

realclean: clean
	rm -f $(NAME).ps $(NAME).pdf
	rm -rf $(NAME)
