#
#  Keyringer Makefile by Silvio Rhatto (rhatto at riseup.net).
#
#  This Makefile is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the Free
#  Software Foundation; either version 2 of the License, or any later version.
#
#  This Makefile is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
#  Place - Suite 330, Boston, MA 02111-1307, USA
#

PACKAGE = keyringer
VERSION = 0.2.3
PREFIX ?= /usr/local
INSTALL = /usr/bin/install

clean:
	find . -name *~ | xargs rm -f # clean local backups

install_lib:
	$(INSTALL) -D --mode=0644 lib/keyringer/functions $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/functions

install_share:
	$(INSTALL) -D --mode=0755 -d share/keyringer $(DESTDIR)/$(PREFIX)/share/$(PACKAGE)
	$(INSTALL) -D --mode=0755 share/keyringer/* $(DESTDIR)/$(PREFIX)/share/$(PACKAGE)

install_bin:
	$(INSTALL) -D --mode=0755 keyringer $(DESTDIR)/$(PREFIX)/bin/keyringer

install_doc:
	$(INSTALL) -D --mode=0644 README $(DESTDIR)/$(PREFIX)/share/doc/$(PACKAGE)/README
	$(INSTALL) -D --mode=0644 LICENSE $(DESTDIR)/$(PREFIX)/share/doc/$(PACKAGE)/LICENSE

install_man:
	$(INSTALL) -D --mode=0644 share/man/keyringer.1 $(DESTDIR)/$(PREFIX)/share/man/man1

install: clean
	@make install_lib install_share install_bin install_doc install_man

build_man:
	pandoc -s -w man share/man/keyringer.1.mdwn -o share/man/keyringer.1
