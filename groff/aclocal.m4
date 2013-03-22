# Autoconf macros for groff.
# Copyright (C) 1989-1995, 2001, 2002, 2003 Free Software Foundation, Inc.
# 
# This file is part of groff.
# 
# groff is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2, or (at your option) any later
# version.
# 
# groff is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
# 
# You should have received a copy of the GNU General Public License along
# with groff; see the file COPYING.  If not, write to the Free Software
# Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

AC_DEFUN([GROFF_PRINT],
  [if test -z "$PSPRINT"; then
     AC_CHECK_PROGS([LPR], [lpr])
     AC_CHECK_PROGS([LP], [lp])
     if test -n "$LPR" && test -n "$LP"; then
       # HP-UX provides an lpr command that emulates lpr using lp,
       # but it doesn't have lpq; in this case we want to use lp
       # rather than lpr.
       AC_CHECK_PROGS([LPQ], [lpq])
       test -n "$LPQ" || LPR=
     fi
     if test -n "$LPR"; then
       PSPRINT="$LPR"
     elif test -n "$LP"; then
       PSPRINT="$LP"
     fi
   fi
   AC_SUBST([PSPRINT])
   AC_MSG_CHECKING([for command to use for printing PostScript files])
   AC_MSG_RESULT([$PSPRINT])

   # Figure out DVIPRINT from PSPRINT.
   AC_MSG_CHECKING([for command to use for printing dvi files])
   if test -n "$PSPRINT" && test -z "$DVIPRINT"; then
     if test "X$PSPRINT" = "Xlpr"; then
       DVIPRINT="lpr -d"
     else
       DVIPRINT="$PSPRINT"
     fi
   fi
   AC_SUBST([DVIPRINT])
   AC_MSG_RESULT([$DVIPRINT])])

# Bison generated parsers have problems with C++ compilers other than g++.
# So byacc is preferred over bison.

AC_DEFUN([GROFF_PROG_YACC],
  [AC_CHECK_PROGS([YACC], [byacc 'bison -y'], [yacc])])

# The following programs are needed for grohtml.

AC_DEFUN([GROFF_HTML_PROGRAMS],
  [make_html=html
   make_install_html=install_html

   missing=
   AC_FOREACH([groff_prog],
     [pnmcut pnmcrop pnmtopng psselect pnmtops gs],
     [AC_CHECK_PROG(groff_prog, groff_prog, [found], [missing])
      if test $[]groff_prog = missing; then
	missing="$missing groff_prog"
      fi;])

   if test -n "$missing"; then
     cnt=0
     for i in $missing
     do
       cnt=`expr $cnt + 1`
       eval "prog$cnt=$i"
     done
     plural="s"
     case $cnt in
     1)
       plural=""
       progs="\`$prog1'" ;;
     2)
       progs="\`$prog1' and \`$prog2'" ;;
     3)
       progs="\`$prog1', \`$prog2', and \`$prog3'" ;;
     4)
       progs="\`$prog1', \`$prog2', \`$prog3', and \`$prog4'" ;;
     5)
       progs="\`$prog1', \`$prog2', \`$prog3', \`$prog4', and \`$prog5'" ;;
     6)
       progs="\`$prog1', \`$prog2', \`$prog3', \`$prog4', \`$prog5', and \`$prog6'" ;;
     esac

     make_html=
     make_install_html=

     AC_MSG_WARN([

  The program$plural
    $progs
  can't be found in the path, thus the HTML backend of groff (grohtml)
  won't work properly.  Consequently, no documentation in HTML format
  is built and installed.
     ])
   fi

   AC_SUBST([make_html])
   AC_SUBST([make_install_html])])

# Check whether pnmtops can handle the -nosetpage option.

