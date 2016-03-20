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

ITasklet testsuite_tasklet;
void main()
{
    PthTaskletImplementer.init();
    testsuite_tasklet = PthTaskletImplementer.get_tasklet_system();
    // Create the manager for this node. This creates first id.
    IdentityManager im0 = new IdentityManager(testsuite_tasklet,
            new ArrayList<string>.wrap({"eth0"}),
            new ArrayList<string>.wrap({"B8:70:F4:9F:78:9B"}),
            new ArrayList<string>.wrap({"169.254.12.34"}),
            new FakeNetnsManager(),
            new FakeStubFactory());
    // Get my first id.
    NodeID id0 = im0.get_main_id();
    print(@"id0 = $(id0.id).\n");
    print(@"it handles $(im0.get_pseudodev(id0, "eth0")) on namespace \"$(im0.get_namespace(id0))\".\n");
    testsuite_tasklet.ms_wait(100);
    // Add a NIC
    im0.add_handled_nic("wlan0", "CC:AF:78:2E:C8:B6", "169.254.45.67");
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
    arc0.peer_mac = "42:66:C0:CF:72:82";
    arc0.peer_linklocal = "169.254.54.32";
    arc0.fake_stub.first_main_id = first_id_arc0;
    im0.add_arc(arc0);
    // list identity-arcs in arc0 (for now the only arc)
    Gee.List<IIdmgmtIdentityArc> x = im0.get_identity_arcs(arc0, id0);
    print(@"id0 now has $(x.size) identity-arcs.\n");
    IIdmgmtIdentityArc x0 = x[0];
    print(@" 1. from $(id0.id) to $(x0.get_peer_nodeid().id) which has MAC $(x0.get_peer_mac()) linklocal $(x0.get_peer_linklocal()).\n");
    // wait a little
    testsuite_tasklet.ms_wait(100);
    // now we migrate
    im0.prepare_add_identity(100, id0);
    testsuite_tasklet.ms_wait(100);
    NodeID id1 = im0.add_identity(100, id0);
    print(@"id1 = $(id1.id).\n");
    print(@"it handles $(im0.get_pseudodev(id1, "eth0")) on namespace \"$(im0.get_namespace(id1))\".\n");
    print(@"   and $(im0.get_pseudodev(id1, "wlan0")) on namespace \"$(im0.get_namespace(id1))\".\n");
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
                          "old_id_new_mac", "old_id_new_mac",
                          new FakeCallerInfo(arc0));
    assert(answer == null);
    print(@" answer is <null>.\n");
    print(@"It informs my id#$(id1.id) and asks if it participates.\n");
    testsuite_tasklet.ms_wait(100); // simulate latency
    answer = im0.match_duplication(110,
                          make_iid(id1),
                          make_iid(first_id_arc0),
                          make_iid(second_id_arc0),
                          "old_id_new_mac", "old_id_new_mac",
                          new FakeCallerInfo(arc0));
    assert(answer == null);
    print(@" answer is <null>.\n");
    // wait a little, because the new identity-arcs are built in a tasklet.
    testsuite_tasklet.ms_wait(100);
    // list identity-arcs in arc0
    x = im0.get_identity_arcs(arc0, id0);
    print(@"id0 now has $(x.size) identity-arcs.\n");
    //...

    x = im0.get_identity_arcs(arc0, id1);
    print(@"id1 now has $(x.size) identity-arcs.\n");
    //...

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

    public void notify_identity_removed(IIdentityID id) throws StubError, DeserializeError
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

NodeIDAsIdentityID make_iid(NodeID id)
{
    NodeIDAsIdentityID ret = new NodeIDAsIdentityID();
    ret.id = id;
    return ret;
}

