/*
 *  This file is part of Netsukuku.
 *  Copyright (C) 2016 Luca Dionisi aka lukisi <luca.dionisi@gmail.com>
 *
 *  Netsukuku is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Netsukuku is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Netsukuku.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gee;
using TaskletSystem;
using Netsukuku;
using Netsukuku.Identities;

ITasklet testsuite_tasklet;
void main()
{
    PthTaskletImplementer.init();
    testsuite_tasklet = PthTaskletImplementer.get_tasklet_system();
    // Create the manager for this node. This creates first id.
    IdentityManager im0 = new IdentityManager(testsuite_tasklet,
            new ArrayList<string>.wrap({"eth0"}),
            new ArrayList<string>.wrap({"82:77:05:80:02:65"}),
            new ArrayList<string>.wrap({"192.168.28.181"}),
            new FakeNetnsManager(),
            new FakeStubFactory(),
            /*NewLinklocalAddress*/ () => @"192.168.$(Random.int_range(0, 255)).$(Random.int_range(0, 255))");
    // Get my first id.
    NodeID id0 = im0.get_main_id();
    print(@"id0 = $(id0.id).\n");
    print(@"it handles $(im0.get_pseudodev(id0, "eth0")) on namespace \"$(im0.get_namespace(id0))\".\n");
    testsuite_tasklet.ms_wait(100);
    // Add a NIC
    im0.add_handled_nic("wlan0", "32:02:11:40:75:71", "192.168.114.200");
    print(@"now also $(im0.get_pseudodev(id0, "wlan0")) on namespace \"$(im0.get_namespace(id0))\".\n");
    // Add an identity-module object to this id.
    SampleModuleManager sm0 = new SampleModuleManager();
    sm0.id = 123;
    im0.set_identity_module(id0, "sample_manager", sm0);
    SampleModuleManager r = (SampleModuleManager)im0.get_identity_module(id0, "sample_manager");
    print(@"it has sample_manager $(r.id)\n");
    // Add an arc
    NodeID first_id_arc0 = new NodeID(8376574);
    FakeArc arc0 = new FakeArc();
    arc0.dev = "eth0";
    arc0.peer_mac = "42:41:53:62:78:77";
    arc0.peer_linklocal = "192.168.60.164";
    arc0.fake_stub.first_main_id = first_id_arc0;
    im0.add_arc(arc0);
    // list identity-arcs in arc0
    foreach (NodeID id in im0.get_id_list())
    {
        Gee.List<IIdmgmtIdentityArc> id_arcs = im0.get_identity_arcs(arc0, id);
        print(@"id $(id.id) now has $(id_arcs.size) identity-arcs.\n");
        foreach (IIdmgmtIdentityArc id_arc in id_arcs)
        {
            print(@" # $(id_arc.get_peer_nodeid().id) MAC $(id_arc.get_peer_mac()) linklocal $(id_arc.get_peer_linklocal()).\n");
        }
    }
    // wait a little
    testsuite_tasklet.ms_wait(100);
    // now we migrate
    im0.prepare_add_identity(100, id0);
    testsuite_tasklet.ms_wait(100);
    NodeID id1 = im0.add_identity(100, id0);
    print(@"id1 = $(id1.id).\n");
    print(@"it handles $(im0.get_pseudodev(id1, "eth0")) on namespace \"$(im0.get_namespace(id1))\".\n");
    print(@"   and $(im0.get_pseudodev(id1, "wlan0")) on namespace \"$(im0.get_namespace(id1))\".\n");
    // list identity-arcs in arc0
    foreach (NodeID id in im0.get_id_list())
    {
        Gee.List<IIdmgmtIdentityArc> id_arcs = im0.get_identity_arcs(arc0, id);
        print(@"id $(id.id) now has $(id_arcs.size) identity-arcs.\n");
        foreach (IIdmgmtIdentityArc id_arc in id_arcs)
        {
            print(@" # $(id_arc.get_peer_nodeid().id) MAC $(id_arc.get_peer_mac()) linklocal $(id_arc.get_peer_linklocal()).\n");
        }
    }
    // Add an identity-module object to this id.
    SampleModuleManager sm1 = new SampleModuleManager();
    sm1.id = 654;
    im0.set_identity_module(id1, "sample_manager", sm1);
    r = (SampleModuleManager)im0.get_identity_module(id1, "sample_manager");
    print(@"it has sample_manager $(r.id)\n");
    // the old...
    print(@"id0 = $(id0.id).\n");
    print(@"it handles $(im0.get_pseudodev(id0, "eth0")) on namespace \"$(im0.get_namespace(id0))\".\n");
    print(@"   and $(im0.get_pseudodev(id0, "wlan0")) on namespace \"$(im0.get_namespace(id0))\".\n");
    // Now the neighbour (first_id_arc0) migrates. It has 2 identity-arcs with the current node, one
    //  with id0 and another with id1.
    print(@"On the neighbor, id#$(first_id_arc0.id) migrates.\n");
    NodeID second_id_arc0 = new NodeID(5275984);
    print(@"It informs my id#$(id0.id) and asks if it participates.\n");
    testsuite_tasklet.ms_wait(100); // simulate latency
    IDuplicationData? answer = im0.match_duplication(110,
                          make_iid(id0),
                          make_iid(first_id_arc0),
                          make_iid(second_id_arc0),
                          "32:23:10:73:57:11", "192.168.22.235",
                          new FakeCallerInfo(arc0));
    assert(answer == null);
    print(@" answer is <null>.\n");
    print(@"It informs my id#$(id1.id) and asks if it participates.\n");
    testsuite_tasklet.ms_wait(100); // simulate latency
    answer = im0.match_duplication(110,
                          make_iid(id1),
                          make_iid(first_id_arc0),
                          make_iid(second_id_arc0),
                          "32:23:10:73:57:11", "192.168.22.235",
                          new FakeCallerInfo(arc0));
    assert(answer == null);
    print(@" answer is <null>.\n");
    // wait a little, because the new identity-arcs are built in a tasklet.
    testsuite_tasklet.ms_wait(100);
    // list identity-arcs in arc0
    foreach (NodeID id in im0.get_id_list())
    {
        Gee.List<IIdmgmtIdentityArc> id_arcs = im0.get_identity_arcs(arc0, id);
        print(@"id $(id.id) now has $(id_arcs.size) identity-arcs.\n");
        foreach (IIdmgmtIdentityArc id_arc in id_arcs)
        {
            print(@" # $(id_arc.get_peer_nodeid().id) MAC $(id_arc.get_peer_mac()) linklocal $(id_arc.get_peer_linklocal()).\n");
        }
    }
    // Exit
    PthTaskletImplementer.kill();
}

