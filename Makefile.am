NULL = 
ACLOCAL_AMFLAGS = -I m4

noinst_LTLIBRARIES = \
	libidentities.la \
	$(NULL)

check_PROGRAMS = \
	$(NULL)

TESTS = \
	$(NULL)

libidentities_la_SOURCES = \
	identities.vala \
	$(NULL)

libidentities_la_VALAFLAGS = \
	-H identities.h \
	--library identities \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg tasklet-system \
	--pkg ntkd-common \
	--pkg ntkdrpc\
	$(NULL)

libidentities_la_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(JSONGLIB_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

libidentities_la_LIBADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(JSONGLIB_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(NTKDRPC_LIBS) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(srcdir)/identities.vapi \
	$(NULL)

identities.vapi: libidentities_la_vala.stamp
	$(NULL)

