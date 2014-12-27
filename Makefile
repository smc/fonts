#!/usr/bin/make -f

fontpath=/usr/share/fonts/truetype/malayalam
fonts=AnjaliOldLipi Chilanka Dyuthi Kalyani Keraleeyam Meera Rachana RaghuMalayalamSans Suruma

version = 6.1

default: clean compile
all: clean compile test webfonts

compile:
# generate ttf files from sfd files
	@for font in `echo ${fonts}`;do \
		fontforge -lang=ff -c "Open('$${font}/$${font}.sfd'); Generate('$${font}/$${font}.ttf')"; \
	done;

install: compile
# copy ttf files to system font directory
	@for font in `echo ${fonts}`;do \
		install -D -m 0644  $${font}/$${font}.ttf \
			${DESTDIR}/${fontpath}/$${font}.ttf;\
	done;

# copy fontconfig configuration files to system fontconfig
# configuration directory
	install -D -m 0644 malayalam-fonts.conf\
	 	${DESTDIR}/etc/fonts/conf.avail/67-malayalam-fonts.conf
	if [ ! -d ${DESTDIR}/etc/fonts/conf.d ]; then\
		mkdir ${DESTDIR}/etc/fonts/conf.d; \
	fi;

	ln -sf ../conf.avail/67-malayalam-fonts.conf\
		${DESTDIR}/etc/fonts/conf.d/67-malayalam-fonts.conf

uninstall:
# remove fonts from system font directories
	@for font in `echo ${fonts}`;do \
		if [ -f ${DESTDIR}/${fontpath}/$${font}.ttf ]; then\
			rm -f ${DESTDIR}/${fontpath}/$${font}.ttf;\
		fi \
	done;

# remove fontconfig configuration files from system fontconfig
# configuration directory
	if [ -f ${DESTDIR}/etc/fonts/conf.d/67-malayalam-fonts.conf ]; then \
	rm ${DESTDIR}/etc/fonts/conf.d/67-malayalam-fonts.conf; fi

	if [ -f ${DESTDIR}/etc/fonts/conf.avail/67-malayalam-fonts.conf ];then \
		rm ${DESTDIR}/etc/fonts/conf.avail/67-malayalam-fonts.conf;\
	fi

	if [ -d ${DESTDIR}/${fontpath} -a -z "$(ls -A ${DESTDIR}/${fontpath})" ];\
	then \
		rmdir ${DESTDIR}/${fontpath};\
	fi

clean:
# remove ttf fonts
	@for font in `echo ${fonts}`;do \
		if [ -f $${font}/$${font}.ttf ];then\
			rm -f $${font}/$${font}.ttf;\
		fi \
	done;
	@rm -rf tests/*.pdf webfonts sdist ignore-file;

test: compile
# Test the fonts
	@for font in `echo ${fonts}`;do \
		echo "Testing font $${font}";\
		hb-view $${font}/$${font}.ttf --text-file tests/tests.txt \
			--output-file tests/$${font}.pdf; \
	done

webfonts: compile
	@echo "Generating webfonts"
	@for font in `echo ${fonts}`;do \
		mkdir -p webfonts/$${font}; \
		sfntly -w $${font}/$${font}.ttf\
			webfonts/$${font}/$${font}.woff; \
		sfntly -e -x $${font}/$${font}.ttf\
		 webfonts/$${font}/$${font}.eot; \
		echo "Webfonts generated for $${font}"; \
	done
sdist: $(fonts) ChangeLog Makefile generate.pe malayalam-fonts.conf
	echo ".git\nignore-file" > ignore-file
	tar --owner root --group root --mode a+rX \
		-X ignore-file -cvf - . | xz -9 >\
		 ../malayalam-fonts-$(version).tar.xz
	touch "$@"