class FakeArc : Object, IIdmgmtArc
{
    public FakeArc()
    {
        fake_stub = new FakeIdentityManagerStub();
    }
    public FakeIdentityManagerStub fake_stub;
    public string peer_linklocal;
    public string peer_mac;
    public string dev;

    public string get_dev()
    {
        return dev;
    }

    public string get_peer_linklocal()
    {
        return peer_linklocal;
    }

    public string get_peer_mac()
    {
        return peer_mac;
    }

    public FakeIdentityManagerStub fake_get_stub()
    {
        return fake_stub;
    }
}

int next_id_fake_idmgr_stub = 0;
class FakeIdentityManagerStub : Object, IIdentityManagerStub
{
    public FakeIdentityManagerStub()
    {
        id_fake_idmgr_stub = next_id_fake_idmgr_stub++;
        already_called = false;
    }
    public int id_fake_idmgr_stub;
    public NodeID first_main_id;
    private bool already_called;

    public IIdentityID get_peer_main_id() throws StubError, DeserializeError
    {
        assert(first_main_id != null);
        assert(! already_called);
        already_called = true;
        print(@"FakeIdentityManagerStub#$(id_fake_idmgr_stub): call start, simulate latency...\n");
        testsuite_tasklet.ms_wait(5);
        print(@"FakeIdentityManagerStub#$(id_fake_idmgr_stub): get_peer_main_id returns $(first_main_id.id).\n");
        NodeIDAsIdentityID ret = new NodeIDAsIdentityID();
        ret.id = first_main_id;
        return ret;
    }

    public IDuplicationData? match_duplication(
                int migration_id, IIdentityID peer_id, IIdentityID old_id, IIdentityID new_id,
                string old_id_new_mac, string old_id_new_linklocal) throws StubError, DeserializeError
    {
        if (id_fake_idmgr_stub == 0)
        {
            print(@"FakeIdentityManagerStub#$(id_fake_idmgr_stub): call start, simulate latency...\n");
            testsuite_tasklet.ms_wait(5);
            print(@"FakeIdentityManagerStub#$(id_fake_idmgr_stub): match_duplication returns <null>.\n");
            return null;
        }
        error("not implemented yet");
    }

    public void notify_identity_arc_removed(IIdentityID peer_id, IIdentityID my_id) throws StubError, DeserializeError
    {
        error("not implemented yet");
    }
}

