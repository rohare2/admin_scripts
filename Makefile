#$Id: Makefile 199 2014-11-02 14:54:20Z rohare $
#$HeadURL: file:///usr/local/svn/admin/scripts/Makefile $
#
SCRIPT_DIR= /usr/local/sbin
CONFIG_DIR= /usr/local/etc

SCRIPT_FILES= aide_check \
	aide_update \
	mysqldump.pl \
	smart_disk_test

CONFIG_FILES= 

FILES= ${SCRIPT_FILES} ${CONFIG_FILES}

INST= /usr/bin/install

all: $(FILES)

install: uid_chk all
	@for file in ${SCRIPT_FILES}; do \
		${INST} -p $$file ${SCRIPT_DIR} -o root -g wheel -m 760; \
	done
	@for file in ${CONFIG_FILES}; do \
		${INST} -p $$file ${CONFIG_DIR}/$$file -o root -g root -m 640; \
	done

uid_chk:
	@if [ `id -u` != 0 ]; then echo You must become root first; exit 1; fi

