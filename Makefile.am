NULL = 
ACLOCAL_AMFLAGS = -I m4

noinst_LTLIBRARIES = \
	libidentities.la \
	$(NULL)

check_PROGRAMS = \
	test_identitymanager_1 \
	$(NULL)

TESTS = \
	test_identitymanager_1 \
	$(NULL)

libidentities_la_SOURCES = \
	identities.vala \
	rngen.vala \
	$(NULL)

libidentities_la_VALAFLAGS = \
	-H identities.h \
	--library identities \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(JSON_PREFIX)/share/vala-0.36/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
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

test_identitymanager_1_SOURCES = \
	testsuites/test_identitymanager_1/test_identitymanager_1.vala \
	testsuites/test_identitymanager_1/identities.vala \
	testsuites/test_identitymanager_1/rngen.vala \
	$(NULL)

test_identitymanager_1_VALAFLAGS = \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(PTHTASKLET_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--pkg glib-2.0 \
	--pkg gee-0.8 \
	--pkg tasklet-system \
	--pkg pth-tasklet \
	--pkg ntkd-common \
	--pkg ntkdrpc\
	$(NULL)

test_identitymanager_1_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(PTHTASKLET_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

test_identitymanager_1_LDADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(PTHTASKLET_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(NTKDRPC_LIBS) \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(srcdir)/identities.vapi \
	$(NULL)

identities.vapi: libidentities_la_vala.stamp
	$(NULL)

