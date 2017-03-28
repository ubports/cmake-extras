#!/usr/bin/env python

import gettext
gettext.textdomain('libertine')
_ = gettext.gettext

print(_('Python apps can be translated, too'))
print(_("Regardless of single- or double-quotes"))
