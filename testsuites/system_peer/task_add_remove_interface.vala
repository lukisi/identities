using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_addinterface(string task)
    {
        if (task.has_prefix("addinterface,"))
        {
            string remain = task.substring("addinterface,".length);
            string[] args = remain.split(",");
            if (args.length != 2) error("bad args num in task 'addinterface'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'addinterface'");
            string my_dev = args[1];
            print(@"INFO: in $(s_wait) seconds will add interface $(my_dev).\n");
            AddInterfaceTasklet s = new AddInterfaceTasklet((int)(s_wait*1000), my_dev);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class AddInterfaceTasklet : Object, ITaskletSpawnable
    {
        public AddInterfaceTasklet(int ms_wait, string my_dev)
        {
            this.ms_wait = ms_wait;
            this.my_dev = my_dev;
        }
        private int ms_wait;
        private string my_dev;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:executing:addinterface");
            assert(!(my_dev in pseudonic_map.keys));
            string listen_pathname = @"recv_$(pid)_$(my_dev)";
            string send_pathname = @"send_$(pid)_$(my_dev)";
            string mac = fake_random_mac(pid, my_dev);
            // @"fe:aa:aa:$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99)):$(PRNGen.int_range(10, 99))";
            print(@"INFO: mac for $(pid),$(my_dev) is $(mac).\n");
            PseudoNetworkInterface pseudonic = new PseudoNetworkInterface(my_dev, listen_pathname, send_pathname, mac);
            pseudonic_map[my_dev] = pseudonic;

            // Start listen stream on linklocal
            string linklocal = fake_random_linklocal(mac);
            // @"169.254.$(PRNGen.int_range(0, 255)).$(PRNGen.int_range(0, 255))";
            print(@"INFO: linklocal for $(mac) is $(linklocal).\n");
            pseudonic.linklocal = linklocal;
            pseudonic.st_listen_pathname = @"conn_$(linklocal)";
            skeleton_factory.start_stream_system_listen(pseudonic.st_listen_pathname);
            tasklet.ms_wait(1);
            print(@"started stream_system_listen $(pseudonic.st_listen_pathname).\n");

            identity_mgr.add_handled_nic(my_dev, mac, linklocal);

            return null;
        }
    }

    bool schedule_task_removeinterface(string task)
    {
        if (task.has_prefix("removeinterface,"))
        {
            string remain = task.substring("removeinterface,".length);
            string[] args = remain.split(",");
            if (args.length != 2) error("bad args num in task 'removeinterface'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'removeinterface'");
            string my_dev = args[1];
            print(@"INFO: in $(s_wait) seconds will remove interface $(my_dev).\n");
            RemoveInterfaceTasklet s = new RemoveInterfaceTasklet((int)(s_wait*1000), my_dev);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class RemoveInterfaceTasklet : Object, ITaskletSpawnable
    {
        public RemoveInterfaceTasklet(int ms_wait, string my_dev)
        {
            this.ms_wait = ms_wait;
            this.my_dev = my_dev;
        }
        private int ms_wait;
        private string my_dev;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:executing:removeinterface");

            // When the user (ntkd) removes the interface from identity_mgr, it needs first to remove
            //  the same interface from neighborhood_mgr. That will result in the neighborhood_mgr
            //  to remove the arcs and emit signals.
            ArrayList<IdmgmtArc> to_remove = new ArrayList<IdmgmtArc>();
            foreach (IdmgmtArc arc in arcs)
            {
                if (arc.my_dev == my_dev) to_remove.add(arc);
            }
            foreach (IdmgmtArc arc in to_remove)
            {
                fake_neighborhood_arc_removing_then_removed(arc);
            }

            identity_mgr.remove_handled_nic(my_dev);
            stop_rpc(my_dev);

            return null;
        }
    }
}