using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_prepare_add_identity(string task)
    {
        if (task.has_prefix("prepare_add_identity,"))
        {
            string remain = task.substring("prepare_add_identity,".length);
            string[] args = remain.split(",");
            if (args.length != 3) error("bad args num in task 'prepare_add_identity'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'prepare_add_identity'");
            int64 migration_id;
            if (! int64.try_parse(args[1], out migration_id)) error("bad args migration_id in task 'prepare_add_identity'");
            int64 nodeid_index;
            if (! int64.try_parse(args[2], out nodeid_index)) error("bad args nodeid_index in task 'prepare_add_identity'");
            print(@"INFO: in $(s_wait) seconds will prepare to add identity from old_id #$(nodeid_index) with migration_id $(migration_id).\n");
            PrepareAddIdentityTasklet s = new PrepareAddIdentityTasklet((int)(s_wait*1000), (int)migration_id, (int)nodeid_index);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class PrepareAddIdentityTasklet : Object, ITaskletSpawnable
    {
        public PrepareAddIdentityTasklet(int ms_wait, int migration_id, int nodeid_index)
        {
            this.ms_wait = ms_wait;
            this.migration_id = migration_id;
            this.nodeid_index = nodeid_index;
        }
        private int ms_wait;
        private int migration_id;
        private int nodeid_index;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            NodeID old_id = my_nodeid_list[nodeid_index];
            identity_mgr.prepare_add_identity(migration_id, old_id);

            return null;
        }
    }

    bool schedule_task_add_identity(string task)
    {
        if (task.has_prefix("add_identity,"))
        {
            string remain = task.substring("add_identity,".length);
            string[] args = remain.split(",");
            if (args.length != 3) error("bad args num in task 'add_identity'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'add_identity'");
            int64 migration_id;
            if (! int64.try_parse(args[1], out migration_id)) error("bad args migration_id in task 'add_identity'");
            int64 nodeid_index;
            if (! int64.try_parse(args[2], out nodeid_index)) error("bad args nodeid_index in task 'add_identity'");
            print(@"INFO: in $(s_wait) seconds will prepare to add identity from old_id #$(nodeid_index) with migration_id $(migration_id).\n");
            AddIdentityTasklet s = new AddIdentityTasklet((int)(s_wait*1000), (int)migration_id, (int)nodeid_index);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class AddIdentityTasklet : Object, ITaskletSpawnable
    {
        public AddIdentityTasklet(int ms_wait, int migration_id, int nodeid_index)
        {
            this.ms_wait = ms_wait;
            this.migration_id = migration_id;
            this.nodeid_index = nodeid_index;
        }
        private int ms_wait;
        private int migration_id;
        private int nodeid_index;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            NodeID old_id = my_nodeid_list[nodeid_index];
            NodeID new_id = identity_mgr.add_identity(migration_id, old_id);
            my_nodeid_list.add(new_id);

            return null;
        }
    }
}