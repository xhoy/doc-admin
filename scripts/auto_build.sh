#!/bin/sh
# --
# scripts/auto_build.sh - Build tar.(gz|bz2) archive of the files from the admin manual
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# --
PATH_TO_CVS_SRC=$1
PRODUCT=doc-admin
VERSION=$2
RELEASE=$3
LANGUAGE="all"
PICTURES=1
ARCHIVE_DIR="doc-admin/"
PACKAGE=doc-admin
PACKAGE_BUILD_DIR="/tmp/$PACKAGE-build"
PACKAGE_DEST_DIR="/tmp/$PACKAGE-packages"

function usage
{
    echo "auto_build.sh 1.0"
    echo ""
    echo "  Build archives of the admin manual that contain the xml files and/or the pictures"
    echo "  and/or the scripts for all or a specific language"
    echo ""
    echo "Copyright (c) 2002-2006 Martin Edenhofer <martin@otrs.org>"
    echo ""
    echo "Usage: auto_build.sh <PATH_TO_CVS_SRC> <VERSION> <RELEASE> [LANG] [-p]"
    echo ""
    echo "Examples:"
    echo ""
    echo "  Build archives with all files:"
    echo ""
    echo "    auto_build.sh /home/ernie/src/doc-admin 1.0.2 01"
    echo ""
    echo "  Build archives that contain files for all languages and no pictures:"
    echo ""
    echo "    auto_build.sh /home/ernie/src/doc-admin 1.0.2 01 -p"
    echo ""
    echo "  Build archives for English files only with all pictures:"
    echo ""
    echo "    auto_build.sh /home/ernie/src/doc-admin 1.0.2 01 en"
    echo ""
    echo "  Build archives for German files only without pictures:"
    echo ""
    echo "    auto_build.sh /home/ernie/src/doc-admin 1.0.2 01 de -p"
    echo ""
    exit 1
}

if ! test $PATH_TO_CVS_SRC || ! test $VERSION || ! test $RELEASE ; then
    usage
fi

if ! test -d $PATH_TO_CVS_SRC ; then
    echo "Error: Can't find path to cvs source directory"
    echo ""
    usage
fi

if test $4 ; then
    case $4 in
        "-p") PICTURES=0
        ;;
        "en") LANGUAGE=en
              ARCHIVE_DIR="doc-admin/en"
        ;;
        "de") LANGUAGE=de
              ARCHIVE_DIR="doc-admin/de"
    esac
fi

if test $5 ; then
    case $5 in
        "-p") PICTURES=0
        ;;
        "en") LANGUAGE=en
              ARCHIVE_DIR="doc-admin/en"
        ;;
        "de") LANGUAGE=de
              ARCHIVE_DIR="doc-admin/de"
    esac
fi
# --
echo "auto_build.sh 1.0"
echo ""
echo "  Build archives of the admin manual that contain the xml files and/or the pictures"
echo "  and/or the scripts for all or a specific language"
echo ""
echo "Copyright (c) 2002-2006 Martin Edenhofer <martin@otrs.org>"
echo ""
# --
# Temporary directories
# --
rm -rf $PACKAGE_DEST_DIR || exit 1
mkdir $PACKAGE_DEST_DIR || exit 1

# --
# build
# --
rm -rf $PACKAGE_BUILD_DIR || exit 1
mkdir -p $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ || exit 1

if [ $LANGUAGE = "all" ] ; then
    cp -a $PATH_TO_CVS_SRC/* $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ || exit 1
else
    cp -a $PATH_TO_CVS_SRC/$LANGUAGE/* $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ || exit 1
fi

# --
# cleanup
# --
cd $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ || exit 1
# remove CVS dirs
find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name CVS | xargs rm -rf || exit 1
# remove swap stuff
find -name ".#*" | xargs rm -rf
# remove .cvs ignore files
find -name ".cvsignore" | xargs rm -rf
# remove pictures if -p was specified
if [ $PICTURES = 0 ] ; then
    find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name screenshots | xargs rm -rf || exit 1
    find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name images | xargs rm -rf || exit 1
fi

# --
# create tar
# --
cd $PACKAGE_BUILD_DIR/ || exit 1
SOURCE_LOCATION=./$PACKAGE-$LANGUAGE-$VERSION-$RELEASE.tar.gz
tar -czf $SOURCE_LOCATION $ARCHIVE_DIR/ || exit 1
cp $SOURCE_LOCATION $PACKAGE_DEST_DIR/

# --
# create bzip2
# --
cd $PACKAGE_BUILD_DIR/ || exit 1
SOURCE_LOCATION=./$PACKAGE-$LANGUAGE-$VERSION-$RELEASE.tar.bz2
tar -cjf $SOURCE_LOCATION $ARCHIVE_DIR/ || exit 1
cp $SOURCE_LOCATION $PACKAGE_DEST_DIR/

# --
# stats
# --
echo "-----------------------------------------------------------------";
echo -n "Source code lines (*.sh) : "
find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name *.sh | xargs cat | wc -l
echo -n "Source code lines (*.pl) : "
find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name *.pl | xargs cat | wc -l
echo -n "Source code lines (*.pm) : "
find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name *.pm | xargs cat | wc -l
echo -n "Source code lines (*.xml): "
find $PACKAGE_BUILD_DIR/$ARCHIVE_DIR/ -name *.xml | xargs cat | wc -l
echo "-----------------------------------------------------------------";
echo "The tar.gz an tar.bz2 files are in $PACKAGE_DEST_DIR";
cd $PACKAGE_DEST_DIR
find . -name "*$PACKAGE*" | xargs ls -lo
echo "-----------------------------------------------------------------";
if which md5sum >> /dev/null; then
    echo "MD5 message digest (128-bit) checksums";
    find . -name "*$PACKAGE*" | xargs md5sum
else
    echo "No md5sum found in \$PATH!"
fi
# --
# cleanup
# --
rm -rf $PACKAGE_BUILD_DIR
rm -rf $PACKAGE_TMP_SPEC

exit 0
