#!/bin/sh

# ******************************************************************
#      Author: Chad Elliott
#        Date: 8/13/2009
# Description: Create an MPC rpm based on the current version number.
#         $Id$
# ******************************************************************

## First find out where this script is located
if [ "$0" != "`basename $0`" ]; then
  if [ "`echo $0 | cut -c1`" = "/" ]; then
    loc="`dirname $0`"
  else
    loc="`pwd`/`dirname $0`"
  fi
else
  ## Do my own 'which' here
  loc="."
  for i in `echo $PATH | tr ':' '\012'`; do
    if [ -x "$i/$0" -a ! -d "$i/$0" ]; then
      loc="$i"
      break
    fi
  done
fi

## Now, get back to where the main MPC script is located
while [ ! -x $loc/mpc.pl ]; do
  loc=`dirname $loc`
done

## Save the MPC version
VERSION=`$loc/mpc.pl --version | sed 's/.*v//'`

## This is where we'll create the spec file and do the work
WDIR=/tmp/mpc.$$

## This is the directory name that RPM expects
MDIR=MPC-$VERSION

## This corresponds to BuildRoot in MPC.spec
BDIR=/tmp/mpc

## The directory where RPM
if [ -x /usr/src/redhat ]; then
  RPMLOC=/usr/src/redhat
else
  RPMLOC=/usr/src/packages
fi

## Create our working directory and make the spec file
mkdir -p $WDIR
cd $WDIR
sed "s/VERSION/$VERSION/" $loc/rpm/MPC.spec > MPC.spec

## Make a copy of the original MPC source to the new directory
mkdir -p $MDIR/usr/lib/MPC
cd $loc
tar --exclude=.svn -cf - . | (cd $WDIR/$MDIR/usr/lib/MPC; tar -xf -)

## Create the build source tar.bz2
cd $WDIR
tar cf $RPMLOC/SOURCES/$MDIR.tar $MDIR
bzip2 -9f $RPMLOC/SOURCES/$MDIR.tar

## Perform the RPM creation step
rm -rf $BDIR
mkdir -p $BDIR
rpmbuild -bb MPC.spec

## Clean everything up
cd ..
rm -rf $WDIR $BDIR