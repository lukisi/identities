using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    [CCode (array_length = false, array_null_terminated = true)]
    string[] interfaces;
    [CCode (array_length = false, array_null_terminated = true)]
    string[] _tasks;
    int pid;
    bool check_add_remove_arc_pid1;
    bool check_add_remove_arc_pid2;
    bool check_add_remove_identities_pid1;
    bool check_multi_id_arcs_pid1;
    bool check_multi_id_arcs_pid2;
    bool check_multi_id_arcs_pid3;
    bool check_add_arc_after_identity_pid1;
    bool check_add_arc_after_identity_pid2;
    bool check_add_arc_after_identity_pid3;

    ITasklet tasklet;
    FakeCommandDispatcher cm;
    IdentityManager? identity_mgr;
    SkeletonFactory skeleton_factory;
    StubFactory stub_factory;
    HashMap<string,PseudoNetworkInterface> pseudonic_map;
    int /*NeighborhoodNodeID*/ my_system_id;
    ArrayList<NodeID> my_nodeid_list;
    ArrayList<IdmgmtArc> arcs;
    ArrayList<string> tester_events;

    int main(string[] _args)
    {
        pid = 0; // default
        check_add_remove_arc_pid1 = false; // default
        check_add_remove_arc_pid2 = false; // default
        check_add_remove_identities_pid1 = false; // default
        check_multi_id_arcs_pid1 = false; // default
        check_multi_id_arcs_pid2 = false; // default
        check_multi_id_arcs_pid3 = false; // default
        check_add_arc_after_identity_pid1 = false; // default
        check_add_arc_after_identity_pid2 = false; // default
        check_add_arc_after_identity_pid3 = false; // default
        OptionContext oc = new OptionContext("<options>");
        OptionEntry[] entries = new OptionEntry[13];
        int index = 0;
        entries[index++] = {"pid", 'p', 0, OptionArg.INT, ref pid, "Fake PID (e.g. -p 1234).", null};
        entries[index++] = {"interfaces", 'i', 0, OptionArg.STRING_ARRAY, ref interfaces, "Interface (e.g. -i eth1). You can use it multiple times.", null};
        entries[index++] = {"tasks", 't', 0, OptionArg.STRING_ARRAY, ref _tasks, "Tasks (e.g. -t addarc,2,eth0,5,eth1 means: after 2 secs add an arc from my nic eth0 to the nic eth1 of pid5). You can use it multiple times.", null};
        entries[index++] = {"check-add-remove-arc-pid1", '\0', 0, OptionArg.NONE, ref check_add_remove_arc_pid1, "Final check for test add_remove_arc pid1.", null};
        entries[index++] = {"check-add-remove-arc-pid2", '\0', 0, OptionArg.NONE, ref check_add_remove_arc_pid2, "Final check for test add_remove_arc pid2.", null};
        entries[index++] = {"check-add-remove-identities-pid1", '\0', 0, OptionArg.NONE, ref check_add_remove_identities_pid1, "Final check for test add_remove_identities pid1.", null};
        entries[index++] = {"check-multi-id-arcs-pid1", '\0', 0, OptionArg.NONE, ref check_multi_id_arcs_pid1, "Final check for test multi_id_arcs pid1.", null};
        entries[index++] = {"check-multi-id-arcs-pid2", '\0', 0, OptionArg.NONE, ref check_multi_id_arcs_pid2, "Final check for test multi_id_arcs pid2.", null};
        entries[index++] = {"check-multi-id-arcs-pid3", '\0', 0, OptionArg.NONE, ref check_multi_id_arcs_pid3, "Final check for test multi_id_arcs pid3.", null};
        entries[index++] = {"check-add-arc-after-identity-pid1", '\0', 0, OptionArg.NONE, ref check_add_arc_after_identity_pid1, "Final check for test add_arc_after_identity pid1.", null};
        entries[index++] = {"check-add-arc-after-identity-pid2", '\0', 0, OptionArg.NONE, ref check_add_arc_after_identity_pid2, "Final check for test add_arc_after_identity pid2.", null};
        entries[index++] = {"check-add-arc-after-identity-pid3", '\0', 0, OptionArg.NONE, ref check_add_arc_after_identity_pid3, "Final check for test add_arc_after_identity pid3.", null};
        entries[index++] = { null };
        oc.add_main_entries(entries, null);
        try {
            oc.parse(ref _args);
        }
        catch (OptionError e) {
            print(@"Error parsing options: $(e.message)\n");
            return 1;
        }

        ArrayList<string> args = new ArrayList<string>.wrap(_args);

        tester_events = new ArrayList<string>();
        ArrayList<string> devs;
        // Names of the network interfaces to do RPC (to begin with).
        devs = new ArrayList<string>();
        foreach (string dev in interfaces) devs.add(dev);

        ArrayList<string> tasks = new ArrayList<string>();
        foreach (string task in _tasks) tasks.add(task);

        if (pid == 0) error("Bad usage");
        if (devs.is_empty) error("Bad usage");

        // Initialize tasklet system
        PthTaskletImplementer.init();
        tasklet = PthTaskletImplementer.get_tasklet_system();
        cm = new FakeCommandDispatcher();

        // Initialize modules that have remotable methods (serializable classes need to be registered).
        IdentityManager.init(tasklet);
        typeof(WholeNodeSourceID).class_peek();
        typeof(WholeNodeUnicastID).class_peek();
        typeof(NeighbourSrcNic).class_peek();

        // Initialize pseudo-random number generators.
        string _seed = @"$(pid)";
        uint32 seed_prn = (uint32)_seed.hash();
        PRNGen.init_rngen(null, seed_prn);
        IdentityManager.init_rngen(null, seed_prn);

        // Pass tasklet system to the RPC library (ntkdrpc)
        init_tasklet_system(tasklet);

        // RPC
        skeleton_factory = new SkeletonFactory();
        stub_factory = new StubFactory();

        pseudonic_map = new HashMap<string,PseudoNetworkInterface>();
        Gee.List<string> if_list_dev = new ArrayList<string>();
        Gee.List<string> if_list_mac = new ArrayList<string>();
        Gee.List<string> if_list_linklocal = new ArrayList<string>();
        foreach (string dev in devs)
        {
            assert(!(dev in pseudonic_map.keys));
            string listen_pathname = @"recv_$(pid)_$(dev)";
            string send_pathname = @"send_$(pid)_$(dev)";
            string mac = fake_random_mac(pid, dev);
            // @"fe:aa:aa:$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99))";
            print(@"INFO: mac for $(pid),$(dev) is $(mac).\n");
            PseudoNetworkInterface pseudonic = new PseudoNetworkInterface(dev, listen_pathname, send_pathname, mac);
            pseudonic_map[dev] = pseudonic;

            // Start listen stream on linklocal
            string linklocal = fake_random_linklocal(mac);
            // @"169.254.$(PRNGen.int_range(0, 255)).$(PRNGen.int_range(0, 255))";
            print(@"INFO: linklocal for $(mac) is $(linklocal).\n");
            pseudonic.linklocal = linklocal;
            pseudonic.st_listen_pathname = @"conn_$(linklocal)";
            skeleton_factory.start_stream_system_listen(pseudonic.st_listen_pathname);
            tasklet.ms_wait(1);
            print(@"started stream_system_listen $(pseudonic.st_listen_pathname).\n");

            if_list_dev.add(dev);
            if_list_mac.add(mac);
            if_list_linklocal.add(linklocal);
        }

        my_system_id = fake_random_neighborhoodnodeid(pid);
        print(@"INFO: neighborhoodnodeid for $(pid) is $(my_system_id).\n");
        skeleton_factory.whole_node_id = my_system_id;

        arcs = new ArrayList<IdmgmtArc>();
        my_nodeid_list = new ArrayList<NodeID>();

        // Init module Identities
        identity_mgr = new IdentityManager(
            if_list_dev, if_list_mac, if_list_linklocal,
            new IdmgmtNetnsManager(),
            new IdmgmtStubFactory(),
            () => @"169.254.$(PRNGen.int_range(0, 255)).$(PRNGen.int_range(0, 255))");
        my_nodeid_list.add(identity_mgr.get_main_id());
        // connect signals
        identity_mgr.identity_arc_added.connect(identities_identity_arc_added);
        identity_mgr.identity_arc_changed.connect(identities_identity_arc_changed);
        identity_mgr.identity_arc_removing.connect(identities_identity_arc_removing);
        identity_mgr.identity_arc_removed.connect(identities_identity_arc_removed);
        identity_mgr.arc_removed.connect(identities_arc_removed);

        foreach (string task in tasks)
        {
            if      (schedule_task_addarc(task)) {}
            else if (schedule_task_prepare_add_identity(task)) {}
            else if (schedule_task_add_identity(task)) {}
            else if (schedule_task_addtag(task)) {}
            else if (schedule_task_removearc(task)) {}
            else if (schedule_task_remove_identity(task)) {}
            else if (schedule_task_addinterface(task)) {}
            else if (schedule_task_removeinterface(task)) {}
            else error(@"unknown task $(task)");
        }

        // TODO

        // Temporary: register handlers for SIGINT and SIGTERM to exit
        Posix.@signal(Posix.Signal.INT, safe_exit);
        Posix.@signal(Posix.Signal.TERM, safe_exit);
        // Main loop
        while (true)
        {
            tasklet.ms_wait(100);
            if (do_me_exit) break;
        }

        // TODO

        // remove all arcs
        while (! arcs.is_empty) fake_neighborhood_arc_removing_then_removed(arcs[0]);

        // Then we destroy the object IdentityManager.
        identity_mgr = null;
        tasklet.ms_wait(100);

        // Call stop_rpc.
        ArrayList<string> final_devs = new ArrayList<string>();
        final_devs.add_all(pseudonic_map.keys);
        foreach (string dev in final_devs) stop_rpc(dev);

        PthTaskletImplementer.kill();

        print("Exiting. Event list:\n");
        foreach (string s in tester_events) print(@"$(s)\n");

        if (check_add_remove_arc_pid1)
        {
            print("Doing check_add_remove_arc_pid1...\n");
            do_check_add_remove_arc_pid1();
        }
        if (check_add_remove_arc_pid2)
        {
            print("Doing check_add_remove_arc_pid2...\n");
            do_check_add_remove_arc_pid2();
        }
        if (check_add_remove_identities_pid1)
        {
            print("Doing check_add_remove_identities_pid1...\n");
            do_check_add_remove_identities_pid1();
        }
        if (check_multi_id_arcs_pid1)
        {
            print("Doing check_multi_id_arcs_pid1...\n");
            do_check_multi_id_arcs_pid1();
        }
        if (check_multi_id_arcs_pid2)
        {
            print("Doing check_multi_id_arcs_pid2...\n");
            do_check_multi_id_arcs_pid2();
        }
        if (check_multi_id_arcs_pid3)
        {
            print("Doing check_multi_id_arcs_pid3...\n");
            do_check_multi_id_arcs_pid3();
        }
        if (check_add_arc_after_identity_pid1)
        {
            print("Doing check_add_arc_after_identity_pid1...\n");
            do_check_add_arc_after_identity_pid1();
        }
        if (check_add_arc_after_identity_pid2)
        {
            print("Doing check_add_arc_after_identity_pid2...\n");
            do_check_add_arc_after_identity_pid2();
        }
        if (check_add_arc_after_identity_pid3)
        {
            print("Doing check_add_arc_after_identity_pid3...\n");
            do_check_add_arc_after_identity_pid3();
        }

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

    void stop_rpc(string dev)
    {
        PseudoNetworkInterface pseudonic = pseudonic_map[dev];
        skeleton_factory.stop_stream_system_listen(pseudonic.st_listen_pathname);
        print(@"stopped stream_system_listen $(pseudonic.st_listen_pathname).\n");
        pseudonic_map.unset(dev);
    }

    class PseudoNetworkInterface : Object
    {
        public PseudoNetworkInterface(string dev, string listen_pathname, string send_pathname, string mac)
        {
            this.dev = dev;
            this.listen_pathname = listen_pathname;
            this.send_pathname = send_pathname;
            this.mac = mac;
        }
        public string mac {get; private set;}
        public string send_pathname {get; private set;}
        public string listen_pathname {get; private set;}
        public string dev {get; private set;}
        public string linklocal {get; set;}
        public string st_listen_pathname {get; set;}
    }

    string fake_random_mac(int pid, string dev)
    {
        string _seed = @"$(pid)_$(dev)";
        uint32 seed_prn = (uint32)_seed.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return @"fe:aa:aa:$(_rand.int_range(10, 99)):$(_rand.int_range(10, 99)):$(_rand.int_range(10, 99))";
    }

    string fake_random_linklocal(string mac)
    {
        uint32 seed_prn = (uint32)mac.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return @"169.254.$(_rand.int_range(0, 255)).$(_rand.int_range(0, 255))";
    }

    int /*NeighborhoodNodeID*/ fake_random_neighborhoodnodeid(int pid)
    {
        string _seed = @"$(pid)";
        uint32 seed_prn = (uint32)_seed.hash();
        Rand _rand = new Rand.with_seed(seed_prn);
        return (int)(_rand.int_range(1, 99999));
    }
}