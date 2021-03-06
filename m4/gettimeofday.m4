#serial 1

dnl From Jim Meyering.
dnl
dnl See if gettimeofday clobbers the static buffer that localtime uses
dnl for it's return value.  The gettimeofday function from Mac OS X 10.0.4,
dnl i.e. Darwin 1.3.7 has this problem.
dnl
dnl If it does, then arrange to use gettimeofday only via the wrapper
dnl function that works around the problem.

AC_DEFUN([AC_FUNC_GETTIMEOFDAY_CLOBBER],
[
 AC_REQUIRE([AC_HEADER_TIME])
 AC_CHECK_HEADERS(string.h stdlib.h)
 AC_CACHE_CHECK([whether gettimeofday clobbers localtime buffer],
  jm_cv_func_gettimeofday_clobber,
  [AC_TRY_RUN([
#include <stdio.h>
#if HAVE_STRING_H
# include <string.h>
#endif

#if TIME_WITH_SYS_TIME
# include <sys/time.h>
# include <time.h>
#else
# if HAVE_SYS_TIME_H
#  include <sys/time.h>
# else
#  include <time.h>
# endif
#endif

#if HAVE_STDLIB_H
# include <stdlib.h>
#endif

int
main ()
{
  time_t t = 0;
  struct tm *lt;
  struct tm saved_lt;
  struct timeval tv;
  lt = localtime (&t);
  saved_lt = *lt;
  gettimeofday (&tv, NULL);
  if (memcmp (lt, &saved_lt, sizeof (struct tm)) != 0)
    exit (1);

  exit (0);
}
	  ],
	 jm_cv_func_gettimeofday_clobber=no,
	 jm_cv_func_gettimeofday_clobber=yes,
	 dnl When crosscompiling, assume it is broken.
	 jm_cv_func_gettimeofday_clobber=yes)
  ])
  if test $jm_cv_func_gettimeofday_clobber = yes; then
    AC_LIBOBJ(gettimeofday)
    AC_DEFINE(gettimeofday, rpl_gettimeofday,
      [Define to rpl_gettimeofday if the replacement function should be used.])
    AC_DEFINE(GETTIMEOFDAY_CLOBBERS_LOCALTIME_BUFFER, 1,
      [Define if gettimeofday clobbers localtime's static buffer.])
  fi
])
