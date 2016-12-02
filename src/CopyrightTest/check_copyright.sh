#!/bin/sh

#
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
#
# Authored by: Michi Henning <michi.henning@canonical.com>
#              James Henstridge <james.henstridge@canonical.com>
#

#
# Check that we have acceptable license information in our source files.
#

set -e

prog_name=$(basename "$0")

usage="usage: $prog_name [-c include_pattern] [-i ignore_pattern] [-d ignore_dir] source_dir test_name"

while getopts "hc:i:d:" opt
do
    case "$opt" in
    '?')
        echo $usage >&2
        exit 2
        ;;
    'h')
        echo $usage
        exit 0
        ;;
    'c')
        include_pat="$OPTARG"
        ;;
    'i')
        ignore_pat="$OPTARG"
        ;;
    'd')
        ignore_dir="$OPTARG"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

[ $# -ne 2 ] && {
    echo $usage >&2
    exit 2
}

testname="$2"
logfile="${testname}.log"
filteredfile="${testname}_filtered.log"

args="-r $1"
[ -n "$include_pat" ] && args="-c $include_pat $args"
[ -n "$ignore_pat" ] && args="-i $ignore_pat $args"
licensecheck $args > $logfile

if [ -n "$ignore_dir" ]; then
    cat $logfile | grep -v -F "$ignore_dir" | grep "No copyright" > $filteredfile || :
else
    cat $logfile | grep "No copyright" > $filteredfile || :
fi

if [ -s $filteredfile ]; then
    cat $filteredfile
    exit 1
fi

exit 0
