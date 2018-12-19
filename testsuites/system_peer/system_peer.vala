using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    int pid;

    ITasklet tasklet;
    FakeCommandDispatcher cm;
    IdentityManager? identity_mgr;
    SkeletonFactory skeleton_factory;
    StubFactory stub_factory;

    ArrayList<IdmgmtArc> arcs;

    int main(string[] _args)
    {
        pid = 0; // default
        OptionContext oc = new OptionContext("<options>");
        OptionEntry[] entries = new OptionEntry[2];
        int index = 0;
        entries[index++] = {"pid", 'p', 0, OptionArg.INT, ref pid, "Fake PID (e.g. -p 1234).", null};
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

        if (pid == 0) error("Bad usage");

        // Initialize tasklet system
        PthTaskletImplementer.init();
        tasklet = PthTaskletImplementer.get_tasklet_system();
        cm = new FakeCommandDispatcher();

        // Initialize modules that have remotable methods (serializable classes need to be registered).
        IdentityManager.init(tasklet);
        //typeof(MainIdentitySourceID).class_peek();

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

        PthTaskletImplementer.kill();

        return 0;
    }

    bool do_me_exit = false;
    void safe_exit(int sig)
    {
        // We got here because of a signal. Quick processing.
        do_me_exit = true;
    }

}