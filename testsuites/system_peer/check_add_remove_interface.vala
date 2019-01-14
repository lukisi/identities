using Netsukuku.Identities;

using Gee;
using Netsukuku;
using TaskletSystem;

namespace SystemPeer
{
    void do_check_add_remove_interface_2_pid1()
    {
/*
TODO
=================== 1 =========================

INFO: mac for 1,eth0 is fe:aa:aa:49:88:22.
INFO: linklocal for fe:aa:aa:49:88:22 is 169.254.224.26.
started stream_system_listen conn_169.254.224.26.
INFO: neighborhoodnodeid for 1 is 44337.
INFO: in 1 seconds will add tag '1' to event list.
INFO: in 2 seconds will add tag '2' to event list.
INFO: in 3 seconds will add tag '3' to event list.
INFO: in 4 seconds will add tag '4' to event list.
INFO: in 5 seconds will add tag '5' to event list.
INFO: in 1 seconds will add arc from my nic eth0 to peer 2 on eth0.
INFO: in 2 seconds will add interface eth1.
INFO: in 3 seconds will add arc from my nic eth1 to peer 3 on eth0.
INFO: in 4 seconds will remove interface eth0.
Tag: 1
Identities: Signal identity_arc_added:
    arc: dev eth0 peer_mac fe:aa:aa:27:79:94 peer_linklocal 169.254.167.155
    my identity: nodeid 1695610425
    id_arc: nodeid 1903597253 peer_mac fe:aa:aa:27:79:94 peer_linklocal 169.254.167.155
    prev_id_arc: null
Tag: 2
INFO: mac for 1,eth1 is fe:aa:aa:78:98:21.
INFO: linklocal for fe:aa:aa:78:98:21 is 169.254.5.184.
started stream_system_listen conn_169.254.5.184.
Tag: 3
Identities: Signal identity_arc_added:
    arc: dev eth1 peer_mac fe:aa:aa:25:10:38 peer_linklocal 169.254.191.25
    my identity: nodeid 1695610425
    id_arc: nodeid 969144653 peer_mac fe:aa:aa:25:10:38 peer_linklocal 169.254.191.25
    prev_id_arc: null
Tag: 4
Identities: Signal identity_arc_removing:
    arc: dev eth0 peer_mac fe:aa:aa:27:79:94 peer_linklocal 169.254.167.155
    my identity: nodeid 1695610425
    peer_nodeid: nodeid 1903597253
Identities: Signal identity_arc_removed:
    arc: dev eth0 peer_mac fe:aa:aa:27:79:94 peer_linklocal 169.254.167.155
    my identity: nodeid 1695610425
    peer_nodeid: nodeid 1903597253
stopped stream_system_listen conn_169.254.224.26.
Tag: 5
Identities: Signal identity_arc_removing:
    arc: dev eth1 peer_mac fe:aa:aa:25:10:38 peer_linklocal 169.254.191.25
    my identity: nodeid 1695610425
    peer_nodeid: nodeid 969144653
Identities: Signal identity_arc_removed:
    arc: dev eth1 peer_mac fe:aa:aa:25:10:38 peer_linklocal 169.254.191.25
    my identity: nodeid 1695610425
    peer_nodeid: nodeid 969144653
stopped stream_system_listen conn_169.254.5.184.
Exiting. Event list:
Tester:Tag:1
Tester:executing:add_arc
Identities:Signal:identity_arc_added
Tester:Tag:2
Tester:executing:addinterface
Tester:Tag:3
Tester:executing:add_arc
Identities:Signal:identity_arc_added
Tester:Tag:4
Tester:executing:removeinterface
Identities:Signal:identity_arc_removing
Identities:Signal:identity_arc_removed
Tester:Tag:5
Identities:Signal:identity_arc_removing
Identities:Signal:identity_arc_removed
Doing check_add_remove_interface_2_pid1...



=================== 2 =========================

INFO: mac for 2,eth0 is fe:aa:aa:27:79:94.
INFO: linklocal for fe:aa:aa:27:79:94 is 169.254.167.155.
started stream_system_listen conn_169.254.167.155.
INFO: neighborhoodnodeid for 2 is 61921.
INFO: in 1 seconds will add tag '1' to event list.
INFO: in 2 seconds will add tag '2' to event list.
INFO: in 3 seconds will add tag '3' to event list.
INFO: in 4 seconds will add tag '4' to event list.
INFO: in 5 seconds will add tag '5' to event list.
INFO: in 1 seconds will add arc from my nic eth0 to peer 1 on eth0.
INFO: in 4 seconds will remove arc # 0.
Tag: 1
Identities: Signal identity_arc_added:
    arc: dev eth0 peer_mac fe:aa:aa:49:88:22 peer_linklocal 169.254.224.26
    my identity: nodeid 1903597253
    id_arc: nodeid 1695610425 peer_mac fe:aa:aa:49:88:22 peer_linklocal 169.254.224.26
    prev_id_arc: null
Tag: 2
Tag: 3
Tag: 4
Identities: Signal identity_arc_removing:
    arc: dev eth0 peer_mac fe:aa:aa:49:88:22 peer_linklocal 169.254.224.26
    my identity: nodeid 1903597253
    peer_nodeid: nodeid 1695610425
Identities: Signal identity_arc_removed:
    arc: dev eth0 peer_mac fe:aa:aa:49:88:22 peer_linklocal 169.254.224.26
    my identity: nodeid 1903597253
    peer_nodeid: nodeid 1695610425
Tag: 5
stopped stream_system_listen conn_169.254.167.155.
Exiting. Event list:
Tester:Tag:1
Tester:executing:add_arc
Identities:Signal:identity_arc_added
Tester:Tag:2
Tester:Tag:3
Tester:Tag:4
Tester:executing:remove_arc
Identities:Signal:identity_arc_removing
Identities:Signal:identity_arc_removed
Tester:Tag:5
Doing check_add_remove_interface_2_pid2...



=================== 3 =========================

INFO: mac for 3,eth0 is fe:aa:aa:25:10:38.
INFO: linklocal for fe:aa:aa:25:10:38 is 169.254.191.25.
started stream_system_listen conn_169.254.191.25.
INFO: neighborhoodnodeid for 3 is 90631.
INFO: in 1 seconds will add tag '1' to event list.
INFO: in 2 seconds will add tag '2' to event list.
INFO: in 3 seconds will add tag '3' to event list.
INFO: in 4 seconds will add tag '4' to event list.
INFO: in 5 seconds will add tag '5' to event list.
INFO: in 3 seconds will add arc from my nic eth0 to peer 1 on eth1.
Tag: 1
Tag: 2
Tag: 3
Identities: Signal identity_arc_added:
    arc: dev eth0 peer_mac fe:aa:aa:78:98:21 peer_linklocal 169.254.5.184
    my identity: nodeid 969144653
    id_arc: nodeid 1695610425 peer_mac fe:aa:aa:78:98:21 peer_linklocal 169.254.5.184
    prev_id_arc: null
Tag: 4
Tag: 5
Identities: Signal identity_arc_removing:
    arc: dev eth0 peer_mac fe:aa:aa:78:98:21 peer_linklocal 169.254.5.184
    my identity: nodeid 969144653
    peer_nodeid: nodeid 1695610425
Identities: Signal identity_arc_removed:
    arc: dev eth0 peer_mac fe:aa:aa:78:98:21 peer_linklocal 169.254.5.184
    my identity: nodeid 969144653
    peer_nodeid: nodeid 1695610425
stopped stream_system_listen conn_169.254.191.25.
Exiting. Event list:
Tester:Tag:1
Tester:Tag:2
Tester:Tag:3
Tester:executing:add_arc
Identities:Signal:identity_arc_added
Tester:Tag:4
Tester:Tag:5
Identities:Signal:identity_arc_removing
Identities:Signal:identity_arc_removed
Doing check_add_remove_interface_2_pid3...


*/
    }

    void do_check_add_remove_interface_2_pid2()
    {
    }

    void do_check_add_remove_interface_2_pid3()
    {
    }
}