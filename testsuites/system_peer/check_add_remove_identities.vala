using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    void do_check_add_remove_identities_pid1()
    {
        int index = 0;
        string cur_event;
        // First we must find a "executing:prepare_add_identity"
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "prepare_add_identity" in cur_event) break;
            index++;
        }
        // then we must find the related "executing:add_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "add_identity" in cur_event) break;
            index++;
        }
        // then we must find the creation of namespace "netnsmanager:create_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_namespace" in cur_event) break;
            index++;
        }
        // then we must find twice the creation of pseudodev "netnsmanager:create_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }

        // then we must find another "executing:prepare_add_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "prepare_add_identity" in cur_event) break;
            index++;
        }
        // then we must find the related "executing:add_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "add_identity" in cur_event) break;
            index++;
        }
        // then we must find the creation of namespace "netnsmanager:create_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_namespace" in cur_event) break;
            index++;
        }
        // then we must find twice the creation of pseudodev "netnsmanager:create_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }

        // then we must find a "executing:remove_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "remove_identity" in cur_event) break;
            index++;
        }
        // then we must find twice the remove of pseudodev "netnsmanager:delete_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        // then we must find the remove of namespace "netnsmanager:delete_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_namespace" in cur_event) break;
            index++;
        }

        // then we must find another "executing:remove_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "remove_identity" in cur_event) break;
            index++;
        }
        // then we must find twice the remove of pseudodev "netnsmanager:delete_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        // then we must find the remove of namespace "netnsmanager:delete_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_namespace" in cur_event) break;
            index++;
        }

        // then we must find a third "executing:prepare_add_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "prepare_add_identity" in cur_event) break;
            index++;
        }
        // then we must find the related "executing:add_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "add_identity" in cur_event) break;
            index++;
        }
        // then we must find the creation of namespace "netnsmanager:create_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_namespace" in cur_event) break;
            index++;
        }
        // then we must find twice the creation of pseudodev "netnsmanager:create_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "create_pseudodev" in cur_event) break;
            index++;
        }

        // then we must find a third "executing:remove_identity"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("executing" in cur_event && "remove_identity" in cur_event) break;
            index++;
        }
        // then we must find twice the remove of pseudodev "netnsmanager:delete_pseudodev"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_pseudodev" in cur_event) break;
            index++;
        }
        // then we must find the remove of namespace "netnsmanager:delete_namespace"
        index++;
        while (true)
        {
            assert(index < tester_events.size);
            cur_event = tester_events[index].down();
            if ("netnsmanager" in cur_event && "delete_namespace" in cur_event) break;
            index++;
        }
    }
}