AC_DEFUN([GROFF_PNMTOPS_NOSETPAGE],
  [AC_MSG_CHECKING([whether pnmtops can handle the -nosetpage option])
   if echo P2 2 2 255 0 1 2 0 | pnmtops -nosetpage > /dev/null 2>&1 ; then
     AC_MSG_RESULT([yes])
     pnmtops_nosetpage="pnmtops -nosetpage"
   else
     AC_MSG_RESULT([no])
     pnmtops_nosetpage="pnmtops"
   fi
   AC_SUBST([pnmtops_nosetpage])])

# GROFF_CSH_HACK(if hack present, if not present)

AC_DEFUN([GROFF_CSH_HACK],
  [AC_MSG_CHECKING([for csh hash hack])

cat <<EOF >conftest.sh
#!/bin/sh
true || exit 0
export PATH || exit 0
exit 1
EOF

   chmod +x conftest.sh
   if echo ./conftest.sh | (csh >/dev/null 2>&1) >/dev/null 2>&1; then
     AC_MSG_RESULT([yes])
     $1
   else
     AC_MSG_RESULT([no])
     $2
   fi
   rm -f conftest.sh])

# From udodo!hans@relay.NL.net (Hans Zuidam)

AC_DEFUN([GROFF_ISC_SYSV3],
  [AC_MSG_CHECKING([for ISC 3.x or 4.x])
   if grep ['[34]\.'] /usr/options/cb.name >/dev/null 2>&1
   then
     AC_MSG_RESULT([yes])
     AC_DEFINE([_SYSV3], [1], [Define if you have ISC 3.x or 4.x.])
   else
     AC_MSG_RESULT([no])
   fi])

AC_DEFUN([GROFF_POSIX],
  [AC_MSG_CHECKING([whether -D_POSIX_SOURCE is necessary])
   AC_LANG_PUSH([C++])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdio.h>
extern "C" { void fileno(int); }

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([_POSIX_SOURCE], [1],
	[Define if -D_POSIX_SOURCE is necessary.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

# srand() of SunOS 4.1.3 has return type int instead of void

AC_DEFUN([GROFF_SRAND],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for return type of srand])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdlib.h>
extern "C" { void srand(unsigned int); }

       ]])
     ],
     [AC_MSG_RESULT([void])
      AC_DEFINE([RET_TYPE_SRAND_IS_VOID], [1],
	[Define if srand() returns void not int.])],
     [AC_MSG_RESULT([int])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_SYS_NERR],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for sys_nerr in <errno.h>, <stdio.h>, or <stdlib.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

       ]],
       [[

int k;
k = sys_nerr;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_SYS_NERR], [1],
	[Define if you have sys_nerr in <errno.h>, <stdio.h>, or <stdio.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_SYS_ERRLIST],
  [AC_MSG_CHECKING([for sys_errlist[] in <errno.h>, <stdio.h>, or <stdlib.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

       ]],
       [[

int k;
k = (int)sys_errlist[0];

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_SYS_ERRLIST], [1],
	[Define if you have sys_errlist in <errno.h>, <stdio.h>, or <stdlib.h>.])],
     [AC_MSG_RESULT([no])])])

AC_DEFUN([GROFF_OSFCN_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <osfcn.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <osfcn.h>

       ]],
       [[

read(0, 0, 0);
open(0, 0);

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_CC_OSFCN_H], [1],
	[Define if you have a C++ <osfcn.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_LIMITS_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <limits.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <limits.h>

       ]],
       [[

int x = INT_MIN;
int y = INT_MAX;
int z = UCHAR_MAX;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_CC_LIMITS_H], [1],
	[Define if you have a C++ <limits.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_STDINT_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([C++ <stdint.h>])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdint.h>

       ]],
       [[

uint32_t x;
int32_t y;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_CC_STDINT_H], [1],
	[Define if you have a C++ <stdint.h>.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_TIME_T],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for declaration of time_t])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <time.h>

       ]],
       [[

time_t t = time(0);
struct tm *p = localtime(&t);

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_DEFINE([LONG_FOR_TIME_T], [1],
	[Define if localtime() takes a long * not a time_t *.])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_STRUCT_EXCEPTION],
  [AC_MSG_CHECKING([struct exception])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <math.h>

       ]],
       [[

struct exception e;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_STRUCT_EXCEPTION], [1],
	[Define if <math.h> defines struct exception.])],
     [AC_MSG_RESULT([no])])])

