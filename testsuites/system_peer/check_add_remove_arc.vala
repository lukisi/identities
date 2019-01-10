using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    void do_check_add_remove_arc_pid1()
    {
        int index = 0;
        string cur_event;
        // First we must find a "executing:add_arc"
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "add_arc" in cur_event) break;
            index++;
        }
        // then we must find a "signal:identity_arc_added"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_added" in cur_event) break;
            index++;
        }
        // then we must find a "tag:work"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("tag" in cur_event && "work" in cur_event) break;
            index++;
        }
        // then we must find a "executing:remove_arc"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "remove_arc" in cur_event) break;
            index++;
        }
        // then we must find a "signal:identity_arc_removing"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_removing" in cur_event) break;
            index++;
        }
        // then we must find a "signal:identity_arc_removed"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_removed" in cur_event) break;
            index++;
        }
    }

    void do_check_add_remove_arc_pid2()
    {
        int index = 0;
        string cur_event;
        // First we must find a "executing:add_arc"
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "add_arc" in cur_event) break;
            index++;
        }
        // then we must find a "signal:identity_arc_added"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_added" in cur_event) break;
            index++;
        }
        // then, although we did not pass the task removearc, finally all arcs are removed:
        // hence, we must find a "signal:identity_arc_removing"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_removing" in cur_event) break;
            index++;
        }
        // then we must find a "signal:identity_arc_removed"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("signal" in cur_event && "identity_arc_removed" in cur_event) break;
            index++;
        }
    }
}