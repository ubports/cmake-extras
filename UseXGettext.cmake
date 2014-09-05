# Copyright (C) 2013 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 2.8.9)

find_package(XGettext REQUIRED)

macro(add_translations_directory NLS_PACKAGE)
    set(
        POT_FILE
        "${CMAKE_CURRENT_SOURCE_DIR}/${NLS_PACKAGE}.pot"
    )

    file(
	GLOB PO_FILES
	${CMAKE_CURRENT_SOURCE_DIR}/*.po
    )

    gettext_create_translations(
        ${POT_FILE}
        ALL
        ${PO_FILES}
    )
endmacro(add_translations_directory)

macro(add_translations_catalog NLS_PACKAGE)
    set(
	POT_FILE
	"${CMAKE_CURRENT_SOURCE_DIR}/${NLS_PACKAGE}.pot"
    )

    add_custom_target (pot COMMENT “Building translation catalog.”
        DEPENDS ${POT_FILE}
    )

    # init this list, which will hold all the sources across all dirs
    set(SOURCES "")

    # add each directory's sources to the overall sources list
    foreach(DIR ${ARGN})
        file(
            GLOB_RECURSE DIR_SOURCES
            RELATIVE ${CMAKE_SOURCE_DIR}
            ${DIR}/*.cpp
            ${DIR}/*.cc
            ${DIR}/*.cxx
            ${DIR}/*.vala
            ${DIR}/*.c
            ${DIR}/*.h
        )
	set (SOURCES ${SOURCES} ${DIR_SOURCES})
    endforeach()

    xgettext_create_pot_file(
        ${POT_FILE}
        CPP
        QT
        INPUT ${SOURCES}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        ADD_COMMENTS "TRANSLATORS"
        KEYWORDS "_" "N_"
        PACKAGE_NAME ${NLS_PACKAGE}
        COPYRIGHT_HOLDER "Canonical Ltd."
    )
endmacro()