AC_DEFUN([GROFF_ARRAY_DELETE],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([whether ANSI array delete syntax is supported])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM(, [[

char *p = new char[5];
delete [] p;

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_DEFINE([ARRAY_DELETE_NEEDS_SIZE], [1],
	[Define if your C++ doesn't understand `delete []'.])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_TRADITIONAL_CPP],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([traditional preprocessor])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#define name2(a, b) a/**/b

       ]],
       [[

int name2(foo, bar);

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([TRADITIONAL_CPP], [1],
	[Define if your C++ compiler uses a traditional (Reiser) preprocessor.])],
     [AC_MSG_RESULT([no])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_WCOREFLAG],
  [AC_MSG_CHECKING([w_coredump])
   AC_RUN_IFELSE([
       AC_LANG_PROGRAM([[

#include <sys/types.h>
#include <sys/wait.h>

       ]],
       [[

main()
{
#ifdef WCOREFLAG
  exit(1);
#else
  int i = 0;
  ((union wait *)&i)->w_coredump = 1;
  exit(i != 0200);
#endif
}

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE(WCOREFLAG, 0200,
	[Define if the 0200 bit of the status returned by wait() indicates
	 whether a core image was produced for a process that was terminated
	 by a signal.])],
     [AC_MSG_RESULT([no])],
     [AC_MSG_RESULT([no])])])

AC_DEFUN([GROFF_BROKEN_SPOOLER_FLAGS],
  [AC_MSG_CHECKING([default value for grops -b option])
   test -n "${BROKEN_SPOOLER_FLAGS}" || BROKEN_SPOOLER_FLAGS=0
   AC_MSG_RESULT([$BROKEN_SPOOLER_FLAGS])
   AC_SUBST([BROKEN_SPOOLER_FLAGS])])

AC_DEFUN([GROFF_PAGE],
  [AC_MSG_CHECKING([default paper size])
   groff_prefix=$prefix
   test "x$prefix" = xNONE && groff_prefix=$ac_default_prefix
   if test -z "$PAGE"; then
     descfile=
     if test -r $groff_prefix/share/groff/font/devps/DESC; then
       descfile=$groff_prefix/share/groff/font/devps/DESC
     elif test -r $groff_prefix/lib/groff/font/devps/DESC; then
       descfile=$groff_prefix/lib/groff/font/devps/DESC
     else
       for f in $groff_prefix/share/groff/*/font/devps/DESC; do
	 if test -r $f; then
	   descfile=$f
	   break
	 fi
       done
     fi

     if test -n "$descfile"; then
       if grep ['^paperlength[	 ]\+841890'] $descfile >/dev/null 2>&1; then
	 PAGE=A4
       elif grep ['^papersize[	 ]\+[aA]4'] $descfile >/dev/null 2>&1; then
	 PAGE=A4
       fi
     fi
   fi

   if test -z "$PAGE"; then
     dom=`awk '([$]1 == "dom" || [$]1 == "search") { print [$]2; exit}' \
	 /etc/resolv.conf 2>/dev/null`
     if test -z "$dom"; then
       dom=`(domainname) 2>/dev/null | tr -d '+'`
       if test -z "$dom" \
	  || test "$dom" = '(none)'; then
	 dom=`(hostname) 2>/dev/null | grep '\.'`
       fi
     fi
     # If the top-level domain is two letters and it's not `us' or `ca'
     # then they probably use A4 paper.
     case "$dom" in
     [*.[Uu][Ss]|*.[Cc][Aa])]
       ;;
     [*.[A-Za-z][A-Za-z])]
       PAGE=A4 ;;
     esac
   fi

   test -n "$PAGE" || PAGE=letter
   if test "x$PAGE" = "xA4"; then
     AC_DEFINE([PAGEA4], [1],
       [Define if the printer's page size is A4.])
   fi
   AC_MSG_RESULT([$PAGE])
   AC_SUBST([PAGE])])

AC_DEFUN([GROFF_CXX_CHECK],
  [AC_REQUIRE([AC_PROG_CXX])
   AC_LANG_PUSH([C++])
   if test "$cross_compiling" = no; then
     AC_MSG_CHECKING([that C++ compiler can compile simple program])
   fi
   AC_RUN_IFELSE([
       AC_LANG_SOURCE([[

int main() {
  return 0;
}

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([a working C++ compiler is required])],
     [:])

   if test "$cross_compiling" = no; then
     AC_MSG_CHECKING([that C++ static constructors and destructors are called])
   fi
   AC_RUN_IFELSE([
       AC_LANG_SOURCE([[

extern "C" {
  void _exit(int);
}

int i;
struct A {
  char dummy;
  A() { i = 1; }
  ~A() { if (i == 1) _exit(0); }
};

A a;

int main()
{
  return 1;
}

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([a working C++ compiler is required])],
     [:])

   AC_MSG_CHECKING([that header files support C++])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdio.h>

       ]],
       [[

fopen(0, 0);

       ]])
     ],
     [AC_MSG_RESULT([yes])],
     [AC_MSG_RESULT([no])
      AC_MSG_ERROR([header files do not support C++
		   (if you are using a version of gcc/g++ earlier than 2.5,
		   you should install libg++)])])
   AC_LANG_POP([C++])])

AC_DEFUN([GROFF_TMAC],
  [AC_MSG_CHECKING([for prefix of system macro packages])
   sys_tmac_prefix=
   sys_tmac_file_prefix=
   for d in /usr/share/lib/tmac /usr/lib/tmac; do
     for t in "" tmac.; do
       for m in an s m; do
	 f=$d/$t$m
	 if test -z "$sys_tmac_prefix" \
	    && test -f $f \
	    && grep '^\.if' $f >/dev/null 2>&1; then
	   sys_tmac_prefix=$d/$t
	   sys_tmac_file_prefix=$t
	 fi
       done
     done
   done
   AC_MSG_RESULT([$sys_tmac_prefix])
   AC_SUBST([sys_tmac_prefix])

   AC_MSG_CHECKING([which system macro packages should be made available])
   tmac_wrap=
   if test "x$sys_tmac_file_prefix" = "xtmac."; then
     for f in $sys_tmac_prefix*; do
       suff=`echo $f | sed -e "s;$sys_tmac_prefix;;"`
       case "$suff" in
       e)
	 ;;
       *)
	 grep "Copyright.*Free Software Foundation" $f >/dev/null \
	      || tmac_wrap="$tmac_wrap $suff" ;;
       esac 
     done
   elif test -n "$sys_tmac_prefix"; then
     files=`echo $sys_tmac_prefix*`
     grep "\\.so" $files >conftest.sol
     for f in $files; do
       case "$f" in
       ${sys_tmac_prefix}e)
	 ;;
       *.me)
	 ;;
       */ms.*)
	 ;;
       *)
	 b=`basename $f`
	 if grep "\\.so.*/$b\$" conftest.sol >/dev/null \
	    || grep -l "Copyright.*Free Software Foundation" $f >/dev/null; then
	   :
	 else
	   suff=`echo $f | sed -e "s;$sys_tmac_prefix;;"`
	   case "$suff" in
	   tmac.*)
	     ;;
	   *)
	     tmac_wrap="$tmac_wrap $suff" ;;
	   esac
	 fi
       esac
     done
     rm -f conftest.sol
   fi
   AC_MSG_RESULT([$tmac_wrap])
   AC_SUBST([tmac_wrap])])