int next_fakecommand_id = 0;
class FakeNetnsManager : Object, IIdmgmtNetnsManager
{
    public void create_namespace(string ns)
    {
        print(@"FakeNetnsManager.create_namespace(...).\n");
        int fakecommand_id = next_fakecommand_id++;
        print(@"FakeNetnsManager: execute#$(fakecommand_id) 'ip netns add $(ns)', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
    }

    public void create_pseudodev(string dev, string ns, string pseudo_dev, out string pseudo_mac)
    {
        print(@"FakeNetnsManager.create_pseudodev(...).\n");
        assert(ns != "");
        int fakecommand_id = next_fakecommand_id++;
        print(@"FakeNetnsManager: execute#$(fakecommand_id) 'ip link add dev $(pseudo_dev) link $(dev) type macvlan', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
        fakecommand_id = next_fakecommand_id++;
        print(@"FakeNetnsManager: execute#$(fakecommand_id) 'ip link set dev $(pseudo_dev) netns $(ns)', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
        fakecommand_id = next_fakecommand_id++;
        print(@"FakeNetnsManager: execute#$(fakecommand_id) 'ip netns exec $(ns) ip link set dev $(pseudo_dev) up', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
        pseudo_mac = randommac();
        print(@"FakeNetnsManager: assign MAC $(pseudo_mac).\n");
    }

    public void add_address(string ns, string pseudo_dev, string linklocal)
    {
        print(@"FakeNetnsManager.add_address(...).\n");
        assert(ns != "");
        int fakecommand_id = next_fakecommand_id++;
        print(@"FakeNetnsManager: execute#$(fakecommand_id) 'ip netns exec $(ns) ip address add $(linklocal)/32 dev $(pseudo_dev)', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
    }

    public void add_gateway(string ns, string linklocal_src, string linklocal_dst, string dev)
    {
        print(@"FakeNetnsManager.add_gateway(...).\n");
        int fakecommand_id = next_fakecommand_id++;
        string prefix = "";
        if (ns != "") prefix = @"ip netns exec $(ns) ";
        print(@"FakeNetnsManager: execute#$(fakecommand_id) '$(prefix)ip route add $(linklocal_dst) dev $(dev) src $(linklocal_src)', simulate latency...\n");
        testsuite_tasklet.ms_wait(1);
        print(@"FakeNetnsManager: execute#$(fakecommand_id) done.\n");
    }

    public void remove_gateway(string ns, string linklocal_src, string linklocal_dst, string dev)
    {
        error("not implemented yet");
    }

    public void flush_table(string ns)
    {
        error("not implemented yet");
    }

    public void delete_pseudodev(string ns, string pseudo_dev)
    {
        error("not implemented yet");
    }

    public void delete_namespace(string ns)
    {
        error("not implemented yet");
    }
}

class FakeStubFactory : Object, IIdmgmtStubFactory
{
    public IIdentityManagerStub get_stub(IIdmgmtArc arc)
    {
        return ((FakeArc)arc).fake_get_stub();
    }

    public IIdmgmtArc? get_arc(CallerInfo caller)
    {
        if (caller is FakeCallerInfo) return ((FakeCallerInfo)caller).arc;
        error("not implemented yet");
    }
}

class FakeCallerInfo : CallerInfo
{
    public FakeCallerInfo(IIdmgmtArc arc)
    {
        base();
        this.arc = arc;
    }

    public IIdmgmtArc arc;
}

class SampleModuleManager : Object
{
    public int id;
}

string randommac()
{
    int i = Random.int_range(0, 9);
    string ret = @"$(i)";
    ret += "2";
    for (int j = 0; j < 5; j++)
    {
        i = Random.int_range(0, 9);
        ret += @":$(i)";
        i = Random.int_range(0, 9);
        ret += @"$(i)";
    }
    return ret;
}

/*
"42:15:41:60:05:82", "192.168.137.31"
"52:34:31:47:75:05", "192.168.132.30"
"72:06:60:63:27:57", "192.168.250.37"
"82:28:75:03:81:12", "192.168.43.172"
"82:83:61:78:14:44", "192.168.227.43"
"32:88:22:47:55:31", "192.168.81.96"
"82:38:82:55:02:76", "192.168.101.254"
"82:40:86:73:17:06", "192.168.170.48"
"62:40:02:16:33:63", "192.168.133.88"
"42:67:58:21:55:45", "192.168.2.120"
"42:32:25:74:77:15", "192.168.41.103"
"02:87:88:84:70:12", "192.168.88.242"
"22:74:70:61:44:58", "192.168.21.108"
"12:50:16:06:75:84", "192.168.132.233"
"42:45:17:46:77:04", "192.168.153.149"
"82:24:58:66:64:51", "192.168.48.81"
"52:42:08:51:61:67", "192.168.211.45"
"22:66:10:42:82:70", "192.168.209.122"
"12:62:78:20:20:08", "192.168.55.25"
"22:80:75:37:61:04", "192.168.11.230"
"32:24:74:50:26:62", "192.168.111.34"
"32:46:78:26:70:60", "192.168.208.167"
"82:82:68:18:27:67", "192.168.78.74"
"62:45:54:15:47:07", "192.168.135.105"
"32:56:68:61:27:77", "192.168.29.9"
"22:82:28:26:76:21", "192.168.242.222"
"72:16:52:01:62:05", "192.168.23.246"
"22:80:54:03:25:34", "192.168.42.98"
"72:78:00:58:03:03", "192.168.156.23"
"82:57:62:66:51:77", "192.168.21.35"
"22:85:75:84:26:30", "192.168.191.41"
"22:00:46:38:35:01", "192.168.101.80"
"22:75:73:17:67:21", "192.168.119.102"
"72:08:45:16:23:18", "192.168.75.168"
"82:72:58:07:43:66", "192.168.211.100"
"72:12:21:64:17:50", "192.168.29.95"
"12:64:35:58:64:88", "192.168.195.149"
"22:12:84:03:67:17", "192.168.40.196"
"62:41:47:58:56:51", "192.168.221.182"
"32:34:72:46:54:72", "192.168.79.220"
"12:35:25:86:40:62", "192.168.220.175"
"02:73:08:41:84:33", "192.168.149.193"
"72:10:30:73:85:21", "192.168.246.74"
"72:06:56:04:67:53", "192.168.238.34"
"82:00:46:15:71:75", "192.168.104.12"
"62:17:14:51:75:41", "192.168.45.60"
"72:04:62:17:34:86", "192.168.247.153"
"42:14:48:81:83:08", "192.168.8.143"
"62:12:14:08:58:24", "192.168.88.147"
"52:81:18:47:56:30", "192.168.112.179"
"42:21:35:44:40:76", "192.168.80.207"
"42:18:01:64:58:03", "192.168.118.72"
"32:41:36:30:58:24", "192.168.151.198"
"52:10:31:48:53:72", "192.168.94.242"
"72:38:23:26:70:48", "192.168.46.201"
"22:46:50:15:48:36", "192.168.52.157"
"42:05:58:85:64:77", "192.168.15.119"
"82:32:35:55:36:01", "192.168.252.41"
"62:17:86:34:30:84", "192.168.175.143"
"52:13:74:04:85:21", "192.168.230.94"
"12:21:33:21:30:38", "192.168.254.26"
"22:62:25:44:07:80", "192.168.61.43"
"22:07:65:22:43:36", "192.168.77.253"
"02:34:65:44:06:24", "192.168.41.4"
"52:22:17:83:45:08", "192.168.142.249"
"82:55:02:67:63:01", "192.168.191.37"
"62:85:08:80:73:01", "192.168.142.182"
"72:80:28:14:15:00", "192.168.160.188"
"02:76:52:53:24:37", "192.168.125.179"
"22:50:48:71:10:62", "192.168.173.137"
"42:33:71:50:67:45", "192.168.207.220"
"12:42:34:03:74:05", "192.168.94.139"
"42:37:33:03:12:82", "192.168.231.169"
"62:00:00:12:42:75", "192.168.145.248"
"62:60:00:86:85:22", "192.168.193.30"
"72:70:85:43:02:17", "192.168.222.222"
"42:04:12:53:77:28", "192.168.188.210"
"22:58:11:54:78:61", "192.168.149.38"
"32:38:75:54:01:55", "192.168.1.156"
"52:70:37:26:54:01", "192.168.223.162"
"82:48:76:88:85:64", "192.168.203.185"
"42:26:62:50:61:82", "192.168.46.154"
"22:68:68:84:17:58", "192.168.246.126"
"02:77:25:25:16:18", "192.168.145.131"
"42:16:76:47:42:61", "192.168.105.32"
"32:38:41:84:42:13", "192.168.246.133"
"22:71:25:68:12:28", "192.168.156.29"
"42:37:81:86:30:87", "192.168.130.100"
"12:65:63:63:54:28", "192.168.170.249"
"82:40:31:84:42:80", "192.168.28.4"
"52:22:02:57:24:18", "192.168.54.142"
"72:41:54:30:58:48", "192.168.228.251"
"32:87:77:84:63:56", "192.168.240.241"
"32:60:07:77:53:67", "192.168.201.124"
"02:11:66:13:75:22", "192.168.98.215"
"52:03:76:58:56:43", "192.168.15.247"
*/

NodeIDAsIdentityID make_iid(NodeID id)
{
    NodeIDAsIdentityID ret = new NodeIDAsIdentityID();
    ret.id = id;
    return ret;
}

