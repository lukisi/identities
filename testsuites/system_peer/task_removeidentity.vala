using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_remove_identity(string task)
    {
        if (task.has_prefix("remove_identity,"))
        {
            string remain = task.substring("remove_identity,".length);
            string[] args = remain.split(",");
            if (args.length != 2) error("bad args num in task 'remove_identity'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'remove_identity'");
            int64 nodeid_index;
            if (! int64.try_parse(args[1], out nodeid_index)) error("bad args nodeid_index in task 'remove_identity'");
            print(@"INFO: in $(s_wait) seconds will remove identity #$(nodeid_index).\n");
            RemoveIdentityTasklet s = new RemoveIdentityTasklet((int)(s_wait*1000), (int)nodeid_index);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class RemoveIdentityTasklet : Object, ITaskletSpawnable
    {
        public RemoveIdentityTasklet(int ms_wait, int nodeid_index)
        {
            this.ms_wait = ms_wait;
            this.nodeid_index = nodeid_index;
        }
        private int ms_wait;
        private int nodeid_index;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:executing:remove_identity");
            NodeID old_id = my_nodeid_list[nodeid_index];
            identity_mgr.remove_identity(old_id);

            return null;
        }
    }
}