AC_DEFUN([GROFF_G],
  [AC_MSG_CHECKING([for existing troff installation])
   if test "x`(echo .tm '|n(.g' | tr '|' '\\\\' | troff -z -i 2>&1) 2>/dev/null`" = x0; then
     AC_MSG_RESULT([yes])
     g=g
   else
     AC_MSG_RESULT([no])
     g=
   fi
   AC_SUBST([g])])

# We need the path to install-sh to be absolute.

AC_DEFUN([GROFF_INSTALL_SH],
  [AC_REQUIRE([AC_CONFIG_AUX_DIR_DEFAULT])
   ac_dir=`cd $ac_aux_dir; pwd`
   ac_install_sh="$ac_dir/install-sh -c"])

# Test whether install-info is available.

AC_DEFUN([GROFF_INSTALL_INFO],
  [AC_CHECK_PROGS([INSTALL_INFO], [install-info], [:])])

# At least one UNIX system, Apple Macintosh Rhapsody 5.5,
# does not have -lm ...

AC_DEFUN([GROFF_LIBM],
  [AC_CHECK_LIB([m], [sin], [LIBM=-lm])
   AC_SUBST([LIBM])])

# ... while the MinGW implementation of GCC for Microsoft Win32
# does not seem to have -lc.

AC_DEFUN([GROFF_LIBC],
  [AC_CHECK_LIB([c], [main], [LIBC=-lc])
   AC_SUBST([LIBC])])

