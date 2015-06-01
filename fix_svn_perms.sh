# !/bin/bash
# $Id: fix_svn_perms.sh 190 2014-10-31 09:52:19Z rohare $
# $URL: file:///usr/local/svn/admin/scripts/fix_svn_perms.sh $
# Correct svn repo file permissions for use with apache

if [ -z ${1+xxx } ]; then
	echo "Please provide a svn repository path"
	exit
else
	repo=$1
fi

if [ -d "${repo}" ]; then
	chown -R apache ${repo}
else
	echo "Woops, there is no $repo svn repository"
fi

