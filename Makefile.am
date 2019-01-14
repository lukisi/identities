NULL = 
ACLOCAL_AMFLAGS = -I m4

noinst_LTLIBRARIES = \
	libidentities.la \
	$(NULL)

check_PROGRAMS = \
	system_peer \
	$(NULL)

TESTS = \
	add_remove_arc \
	add_remove_identities \
	multi_id_arcs \
	add_arc_after_identity \
	add_remove_interface \
	add_remove_interface_2 \
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

system_peer_SOURCES =  \
	testsuites/system_peer/system_peer.vala \
	testsuites/system_peer/rngen.vala \
	testsuites/system_peer/serializables.vala \
	testsuites/system_peer/rpc/skeleton_factory.vala \
	testsuites/system_peer/rpc/stub_factory.vala \
	testsuites/system_peer/rpc/module_stubs.vala \
	testsuites/system_peer/fake_command_dispatcher.vala \
	testsuites/system_peer/fake_neighborhood_signals.vala \
	testsuites/system_peer/identities_helpers.vala \
	testsuites/system_peer/identities_signals.vala \
	testsuites/system_peer/task_addarc.vala \
	testsuites/system_peer/task_addidentity.vala \
	testsuites/system_peer/task_removeidentity.vala \
	testsuites/system_peer/task_addtag.vala \
	testsuites/system_peer/task_removearc.vala \
	testsuites/system_peer/task_add_remove_interface.vala \
	testsuites/system_peer/check_add_remove_arc.vala \
	testsuites/system_peer/check_add_remove_identities.vala \
	testsuites/system_peer/check_multi_id_arcs.vala \
	testsuites/system_peer/check_add_arc_after_identity.vala \
	testsuites/system_peer/check_add_remove_interface.vala \
	identities.vapi \
	$(NULL)

system_peer_VALAFLAGS = \
	--vapidir $(GEE_PREFIX)/share/vala/vapi \
	--vapidir $(TASKLETSYSTEM_VAPIDIR) \
	--vapidir $(PTHTASKLET_VAPIDIR) \
	--vapidir $(NTKDCOMMON_VAPIDIR) \
	--vapidir $(NTKDRPC_VAPIDIR) \
	--pkg gee-0.8 \
	--pkg ntkd-common \
	--pkg tasklet-system \
	--pkg pth-tasklet \
	--pkg ntkdrpc \
	$(NULL)

system_peer_CPPFLAGS = \
	-w \
	$(GOBJECT_CFLAGS) \
	$(GEE_CFLAGS) \
	$(NTKDCOMMON_CFLAGS) \
	$(TASKLETSYSTEM_CFLAGS) \
	$(PTHTASKLET_CFLAGS) \
	$(NTKDRPC_CFLAGS) \
	$(NULL)

system_peer_LDADD = \
	$(GOBJECT_LIBS) \
	$(GEE_LIBS) \
	$(NTKDCOMMON_LIBS) \
	$(TASKLETSYSTEM_LIBS) \
	$(PTHTASKLET_LIBS) \
	$(NTKDRPC_LIBS) \
	$(builddir)/libidentities.la \
	$(NULL)

MAINTAINERCLEANFILES = \
	$(srcdir)/identities.vapi \
	$(NULL)

identities.vapi: libidentities_la_vala.stamp
	$(NULL)

