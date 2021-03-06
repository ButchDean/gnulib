#serial 1

dnl Find out how to get the file descriptor associated with an open DIR*.
dnl From Jim Meyering

AC_DEFUN([UTILS_FUNC_DIRFD],
[
  AC_HEADER_DIRENT
  dirfd_headers='
#if HAVE_DIRENT_H
# include <dirent.h>
#else /* not HAVE_DIRENT_H */
# define dirent direct
# if HAVE_SYS_NDIR_H
#  include <sys/ndir.h>
# endif /* HAVE_SYS_NDIR_H */
# if HAVE_SYS_DIR_H
#  include <sys/dir.h>
# endif /* HAVE_SYS_DIR_H */
# if HAVE_NDIR_H
#  include <ndir.h>
# endif /* HAVE_NDIR_H */
#endif /* HAVE_DIRENT_H */
'
  AC_CHECK_FUNCS(dirfd)
  AC_CHECK_DECLS([dirfd], , , $dirfd_headers)

  # Use the replacement only if we have neither the function
  # nor a declaration.
  if test $ac_cv_func_dirfd,$ac_cv_have_decl_dirfd = no,no; then
    AC_REPLACE_FUNCS([dirfd])
    AC_CACHE_CHECK(
	      [how to get the file descriptor associated with an open DIR*],
		   ac_cv_sys_dir_to_fd,
      [
        dirfd_save_DEFS=$DEFS
	for ac_expr in						\
								\
	    'dir_p->d_fd'					\
								\
	    'dir_p->dd_fd'					\
								\
	    '# systems for which the info is not available'	\
	    -1							\
	    ; do

	  # Skip each embedded comment.
	  case "$ac_expr" in '#'*) continue;; esac

	  DEFS="$DEFS -DDIR_TO_FD=$ac_expr"
	  AC_TRY_COMPILE(
	    [$dirfd_headers
	    ],
	    [DIR *dir_p = opendir("."); (void) ($ac_expr);],
	    dir_fd_done=yes
	  )
	  DEFS=$dirfd_save_DEFS
	  test "$dir_fd_done" = yes && break
	done

	ac_cv_sys_dir_to_fd=$ac_expr
      ]
    )
    AC_DEFINE_UNQUOTED(DIR_TO_FD,
      $ac_cv_sys_dir_to_fd,
      [the file descriptor associated with `dir_p'])
  fi
])