# Check for EBCDIC -- stolen from the OS390 Unix LYNX port

AC_DEFUN([GROFF_EBCDIC],
  [AC_MSG_CHECKING([whether character set is EBCDIC])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

/* Treat any failure as ASCII for compatibility with existing art.
   Use compile-time rather than run-time tests for cross-compiler
   tolerance. */
#if '0' != 240
make an error "Character set is not EBCDIC"
#endif

       ]])
     ],
     [groff_cv_ebcdic="yes"
      TTYDEVDIRS="font/devcp1047"
      AC_MSG_RESULT([yes])
      AC_DEFINE(IS_EBCDIC_HOST, 1,
	[Define if the host's encoding is EBCDIC.])],
     [groff_cv_ebcdic="no"
     TTYDEVDIRS="font/devascii font/devlatin1"
     OTHERDEVDIRS="font/devlj4 font/devlbp"
     AC_MSG_RESULT([no])])
   AC_SUBST([TTYDEVDIRS])
   AC_SUBST([OTHERDEVDIRS])])

# Check for OS/390 Unix.  We test for EBCDIC also -- the Linux port (with
# gcc) to OS/390 uses ASCII internally.

AC_DEFUN([GROFF_OS390],
  [if test "$groff_cv_ebcdic" = "yes"; then
     AC_MSG_CHECKING([for OS/390 Unix])
     case `uname` in
     OS/390)
       CFLAGS="$CFLAGS -D_ALL_SOURCE"
       AC_MSG_RESULT([yes]) ;;
     *)
       AC_MSG_RESULT([no]) ;;
     esac
   fi])

# Check whether we need a declaration for a function.
#
# Stolen from GNU bfd.

AC_DEFUN([GROFF_NEED_DECLARATION],
  [AC_MSG_CHECKING([whether $1 must be declared])
   AC_LANG_PUSH([C++])
   AC_CACHE_VAL([groff_cv_decl_needed_$1],
     [AC_COMPILE_IFELSE([
          AC_LANG_PROGRAM([[

#include <stdio.h>
#ifdef HAVE_STRING_H
#include <string.h>
#endif
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_MATH_H
#include <math.h>
#endif

	  ]],
	  [[

#ifndef $1
  char *p = (char *) $1;
#endif

	  ]])
      ],
      [groff_cv_decl_needed_$1=no],
      [groff_cv_decl_needed_$1=yes])])
   AC_MSG_RESULT([$groff_cv_decl_needed_$1])
   if test $groff_cv_decl_needed_$1 = yes; then
     AC_DEFINE([NEED_DECLARATION_]translit($1, [a-z], [A-Z]), [1],
       [Define if your C++ doesn't declare ]$1[().])
   fi
   AC_LANG_POP([C++])])

# If mkstemp() isn't available, use our own mkstemp.cpp file.

AC_DEFUN([GROFF_MKSTEMP],
  [AC_MSG_CHECKING([for mkstemp])
   AC_LANG_PUSH([C++])
   AC_LIBSOURCE([mkstemp.cpp])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

#include <stdlib.h>
#include <unistd.h>
int (*f) (char *);

       ]],
       [[

f = mkstemp;

       ]])
     ],
     [AC_MSG_RESULT([yes])
      AC_DEFINE([HAVE_MKSTEMP], [1], [Define if you have mkstemp().])],
     [AC_MSG_RESULT([no])
      _AC_LIBOBJ([mkstemp])])
   AC_LANG_POP([C++])])

