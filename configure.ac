dnl Process this file with autoconf to produce a configure script.
dnl
dnl There are a couple of environment defined variables which this script
dnl makes use of in addition to the standard CFLAGS/LDFLAGS/etc. These are:
dnl
dnl RELEASE_TAG        - Debian release tag which is put to debian/changelog
dnl SNAPSHOT_VERSION   - snapshot version to add to version number
dnl SOURCE_REVISION    - Revision of the source-tree, will added to the version string
dnl
AC_INIT(src/log.cc)
m4_include(ax_cxx_compile_stdcxx_11.m4)

dnl ***************************************************************************
dnl Definitions

PACKAGE=libzorpll
VERSION=`cat $srcdir/VERSION`

dnl ***************************************************************************
dnl Dependencies

LIBGLIB_MIN_VERSION=2.32.0
OPENSSL_MIN_VERSION=1.0.1

dnl ***************************************************************************
dnl Initial setup

# We want an absolute path to the source-dir.
case "$srcdir" in
    /*)
        top_srcdir=$srcdir
        ;;
    *)
        oldsrcdir="$srcdir"
        top_srcdir="`cd \"$srcdir\"; pwd`"
        ;;
esac

if test -r $srcdir/dist.conf; then
	# read defaults, dist.conf does not change
	# values for parameters that are already set
	. $srcdir/dist.conf
fi


AC_CONFIG_MACRO_DIR([m4])

if test -n "$SNAPSHOT_VERSION"; then
        VERSION=$VERSION+$SNAPSHOT_VERSION
fi

if test -z "$RELEASE_TAG"; then
	RELEASE_TAG=zorp30dbg
fi

if test -z "$libexecdir" || test "x${libexecdir}" = "xNONE"; then
        libexecdir=${libdir}/libzorpll
fi

AM_INIT_AUTOMAKE($PACKAGE, $VERSION, no-define)
m4_ifdef([AM_SILENT_RULES],[AM_SILENT_RULES([yes])])
ZORPLIBLL_VERSION=$VERSION

AM_CONFIG_HEADER(src/zorp/zorplibconfig.h)

dnl check for arguments
AC_ARG_ENABLE(debug,
              [  --enable-debug       Enable debug information & messages (default: no)],,
              enable_debug=no)

AC_ARG_ENABLE(trace,
              [  --enable-trace       Enable trace information & messages (default: no)],,
              enable_trace=no)

AC_ARG_ENABLE(mem-trace,
              [  --enable-mem-trace   Enable memory trace (default: no)],,
              enable_mem_trace=no)

AC_ARG_ENABLE(caps,
              [  --enable-caps        Enable using POSIX 1003.e capabilities (default: autodetect)],,
              enable_caps=auto)

AC_ARG_ENABLE(stackdump,
              [  --enable-stackdump   Enable stackdump when a fatal signal is encountered (default: auto)],,
              enable_stackdump=auto)

AC_ARG_ENABLE(ssl-engine,
              [  --enable-ssl-engine   Enable OpenSSL engine support (default: auto)],,
              enable_ssl_engine=auto)

AC_ARG_ENABLE(tos,
              [  --enable-tos          Enable ToS manipulation routines (default: auto)],,
	      enable_tos=auto)

dnl ***************************************************************************
dnl Argument processing which might affect detection

if test "x$enable_debug" = "xyes"; then
  CFLAGS="$CFLAGS -O0"
else
  CFLAGS="$CFLAGS -O2"
fi

dnl Checks for programs.
AC_PROG_CC
AC_PROG_CXX
AX_CXX_COMPILE_STDCXX_11(noext)
AC_PROG_CPP
AC_PROG_CXXCPP

AC_LANG_PUSH([C++])
AC_COMPILE_IFELSE([AC_LANG_SOURCE(
  [[template <typename T>
    struct check {
      static_assert(sizeof(int) <= sizeof(T), "not big enough");
    };

    typedef check<check<bool>> right_angle_brackets;

    int a;
    decltype(a) b;

    typedef check<int> check_type;
    check_type c;
    check_type&& cr = static_cast<check_type&&>(c);]])],,
  AC_MSG_FAILURE(['$CXX $CXXFLAGS' does not accept full ISO C++11]))

AM_PROG_LIBTOOL

dnl ***************************************************************************
dnl Checks for header files.

AC_HEADER_DIRENT
AC_HEADER_STDC
AC_CHECK_HEADERS(fcntl.h sys/ioctl.h sys/time.h syslog.h unistd.h sys/capability.h dlfcn.h crypt.h pwd.h grp.h sys/prctl.h sys/resource.h)

dnl locating zlib1g headers
AC_CHECK_HEADER(zlib.h,,AC_MSG_ERROR([You don't seem to have zlib1g-dev installed]))

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_SIZE_T
AC_TYPE_UID_T
AC_STRUCT_TM

PKG_CHECK_MODULES(OPENSSL, openssl >= $OPENSSL_MIN_VERSION,,
        AC_MSG_ERROR(Cannot find OpenSSL library version >= $OPENSSL_MIN_VERSION: is pkg-config in path?))

save_CXXFLAGS=$CXXFLAGS
CXXFLAGS="$CXXFLAGS $OPENSSL_CFLAGS"
AC_CHECK_HEADER(openssl/ssl.h, [], [AC_MSG_ERROR([OpenSSL header file <openssl/ssl.h> is missing])])
CXXFLAGS=$save_CXXFLAGS

if test "x$ac_cv_header_openssl_des_h" = "xno"; then
	AC_ERROR(OpenSSL headers required)
fi

AC_CACHE_CHECK(for PR_SET_KEEPCAPS, blb_cv_keepcaps,
  [AC_EGREP_CPP(PR_SET_KEEPCAPS, 
[
#include <sys/prctl.h>

PR_SET_KEEPCAPS
],
  blb_cv_keepcaps=no,
  blb_cv_keepcaps=yes)])

if test "x$blb_cv_keepcaps" = "xyes"; then
	AC_DEFINE(HAVE_PR_SET_KEEPCAPS, 1, [have PR_SET_KEEPCAPS])
fi

AC_CACHE_CHECK(for SOL_IP, blb_cv_sol_ip,
  [AC_EGREP_CPP(SOL_IP, 
[
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

SOL_IP
],
  blb_cv_sol_ip=no,
  blb_cv_sol_ip=yes)])

if test "x$blb_cv_sol_ip" = "xyes"; then
	AC_DEFINE(HAVE_SOL_IP, 1, [have SOL_IP])
fi

AC_CACHE_CHECK(for IP_PKTOPTIONS, blb_cv_ip_pktoptions,
  [AC_EGREP_CPP(IP_PKTOPTIONS, 
[
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

IP_PKTOPTIONS
],
  blb_cv_ip_pktoptions=no,
  blb_cv_ip_pktoptions=yes)])

if test "x$blb_cv_ip_pktoptions" = "xyes"; then
	AC_DEFINE(HAVE_PKTOPTIONS, 1, [have IP_PKTOPTIONS])
fi

AC_CACHE_CHECK(for IP_RECVTOS, blb_cv_ip_recvtos,
  [AC_EGREP_CPP(IP_RECVTOS, 
[
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

IP_RECVTOS
],
  blb_cv_ip_recvtos=no,
  blb_cv_ip_recvtos=yes)])

if test "x$blb_cv_ip_recvtos" = "xyes"; then
	AC_DEFINE(HAVE_IP_RECVTOS, 1, [have IP_RECVTOS])
fi

dnl ***************************************************************************
dnl Checks for library functions.

AC_FUNC_ALLOCA
AC_PROG_GCC_TRADITIONAL
AC_FUNC_MEMCMP
AC_FUNC_STRFTIME

AC_CHECK_LIB(cap, cap_set_proc)
AC_CHECK_LIB(pthread, pthread_create)
AC_CHECK_LIB(resolv, inet_aton)
AC_CHECK_LIB(socket, socket)
if test "x$ac_cv_header_crypt_h" = "xyes"; then
	AC_CHECK_LIB(crypt, crypt)
fi
AC_CHECK_LIB(z, gzread)
AC_CHECK_FUNCS(socket strtol strtoul strlcpy backtrace prctl)
AC_CHECK_FUNCS(inet_aton inet_addr localtime_r)
if test "x$ac_cv_header_crypt_h" = "xyes"; then
	AC_CHECK_FUNCS(crypt)
fi

PKG_CHECK_MODULES(GLIB, glib-2.0 >= $LIBGLIB_MIN_VERSION,,
	AC_MSG_ERROR(Cannot find GLib library version >= $LIBGLIB_MIN_VERSION: is pkg-config in path?))

PKG_CHECK_MODULES(GTHREAD, gthread-2.0 >= $LIBGLIB_MIN_VERSION,,
	AC_MSG_ERROR(Cannot find Gthread library version >= $LIBGLIB_MIN_VERSION: is pkg-config in path?))

dnl AM_PATH_GLIB_2_0($GLIB_MIN_VERSION,,
dnl    AC_MSG_ERROR(Cannot find GLIB version >= $GLIB_MIN_VERSION: is pkg-config in path?), gthread)

dnl ***************************************************************************
dnl Misc checks

dnl enable support for files over 2GB
AC_SYS_LARGEFILE

os=`uname -s`
if test "x$os" = "xLinux"; then
	AC_DEFINE(HAVE_BUGGY_SYSLOG_IN_LIBC, 1, [have buggy syslog() in libc])
	AC_DEFINE(HAVE_MD5_CRYPT, 1, [Have transparent md5 support in crypt()])
fi


if test "x$enable_caps" = "xauto" ; then
	AC_MSG_CHECKING(whether to enable POSIX 1003.1e capability support)
        if test "x$ac_cv_header_sys_capability_h" = "xyes" -a "x$ac_cv_lib_cap_cap_set_proc" = "xyes"; then
                AC_MSG_RESULT(yes)
                enable_caps=yes
        else
                AC_MSG_RESULT(no)
		enable_caps=no
        fi
fi

if test "x$enable_stackdump" = "xauto"; then
        enable_stackdump=no
        AC_MSG_CHECKING(whether to enable stack dumping (only in i386 Linux))
	proc=`uname -m | sed -e 's/i.86/i386/'`
	os=`uname -s`
        if test "x$proc" = "xi386"; then
                if test "x$os" = "xLinux"; then
                        AC_MSG_RESULT(yes)
                        enable_stackdump=yes
                else
                        AC_MSG_RESULT(no)
                fi
        else
                AC_MSG_RESULT(no)
        fi
fi

save_LIBS="$LIBS"
LIBS="$LIBS $OPENSSL_LIBS"
if test "x$enable_ssl_engine" = "xauto"; then
	AC_CHECK_FUNC(ENGINE_by_id)
	AC_MSG_CHECKING(whether to enable SSL crypto engine support)
	if test "x$ac_cv_func_ENGINE_by_id" = "xyes"; then
		AC_MSG_RESULT(yes)
		enable_ssl_engine=yes
	else
		AC_MSG_RESULT(no)
		enable_ssl_engine=no
	fi
fi
LIBS=$save_LIBS

if test "x$enable_tos" = "xauto"; then
	AC_MSG_CHECKING(whether to enable ToS manipulation support)
	if test "x$blb_cv_sol_ip" = "xyes" -a "x$blb_cv_ip_pktoptions" = "xyes" -a "x$blb_cv_ip_recvtos" = "xyes"; then
		AC_MSG_RESULT(yes)
		enable_tos=yes
	else
		AC_MSG_RESULT(no)
		enable_tos=no
	fi
fi



dnl ***************************************************************************
dnl Export detected settings to Makefiles and Zorp

enable_value()
{
        if test "x$1" = "xyes" ; then
                echo 1
        else
                echo 0
        fi
}

LIBZORPLL_COMPAT_VERSION="`echo $VERSION | cut -d '.' -f 1-3`"
dnl Library versioning, the resulting shared object is named:
dnl 	libzorpll-<RELEASE>.so.<AGE>
dnl 
VERSION_NOSNAPSHOT="`echo $VERSION | cut -d '+' -f 1`"

VERSION_MAJOR=`echo $VERSION_NOSNAPSHOT |  cut -d '.' -f 1`
VERSION_MINOR=`echo $VERSION_NOSNAPSHOT |  cut -d '.' -f 2`
VERSION_COMPAT=`echo $VERSION_NOSNAPSHOT |  cut -d '.' -f 3`
VERSION_AGE=`echo $VERSION_NOSNAPSHOT |  cut -d '.' -f 4`

LIBZORPLL_LT_RELEASE="$VERSION_MAJOR.$VERSION_MINOR"
LIBZORPLL_LT_CURRENT=$(( $VERSION_COMPAT + $VERSION_AGE ))
LIBZORPLL_LT_COMPAT_BRANCH="$VERSION_MAJOR.$VERSION_MINOR-$VERSION_COMPAT"
LIBZORPLL_LT_COMPAT_PL="$VERSION_COMPAT"
LIBZORPLL_LT_AGE="$VERSION_AGE"

ZORPLIBLL_WIN_VERSION="$VERSION_MAJOR,$VERSION_MINOR,$VERSION_COMPAT,$VERSION_AGE"

set -x 
if test -z "${exec_prefix}" -o "x${exec_prefix}" = "xNONE"; then
        exec_prefix="${prefix}"
fi

set -x
expand_recursive()
{
  expd=`eval echo $1`

  if test "$1" = "$expd";
  then 
    echo $expd;
  else
    expand_recursive $expd
  fi;
} 

libexecdir="`expand_recursive ${libexecdir}`"
sysconfdir="`expand_recursive ${sysconfdir}`"

ZORPLIB_PIDFILE_DIR="`eval echo ${localstatedir}/run/zorp`"
ZORPLIB_TEMP_DIR="`eval echo ${localstatedir}/lib/zorp/tmp`"

set +x

AC_DEFINE_UNQUOTED(ZORPLIBLL_PACKAGE, "$PACKAGE", [Zorp low level library package name] )
AC_DEFINE_UNQUOTED(ZORPLIBLL_VERSION, "$ZORPLIBLL_VERSION", [Zorp low level library version] )
AC_DEFINE_UNQUOTED(ZORPLIBLL_REVISION, "$SOURCE_REVISION", [Zorp low level library, source revision])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_DEBUG, `enable_value $enable_debug`, [enable debug])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_TRACE, `enable_value $enable_trace`, [enable trace])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_MEM_TRACE, `enable_value $enable_mem_trace`, [enable memtrace])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_CAPS, `enable_value $enable_caps`, [enable caps])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_SSL_ENGINE, `enable_value $enable_ssl_engine`, [enable ssl engine])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_STACKDUMP, `enable_value $enable_stackdump`, [enable stack dump])
AC_DEFINE_UNQUOTED(ZORPLIB_ENABLE_TOS, `enable_value $enable_tos`, [enable ToS manipulation])
AC_DEFINE_UNQUOTED(ZORPLIB_PIDFILE_DIR, "$ZORPLIB_PIDFILE_DIR", [default PID file directory])
AC_DEFINE_UNQUOTED(ZORPLIB_LIBEXECDIR, "`eval echo ${libexecdir}`", [libexecdir])
AC_DEFINE_UNQUOTED(ZORPLIB_COMPAT_BRANCH,"`eval echo ${LIBZORPLL_LT_COMPAT_BRANCH}`", [Binary compatibility version])
AC_DEFINE_UNQUOTED(ZORPLIB_TEMP_DIR, "$ZORPLIB_TEMP_DIR", [default temporary directory])

cat <<EOF


Compile time options:
---------------------
debug: $enable_debug
trace: $enable_trace
mem_trace: $enable_mem_trace
caps: $enable_caps
stackdump: $enable_stackdump
ssl_engine: $enable_ssl_engine
tos: $enable_tos

EOF

CFLAGS="$CFLAGS -D_GNU_SOURCE -Wall -Wshadow -W -Wstrict-prototypes -Werror-implicit-function-declaration -Wpointer-arith -g"

DEPS_CXXFLAGS="$CXXFLAGS $GLIB_CFLAGS $GTHREAD_CFLAGS $OPENSSL_CFLAGS"
CXXFLAGS="-I$top_srcdir/lib -I$top_srcdir $DEPS_CXXFLAGS"
OPENSSL_CPPFLAGS="$OPENSSL_CFLAGS"
DEPS_LIBS="$LIBS $GLIB_LIBS $GTHREAD_LIBS $OPENSSL_LIBS"
LIBS="$ZORP_LIBS $DEPS_LIBS"

AC_SUBST(SNAPSHOT_VERSION)
AC_SUBST(RELEASE_TAG)
AC_SUBST(SOURCE_REVISION)
AC_SUBST(ZORPLIBLL_VERSION)
AC_SUBST(ZORPLIBLL_WIN_VERSION)

AC_SUBST(LIBZORPLL_LT_RELEASE)
AC_SUBST(LIBZORPLL_LT_CURRENT)
AC_SUBST(LIBZORPLL_LT_COMPAT_BRANCH)
AC_SUBST(LIBZORPLL_LT_COMPAT_PL)
AC_SUBST(LIBZORPLL_LT_AGE)

AC_SUBST(OPENSSL_CFLAGS)
AC_SUBST(OPENSSL_CPPFLAGS)
AC_SUBST(DEPS_CXXFLAGS)
AC_SUBST(DEPS_LIBS)
AC_SUBST(ZORP_LIBS)

AC_SUBST(ZORPLIB_PIDFILE_DIR)
AC_SUBST(ZORPLIB_TEMP_DIR)

AC_OUTPUT(
Makefile
dist.conf
src/libzorpll.rc
src/Makefile
src/zorp/Makefile
scripts/Makefile
scripts/failure_notify
src/zorp/zorplibconfig.h-win32
tests/Makefile
zorplibll.pc
)
