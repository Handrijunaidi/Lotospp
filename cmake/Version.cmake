# Generates include/version.h

# Lotos2 version
set(LOTOS2_VERSION_MAJOR 0)
set(LOTOS2_VERSION_MINOR 2)
set(LOTOS2_VERSION_PATCH 1)
set(LOTOS2_VERSION_BUILD "dev")

# When building from a git clone, set the extra version to the HEAD revision, replacing any existing value
find_program(lotos2_git git)
if (lotos2_git)
	if (NOT LOTOS2_VERSION_SOURCE_DIR)
		set(LOTOS2_VERSION_SOURCE_DIR ${PROJECT_SOURCE_DIR})
	endif ()

	execute_process(COMMAND ${lotos2_git} rev-parse HEAD
		WORKING_DIRECTORY ${LOTOS2_VERSION_SOURCE_DIR}
		RESULT_VARIABLE lotos2_git_result
		OUTPUT_VARIABLE lotos2_git_output
		ERROR_QUIET
		OUTPUT_STRIP_TRAILING_WHITESPACE
		)
	if (${lotos2_git_result} EQUAL 0)
		string(SUBSTRING ${lotos2_git_output} 0 7 lotos2_git_short)
		set(LOTOS2_VERSION_BUILD "-${lotos2_git_short}")
	endif ()
endif ()

# version.h content
set(lotos2_version_file "${CMAKE_CURRENT_BINARY_DIR}/include/version.h")
set(lotos2_old_version "")
set(lotos2_new_version
	"// Autogenerated by CMake. Don't edit, changes will be lost
#ifndef LOTOS2_VERSION_H
#define LOTOS2_VERSION_H

#define LOTOS2_VERSION_MAJOR ${LOTOS2_VERSION_MAJOR}
#define LOTOS2_VERSION_MINOR ${LOTOS2_VERSION_MINOR}
#define LOTOS2_VERSION_PATCH ${LOTOS2_VERSION_PATCH}
#define LOTOS2_VERSION_BUILD \"${LOTOS2_VERSION_BUILD}\"
#define LOTOS2_VERSION_STRING \"${LOTOS2_VERSION_MAJOR}.${LOTOS2_VERSION_MINOR}.${LOTOS2_VERSION_PATCH}${LOTOS2_VERSION_BUILD}\"

#endif // LOTOS2_VERSION_H
")

# Read in the old file (if it exists)
if (EXISTS ${lotos2_version_file})
	file(READ ${lotos2_version_file} lotos2_old_version)
endif ()

# Only write the file if the content has changed
string(COMPARE NOTEQUAL
	"${lotos2_old_version}" "${lotos2_new_version}"
	lotos2_update_version_file
	)

if (${lotos2_update_version_file})
	message(STATUS "Creating ${lotos2_version_file}")
	file(WRITE ${lotos2_version_file} ${lotos2_new_version})
endif ()