# Test whether <inttypes.h> exists, doesn't clash with <sys/types.h>,
# and declares uintmax_t.  Taken from the fileutils package.

AC_DEFUN([GROFF_INTTYPES_H],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for inttypes.h])
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[

#include <sys/types.h>
#include <inttypes.h>

       ]],
       [[

uintmax_t i = (uintmax_t)-1;

       ]])
     ],
     [groff_cv_header_inttypes_h=yes],
     [groff_cv_header_inttypes_h=no])
   AC_MSG_RESULT([$groff_cv_header_inttypes_h])
   AC_LANG_POP([C++])])

# Test for working `unsigned long long'.  Taken from the fileutils package.

AC_DEFUN([GROFF_UNSIGNED_LONG_LONG],
  [AC_LANG_PUSH([C++])
   AC_MSG_CHECKING([for unsigned long long])
   AC_LINK_IFELSE([
       AC_LANG_PROGRAM([[

unsigned long long ull = 1;
int i = 63;
unsigned long long ullmax = (unsigned long long)-1;

       ]],
       [[

return ull << i | ull >> i | ullmax / ull | ullmax % ull;

       ]])
     ],
     [groff_cv_type_unsigned_long_long=yes],
     [groff_cv_type_unsigned_long_long=no])
   AC_MSG_RESULT([$groff_cv_type_unsigned_long_long])
   AC_LANG_POP([C++])])

# Define uintmax_t to `unsigned long' or `unsigned long long'
# if <inttypes.h> does not exist.  Taken from the fileutils package.

AC_DEFUN([GROFF_UINTMAX_T],
  [AC_REQUIRE([GROFF_INTTYPES_H])
   if test $groff_cv_header_inttypes_h = no; then
     AC_REQUIRE([GROFF_UNSIGNED_LONG_LONG])
     test $groff_cv_type_unsigned_long_long = yes \
	  && ac_type='unsigned long long' \
	  || ac_type='unsigned long'
     AC_DEFINE_UNQUOTED([uintmax_t], [$ac_type],
       [Define uintmax_t to `unsigned long' or `unsigned long long' if
	<inttypes.h> does not exist.])
   fi])

# Identify PATH_SEPARATOR character to use in GROFF_FONT_PATH and
# GROFF_TMAC_PATH which is appropriate for the target system (POSIX=':',
# MS-DOS/Win32=';').
#
# The logic to resolve this test is already encapsulated in
# `${srcdir}/src/include/nonposix.h'.

AC_DEFUN([GROFF_TARGET_PATH_SEPARATOR],
  [AC_MSG_CHECKING([separator character to use in groff search paths])
   cp ${srcdir}/src/include/nonposix.h conftest.h
   AC_COMPILE_IFELSE([
       AC_LANG_PROGRAM([[
        
#include <ctype.h>
#include "conftest.h"

       ]],
       [[

#if PATH_SEP_CHAR == ';'
make an error "Path separator is ';'"
#endif

       ]])
     ],
     [GROFF_PATH_SEPARATOR=":"],
     [GROFF_PATH_SEPARATOR=";"])
   AC_MSG_RESULT([$GROFF_PATH_SEPARATOR])
   AC_SUBST(GROFF_PATH_SEPARATOR)])
