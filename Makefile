#
#  Keyringer Makefile by Silvio Rhatto (rhatto at riseup.net).
#
#  This Makefile is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the Free
#  Software Foundation; either version 3 of the License, or any later version.
#
#  This Makefile is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program; if not, write to the Free Software Foundation, Inc., 59 Temple
#  Place - Suite 330, Boston, MA 02111-1307, USA
#

PACKAGE  = keyringer
VERSION  = $(shell ./keyringer | head -n 1 | cut -d ' ' -f 2)
PREFIX  ?= /usr/local
ARCHIVE ?= tarballs
INSTALL  = /usr/bin/install

clean:
	find . -name *~ | xargs rm -f # clean local backups

install_lib:
	$(INSTALL) -D --mode=0755 lib/keyringer/functions $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/functions
	$(INSTALL) -D --mode=0755 -d lib/keyringer/actions $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/actions
	$(INSTALL) -D --mode=0755 lib/keyringer/actions/* $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/actions
	$(INSTALL) -D --mode=0755 -d share/keyringer/editors $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/editors
	$(INSTALL) -D --mode=0644 share/keyringer/editors/* $(DESTDIR)/$(PREFIX)/lib/$(PACKAGE)/editors

install_bin:
	$(INSTALL) -D --mode=0755 keyringer $(DESTDIR)/$(PREFIX)/bin/keyringer

install_doc:
	$(INSTALL) -D --mode=0644 index.mdwn $(DESTDIR)/$(PREFIX)/share/doc/$(PACKAGE)/README.md
	$(INSTALL) -D --mode=0644 LICENSE $(DESTDIR)/$(PREFIX)/share/doc/$(PACKAGE)/LICENSE

install_man:
	$(INSTALL) -D --mode=0644 share/man/keyringer.1 $(DESTDIR)/$(PREFIX)/share/man/man1/keyringer.1

install_completion:
	$(INSTALL) -D --mode=0644 lib/keyringer/completions/bash/keyringer $(DESTDIR)/$(PREFIX)/share/bash-completion/completions/keyringer
	$(INSTALL) -D --mode=0644 lib/keyringer/completions/zsh/_keyringer $(DESTDIR)/$(PREFIX)/share/zsh/vendor-completions/_keyringer

install: clean
	@make install_lib install_bin install_doc install_man install_completion

build_man:
	# Pipe output to sed to avoid http://lintian.debian.org/tags/hyphen-used-as-minus-sign.html
	# Fixed in http://johnmacfarlane.net/pandoc/releases.html#pandoc-1.10-2013-01-19
	pandoc -s -w man share/man/keyringer.1.mdwn -o share/man/keyringer.1
	sed -i -e 's/--/\\-\\-/g' share/man/keyringer.1

tarball:
	mkdir -p $(ARCHIVE)
	git archive --prefix=keyringer-$(VERSION)/ --format=tar HEAD | bzip2 > $(ARCHIVE)/keyringer-$(VERSION).tar.bz2

release:
	@make build_man
	git commit -a -m "Keyringer $(VERSION)"
	# See https://github.com/nvie/gitflow/issues/87
	#     https://github.com/nvie/gitflow/pull/160
	#     https://github.com/nvie/gitflow/issues/50
	#git flow release finish -s -m "Keyringer $(VERSION)" $(VERSION)
	git flow release finish -s $(VERSION)
	git checkout master
	@make tarball
	gpg --use-agent --armor --detach-sign --output $(ARCHIVE)/keyringer-$(VERSION).tar.bz2.asc $(ARCHIVE)/keyringer-$(VERSION).tar.bz2
	scp $(ARCHIVE)/keyringer-$(VERSION).tar.bz2* keyringer:/var/sites/keyringer/releases/
	# We're doing tagging afterwards:
	# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=568375
	#git tag -s $(VERSION) -m "Keyringer $(VERSION)"
	git checkout develop

debian:
	git checkout debian
	git-import-orig --upstream-vcs-tag=$(VERSION) $(ARCHIVE)/keyringer-$(VERSION).tar.bz2
	# Fine tune debian/changelog prepared by git-dch
	dch -e
	git commit -a -m "Updating debian/changelog"
	git-buildpackage --git-tag-only --git-sign-tags

wiki:
	@ikiwiki --setup ikiwiki.setup

wiki_deploy:
	@rsync -avz --delete www/ blog:/var/sites/keyringer/www/
