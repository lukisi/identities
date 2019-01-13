using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    void do_check_multi_id_arcs_pid1()
    {
    }

    void do_check_multi_id_arcs_pid2()
    {
    }

    void do_check_multi_id_arcs_pid3()
    {
        int index = 0;
        string cur_event;
        // First we must find a "tag:2"
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("tag" in cur_event && "2" in cur_event) break;
            index++;
        }
        // then we must find twice related "netnsmanager:add_gateway"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "add_gateway" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "add_gateway" in cur_event) break;
            index++;
        }
        // First we must find a "tag:4"
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("tag" in cur_event && "4" in cur_event) break;
            index++;
        }
        // then we must find twice related "netnsmanager:remove_gateway"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "remove_gateway" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "remove_gateway" in cur_event) break;
            index++;
        }
    }
}