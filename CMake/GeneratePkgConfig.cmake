function(get_relative_link OUTPUT PATH)
  get_filename_component(NAME ${PATH} NAME_WE)
  if (${PATH} MATCHES "^[$]<[$]<CONFIG:DEBUG>:")
    set(LINK "")
  elseif (${NAME} MATCHES "^lib")
    string(REGEX REPLACE "^lib" "-l" LINK ${NAME})
  elseif (${NAME} MATCHES "^-")
    set(LINK ${NAME})
  else()
    string(CONCAT LINK "-l" ${NAME})
  endif()
  set(${OUTPUT} ${LINK} PARENT_SCOPE)
endfunction()

function(generate_pkgconfig TARGET DESCRIPTION)
  # message("Generating pkg-config for ${TARGET}")
  get_filename_component(PREFIX ${CMAKE_INSTALL_PREFIX} REALPATH)

  get_target_property(LIST ${TARGET} LINK_LIBRARIES)
  set(REQS "")
  set(LIBS "")
  foreach (LIB ${LIST})
    if (TARGET ${LIB})
      set(HAS_REQS 1)
      list(APPEND REQS ${LIB})
    else()
      set(HAS_LIBS 1)
      get_relative_link(LINK ${LIB})
      if (NOT LINK EQUAL "")
        list(APPEND LIBS ${LINK})
      endif()
    endif()
  endforeach()

  if (HAS_REQS)
    set(REQUIRES "\nRequires.private:")
    foreach (REQ ${REQS})
      set(REQUIRES "${REQUIRES} ${REQ}")
    endforeach()
  endif()
  if (HAS_LIBS)
    set(LIBRARIES "\nLibs.private:")
    foreach (LIB ${LIBS})
      set(LIBRARIES "${LIBRARIES} ${LIB}")
    endforeach()
  endif()

  file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/pkgconfig")
  file(GENERATE OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/pkgconfig/${TARGET}.pc" CONTENT 
"prefix=${PREFIX}
includedir=\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}
libdir=\${prefix}/${CMAKE_INSTALL_LIBDIR}

Name: ${TARGET}
Description: ${DESCRIPTION}
Version: ${PROJECT_VERSION}

CFlags: -I\${includedir}
Libs: -L\${libdir} -l${TARGET}${REQUIRES}${LIBRARIES}
")

  install(FILES "pkgconfig/${TARGET}.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/pkgconfig")
endfunction()
