#$Id: Makefile 199 2014-11-02 14:54:20Z rohare $
#$HeadURL: file:///usr/local/svn/admin/scripts/Makefile $
#
SCRIPT_DIR= /usr/local/sbin
CONFIG_DIR= /usr/local/etc

SCRIPT_FILES= autoban_http.pl \
	autoban_ssh.pl \
	check_loginsec \
	check_passwd \
	cleanup \
	dec2ip.sh \
	find_suid_files \
	ip2dec.sh \
	ipcs_clean \
	kill_by_user \
	kill_defunct \
	kill_idle_users \
	loadzones.pl \
	sar_plot \
	sensor_chk

CONFIG_FILES= 

FILES= ${SCRIPT_FILES} ${CONFIG_FILES}

INST= /usr/bin/install

all: $(FILES)

install: uid_chk all
	@for file in ${SCRIPT_FILES}; do \
		${INST} -p $$file ${SCRIPT_DIR} -o root -g admins -m 700; \
	done
	@for file in ${CONFIG_FILES}; do \
		${INST} -p $$file ${CONFIG_DIR}/$$file -o root -g admins -m 640; \
	done

uid_chk:
	@if [ `id -u` != 0 ]; then echo You must become root first; exit 1; fi

