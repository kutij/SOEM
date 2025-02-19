# Written by J Kuti for automatic third party install & download

set (CMAKE_3RDPARTY_DIR "${CMAKE_BINARY_DIR}/ThirdParties")
set (3RDPARTY_INSTALL_PREFIX "${CMAKE_3RDPARTY_DIR}/package")
file(MAKE_DIRECTORY ${CMAKE_3RDPARTY_DIR})
#Policy_all_thirdparties
set(Policy_ALL_3RD_PARTIES "Setting one by one" CACHE STRING "How to get 3rdParties - download option may need Git or HG on the PATH")
set_property(CACHE Policy_ALL_3RD_PARTIES PROPERTY STRINGS "Setting one by one" "Download all")

macro(third_party_policy NAME COMMAND CACHE_LIST_NAME CONFIG_LIST_NAME DOES_NEED_BUILDING PROGRAMNAMELIST)
	set(Policy_${NAME} "Choose" CACHE STRING "How to get ${NAME} - download option may need Git or HG on the PATH")
	set_property(CACHE Policy_${NAME} PROPERTY STRINGS "Choose" "Search on the path" "Download")
	set(THIS_3RDPARTY_INSTALL_PREFIX "${CMAKE_3RDPARTY_DIR}/${NAME}/package")
	if (Policy_${NAME} STREQUAL  "Download" OR Policy_ALL_3RD_PARTIES STREQUAL "Download all")
		find_package(${NAME} QUIET PATHS ${THIS_3RDPARTY_INSTALL_PREFIX} NO_DEFAULT_PATH )
		if (NOT ${NAME}_FOUND)
			set (DIR "${CMAKE_3RDPARTY_DIR}/${NAME}")
			set (SRC_DIR "${DIR}/src")
			set (BUILD_DIR "${DIR}/build")
			# CLONE
			find_program(${${PROGRAMNAMELIST}})
			message( STATUS "Downloading ${NAME} (to ${SRC_DIR})...")
			EXEC_PROGRAM( "${COMMAND} \"${SRC_DIR}\"" )
			message ( STATUS " succeeded. CMake configure started....")
			# Call configure, generate and build (Release & Debug) on the externals
			message(STATUS "Generating makefile/solution for ${NAME}")
			EXEC_PROGRAM( cmake "${SRC_DIR}" ARGS \"${GENERATOR_ARGUMENT}\" \"-S${SRC_DIR}\"
				\"-B${BUILD_DIR}\" ${${CACHE_LIST_NAME}} -DCMAKE_INSTALL_PREFIX="${THIS_3RDPARTY_INSTALL_PREFIX}")
			if (WIN32)
				set(CONFIGS ${${CONFIG_LIST_NAME}})
			else()
				set(CONFIGS Release)
			endif()
			foreach(config ${CONFIGS})
				if(${DOES_NEED_BUILDING})
					message(STATUS "Building ${NAME} (${config}). It can take some time...")
					EXEC_PROGRAM(cmake ARGS
						--build \"${BUILD_DIR}\" --config ${config} )
				endif()
				message(STATUS "Installing ${NAME} (${config}).")
				EXEC_PROGRAM(cmake ARGS
					--install \"${BUILD_DIR}\" --config ${config} )
			endforeach()
			message(STATUS "done.")
			find_package(${NAME} REQUIRED PATHS ${THIS_3RDPARTY_INSTALL_PREFIX} NO_DEFAULT_PATH )
		endif()
	elseif (Policy_${NAME} STREQUAL  "Search on the path")
		find_package(${NAME} REQUIRED)
	else()
		message( SEND_ERROR "Policy for ${NAME} must be chosen!" )
	endif()
endmacro(third_party_policy)
