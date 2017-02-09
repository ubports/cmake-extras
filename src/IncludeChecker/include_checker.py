#!/usr/bin/env python

#
# Copyright (C) 2017 Canonical Ltd
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
# Authored by: Pete Woods <pete.woods@canonical.com>
#

import os
import sys
from clang.cindex import Index


class ParseException(Exception):
    def __init__(self, header, errors):
        self.header = header
        self.errors = errors


class IncludeError:
    def __init__(self, header, includes):
        self.header = header
        self.includes = includes


class IncludeChecker:
    def __init__(self, compiler_args):
        self.index = Index.create()
        self.compiler_args = compiler_args
        self.ignore = frozenset()
        self.file_extensions = tuple()
        self.forbidden = frozenset()
        self.allowed = {}
        self.system_includes = self._load_system_includes()

    def _load_system_includes(self):
        import re
        import subprocess

        regex = re.compile(ur'(?:\#include \<...\> search starts here\:)(?P<list>.*?)(?:End of search list)',
                           re.DOTALL)
        process = subprocess.Popen(['clang++', '-v', '-E', '-x', 'c++', '-'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        process_out, process_err = process.communicate('')
        output = process_out + process_err
        includes = []
        for p in re.search(regex, output).group('list').split('\n'):
            p = p.strip()
            if len(p) > 0 and p.find('(framework directory)') < 0:
                includes.append('-isystem')
                includes.append(p)
        return includes

    def check_include_dirs(self, dirs):
        errors = []
        for incdir in dirs:
            errors.extend(self.check_includes(os.path.abspath(incdir)))
        return errors

    def check_includes(self, incdir):
        errors = []
        for root, dirs, files in os.walk(incdir, topdown=True):
            for d in dirs:
                if d in self.ignore:
                    dirs.remove(d)
            for filename in files:
                if filename.endswith(self.file_extensions):
                    fullname = os.path.join(root, filename)
                    allowed = frozenset()
                    for path, names in self.allowed.iteritems():
                        if root.endswith(path) or fullname.endswith(path):
                            allowed = names
                            break
                    error = self.check_include(fullname, allowed)
                    if error:
                        errors.append(error)
        return errors

    def check_include(self, header, allowed):
        tu = self.index.parse('test.cpp',
                              unsaved_files=[('test.cpp', '#include <%s>\n' % header)],
                              args=self.compiler_args + self.system_includes)
        if not tu:
            raise RuntimeError("unable to load input")

        if tu.diagnostics:
            raise ParseException(header, tu.diagnostics)

        includes = []
        for i in tu.get_includes():
            for f in self.forbidden - allowed:
                if f in i.include.name:
                    includes.append((i.include.name, i.location.file.name, i.location))

        if includes:
            return IncludeError(header, includes)

        return None


def main():
    from optparse import OptionParser

    parser = OptionParser("usage: %prog [options] -- [clang-args*]", version="%prog 1.0.0")
    parser.disable_interspersed_args()
    parser.add_option("-d", "--dir", help="read headers from DIR", metavar="DIR", action='append', default=[])
    parser.add_option("-f", "--forbidden", help="FORBIDDEN includes", metavar="FORBIDDEN", action='append', default=[])
    parser.add_option("-a", "--allowed", help="ALLOWED exceptions to forbidden includes, e.g. some/path:bad/header.h:bad/other.h", metavar="ALLOWED", action='append', default=[])
    parser.add_option("-i", "--ignore", help="IGNORE directories with this name", metavar="IGNORE", action='append', default=[])
    parser.add_option("-e", "--file-extensions", help="include files with these EXTENSIONS", metavar="EXTENSION", action='append', default=[])

    (opts, args) = parser.parse_args()

    if len(args) == 0:
        parser.error('invalid number arguments')

    checker = IncludeChecker(args)
    checker.forbidden = frozenset(opts.forbidden)
    if opts.ignore:
        checker.ignore = frozenset(opts.ignore)
    else:
        checker.ignore = frozenset(['.h', '.hxx'])
    checker.file_extensions = tuple(opts.file_extensions)

    allowed = {}
    for allow in opts.allowed:
        s = allow.split(':')
        if len(s) < 2:
            parser.error('invalid ALLOW argument: %s' % allow)
        allowed[s[0]] = frozenset(s[1:])
    checker.allowed = allowed

    try:
        errors = checker.check_include_dirs(opts.dir)
    except ParseException as err:
        sys.stderr.write('Error parsing "%s":\n' % err.header)
        for e in err.errors:
            loc = e.location
            sys.stderr.write('  "%s": line %s, column %s: %s\n' % (loc.file, loc.line, loc.column, e.spelling))
        sys.exit(1)

    if errors:
        for err in errors:
            sys.stderr.write('Forbidden include(s) in "%s":\n' % err.header)
            for include, file, loc in err.includes:
                sys.stderr.write('  "%s": line %s, column %s: %s\n' % (file, loc.line, loc.column, include))
        sys.exit(2)

if __name__ == '__main__':
    main()
