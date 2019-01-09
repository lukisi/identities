using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_removearc(string task)
    {
        if (task.has_prefix("removearc,"))
        {
            string remain = task.substring("removearc,".length);
            string[] args = remain.split(",");
            if (args.length != 2) error("bad args num in task 'removearc'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'removearc'");
            int64 arc_index;
            if (! int64.try_parse(args[1], out arc_index)) error("bad args arc_index in task 'removearc'");
            print(@"INFO: in $(s_wait) seconds will remove arc # $(arc_index).\n");
            RemoveArcTasklet s = new RemoveArcTasklet((int)(s_wait*1000), (int)arc_index);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class RemoveArcTasklet : Object, ITaskletSpawnable
    {
        public RemoveArcTasklet(int ms_wait, int arc_index)
        {
            this.ms_wait = ms_wait;
            this.arc_index = arc_index;
        }
        private int ms_wait;
        private int arc_index;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:executing:remove_arc");
            fake_neighborhood_arc_removing_then_removed(arcs[arc_index]);

            return null;
        }
    }
}