include(CheckSourceCompiles)
# Compiler capability test
check_source_compiles(Fortran
"program test
character(kind=selected_char_kind('ISO_10646')) :: c
end program"
HAS_Fortran_UTF8
)

# compiler flags for gfortran
if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")

  if(SERIAL)
    message(STATUS "Configuring to build with -fcoarray=single")
    add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-fcoarray=single>")
  else()
    add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-fcoarray=lib>")
  endif()

  if(BLAS)
    add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-fexternal-blas;${BLAS}>")
    list(APPEND LIBS "blas")
    message(STATUS "Configuring build to use BLAS from ${BLAS}")
  endif()

  add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-fcheck=bounds;-fbacktrace>")
  add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Release>>:-Ofast;-fno-frontend-optimize;-fno-backtrace>")

elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  # compiler flags for ifort

  if(SERIAL)
    message(STATUS "Configuring to build with -coarray=single")
    if(WIN32)
      add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:/Qcoarray:single>")
    else()
      add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-coarray=single>")
    endif()
  else()
    if(WIN32)
      add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:/Qcoarray:shared>")
    else()
      add_compile_options("$<$<COMPILE_LANGUAGE:Fortran>:-coarray=shared>")
    endif()
  endif()

  if(WIN32)
    string(APPEND CMAKE_Fortran_FLAGS " /assume:byterecl")
  else()
    string(APPEND CMAKE_Fortran_FLAGS " -assume byterecl")
  endif()
  add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-check;-traceback>")
  # add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Release>>:-O3>")

elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Cray")
  # compiler flags for Cray ftn
  string(APPEND CMAKE_Fortran_FLAGS " -h noomp")
  add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Debug>>:-O0;-g>")
  add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<CONFIG:Release>>:-O3>")
endif()
