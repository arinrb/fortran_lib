#ifndef UTILS_HAVE_ALREADY_LOADED
#  define UTILS_HAVE_ALREADY_LOADED
#  define USE_UTILS_H use, intrinsic:: iso_fortran_env, only: ERROR_UNIT, OUTPUT_UNIT
#  define WHERE_AM_I __FILE__, " ", __LINE__
#  ifdef __GFORTRAN__
#    define quote(x) "x"
#  else
#    ifdef __INTEL_COMPILER
#      define quote(x) #x
#    else
#      define quote(x) #x
#    endif
#  endif
#  define WARN(message) write(ERROR_UNIT, *) "WARN: ", WHERE_AM_I, (message)
#  define RAISE(message) write(ERROR_UNIT, *) "RAISE: ", WHERE_AM_I, (message); stop 1
#  define TESTABLE_RAISE(message, isRaised) \
     if(present(isRaised))then; \
       isRaised = .true.; \
       return; \
     else; \
       write(ERROR_UNIT, *) "RAISE: ", WHERE_AM_I, (message); stop 1; \
     end if
#  define ALL_OF(array, dim_, index) index = lbound(array, dim = dim_, kind = kind(index)), ubound(array, dim = dim_, kind = kind(index))
#  define has_val(array, val) (any((array) == (val)))
#  define is_iostat_ok(ios) (ios == 0)
#  define is_iostat_bad(ios) (.not.is_iostat_ok(ios))
#  define I (0, 1)
#  define PRINT(x) write(ERROR_UNIT, *) "INFO: ", WHERE_AM_I, (x)
#  define PRINT_VARIABLE(x) write(ERROR_UNIT, *) "INFO: ", WHERE_AM_I, quote(x), ": ", (x)

#  define WARN_IF(isBad) \
     if(isBad)then; \
       WARN(quote(isBad)); \
     end if

#  define RAISE_IF(isBad) \
     if(isBad)then; \
       RAISE(quote(isBad)); \
     end if
#  define TESTABLE_RAISE_IF(isBad, isRaised) \
     if(present(isRaised)) isRaised = .false.; \
     if(isBad)then; \
       TESTABLE_RAISE(quote(isBad), isRaised); \
     end if
#  define ASSERT(isOk) RAISE_IF(.not.(isOk))
#  define TESTABLE_ASSERT(isOk, isRaised) TESTABLE_RAISE_IF(.not.(isOk), isRaised)
#  define TEST(isOk) \
     ASSERT(isOk); \
     write(OUTPUT_UNIT, '(a)', advance = 'no') '.'

#  ifdef DEBUG
#    define DEBUG_RAISE_IF(isBad) RAISE_IF(isBad)
#    define DEBUG_PRINT(x) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, (x)
#    define DEBUG_PRINT_VARIABLE(x) write(ERROR_UNIT, *) "DEBUG: ", WHERE_AM_I, quote(x), ": ", (x)
#  else
#    define DEBUG_RAISE_IF(isBad)
#    define DEBUG_PRINT(x)
#    define DEBUG_PRINT_VARIABLE(x)
#  endif
#  define DEBUG_ASSERT(isOk) DEBUG_RAISE_IF(.not.(isOk))
#endif
