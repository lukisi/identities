using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_addarc(string task)
    {
        if (task.has_prefix("addarc,"))
        {
            string remain = task.substring("addarc,".length);
            string[] args = remain.split(",");
            if (args.length != 4) error("bad args num in task 'addarc'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'addarc'");
            int64 peer_pid;
            if (! int64.try_parse(args[2], out peer_pid)) error("bad args peer_pid in task 'addarc'");
            string my_dev = args[1];
            string peer_dev = args[3];
            print(@"INFO: in $(s_wait) seconds will add arc from my nic $(my_dev) to peer $(peer_pid) on $(peer_dev).\n");
            AddArcTasklet s = new AddArcTasklet((int)(s_wait*1000), my_dev, (int)peer_pid, peer_dev);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class AddArcTasklet : Object, ITaskletSpawnable
    {
        public AddArcTasklet(int ms_wait, string my_dev, int peer_pid, string peer_dev)
        {
            this.ms_wait = ms_wait;
            this.my_dev = my_dev;
            this.peer_pid = peer_pid;
            this.peer_dev = peer_dev;
        }
        private int ms_wait;
        private string my_dev;
        private int peer_pid;
        private string peer_dev;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:executing:add_arc");
            PseudoNetworkInterface pseudonic = pseudonic_map[my_dev];
            string my_mac = pseudonic.mac;
            int /*NeighborhoodNodeID*/ peer_id = fake_random_neighborhoodnodeid(peer_pid);
            string peer_mac = fake_random_mac(peer_pid, peer_dev);
            string peer_linklocal = fake_random_linklocal(peer_mac);
            IdmgmtArc arc = new IdmgmtArc(my_dev, my_mac, peer_id, peer_mac, peer_linklocal);
            arcs.add(arc);
            identity_mgr.add_arc(arc);

            return null;
        }
    }
}