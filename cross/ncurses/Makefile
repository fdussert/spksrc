

PKG_NAME = ncurses
PKG_VERS = 5.9
PKG_EXT = tar.gz
PKG_DIST_NAME = $(PKG_NAME)-$(PKG_VERS).$(PKG_EXT)
PKG_DIST_SITE = http://ftp.gnu.org/pub/gnu/$(PKG_NAME)
PKG_DIR = $(PKG_NAME)-$(PKG_VERS)

DEPENDS = 

MAINTAINER = superzebulon@superzebulon.org
HOMEPAGE   = http://www.gnu.org/s/readline
COMMENT    = The Ncurses (new curses) library is a free software emulation of curses in System V Release 4.0, and more.
LICENSE    = http://www.gnu.org/licenses/gpl.html

GNU_CONFIGURE = 1
CONFIGURE_ARGS = --with-shared --enable-rpath --enable-overwrite

include ../../mk/spksrc.cross-cc.mk
