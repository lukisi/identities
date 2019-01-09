using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    bool schedule_task_addtag(string task)
    {
        if (task.has_prefix("addtag,"))
        {
            string remain = task.substring("addtag,".length);
            string[] args = remain.split(",");
            if (args.length != 2) error("bad args num in task 'addtag'");
            int64 s_wait;
            if (! int64.try_parse(args[0], out s_wait)) error("bad args s_wait in task 'addtag'");
            string label = args[1];
            print(@"INFO: in $(s_wait) seconds will add tag '$(label)' to event list.\n");
            AddTagTasklet s = new AddTagTasklet((int)(s_wait*1000), label);
            tasklet.spawn(s);
            return true;
        }
        else return false;
    }

    class AddTagTasklet : Object, ITaskletSpawnable
    {
        public AddTagTasklet(int ms_wait, string label)
        {
            this.ms_wait = ms_wait;
            this.label = label;
        }
        private int ms_wait;
        private string label;

        public void * func()
        {
            tasklet.ms_wait(ms_wait);

            tester_events.add(@"Tester:Tag:$(label)");

            return null;
        }
    }
}