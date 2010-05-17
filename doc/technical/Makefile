# Generates HTML, Postscript and PDF from SGML source.
#
# Author(s):  Martin Konold <konold@suse.de
#

NAME=		kolabserver
DEST=		kolabserver
SHELL=		/bin/bash
SGML_SRC=	kolabserver.sgml
DEP_SGML= apache.sgml cyrus.sgml intro.sgml kolab.sgml monit.sgml openssl.sgml proftpd.sgml \
          appendix.sgml extensions.sgml kolabserver.sgml ldap.sgml \
	      openpkg.sgml postfix.sgml sasl.sgml

HTML_DST=	html/index.html
PS_DST=		$(NAME).ps
PDF_DST=	$(NAME).pdf
RTF_DST=	$(NAME).rtf

#HTML_CMD=	db2html -j -f/dev/null
HTML_CMD=	db2html
#PS_CMD=	db2ps -j -f/dev/null
PS_CMD=		db2ps 
#PDF_CMD=	db2pdf -j -f/dev/null
RTF_CMD=	db2rtf


#$(DEST):	mkdir $(DEST)
all: html ps pdf clean rtf

html: $(HTML_DST)
ps:   $(PS_DST)
pdf: $(PDF_DST)
rtf: $(RTF_DST)

html/index.html: $(SGML_SRC)
	$(HTML_CMD) $(SGML_SRC)
	cp erfrakon.png $(DEST)/
	#cat $(DEST)/book1.html | sed -e \
's/SRC=\"erfrakon\.gif\"/SRC=\"erfrakon\.png\"/g'> $(DEST)/index.html
	cp kolab.png $(DEST)/
	#grep -l kolab.gif $(DEST)/*.html | xargs cat | sed -e \
's/SRC=\"kolab\.gif\"/SRC=\"kolab.png\"/g' > /tmp/123.html
	#grep -l kolab.gif $(DEST)/*.html | xargs cp /tmp/123.html

$(NAME).ps: $(SGML_SRC) $(DEP_SGML)
	$(PS_CMD) $(SGML_SRC)

$(NAME).pdf: $(SGML_SRC) $(NAME).ps
	ps2pdf $(NAME).ps

$(NAME).rtf: $(SGML_SRC) $(DEP_SGML)
	$(RTF_CMD) $(SGML_SRC)	

clean:
	rm -f *.tex *.dvi *.aux *.log
	rm -rf db2html*
	rm -rf $(NAME).junk

realclean: clean
	rm -f $(NAME).ps $(NAME).pdf
	rm -rf $(NAME)

#archive: html ps pdf clean
#	scp $(NAME)/*.html $(NAME)/*.gif $(NAME).ps $(NAME).pdf *.sgml 
#root@main:/space/projectdoc/Topics/$(NAME)
