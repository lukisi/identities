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
    NodeID my_id = im0.get_main_id();
    print(@"my id = $(my_id.id).\n");
    print(@"it handles $(im0.get_pseudodev(my_id, "eth0")) on namespace \"$(im0.get_namespace(my_id))\".\n");
    testsuite_tasklet.ms_wait(100);
    // Add a NIC
    im0.add_handled_nic("wlan0", "CC:AF:78:2E:C8:B6", "169.254.45.67");
    print(@"now also $(im0.get_pseudodev(my_id, "wlan0")) on namespace \"$(im0.get_namespace(my_id))\".\n");
    // Add an identity-module object to this id.
    SampleModuleManager sm1 = new SampleModuleManager();
    sm1.id = 123;
    im0.set_identity_module(my_id, "sample_manager", sm1);
    SampleModuleManager r = (SampleModuleManager)im0.get_identity_module(my_id, "sample_manager");
    print(@"it has sample_manager $(r.id)\n");
    // Add an arc
    FakeArc arc0 = new FakeArc();
    arc0.dev = "eth0";
    arc0.peer_mac = "42:66:C0:CF:72:82";
    arc0.peer_linklocal = "169.254.54.32";
    arc0.fake_stub.nodeid = new NodeID(8376574);
    im0.add_arc(arc0);
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
    }
    public int id_fake_idmgr_stub;
    public NodeID nodeid;

    public IIdentityID get_peer_main_id() throws StubError, DeserializeError
    {
        print(@"FakeIdentityManagerStub#$(id_fake_idmgr_stub): get_peer_main_id returns $(nodeid.id).\n");
        NodeIDAsIdentityID ret = new NodeIDAsIdentityID();
        ret.id = nodeid;
        return ret;
    }

    public IDuplicationData? match_duplication(
                int migration_id, IIdentityID peer_id, IIdentityID old_id, IIdentityID new_id,
                string old_id_new_mac, string old_id_new_linklocal) throws StubError, DeserializeError
    {
        error("not implemented yet");
    }

    public void notify_identity_removed(IIdentityID id) throws StubError, DeserializeError
    {
        error("not implemented yet");
    }
}

class FakeNetnsManager : Object, IIdmgmtNetnsManager
{
    public void create_namespace(string ns)
    {
        error("not implemented yet");
    }

    public void create_pseudodev(string dev, string ns, string pseudo_dev, out string pseudo_mac)
    {
        error("not implemented yet");
    }

    public void add_address(string ns, string pseudo_dev, string linklocal)
    {
        error("not implemented yet");
    }

    public void add_gateway(string ns, string linklocal_src, string linklocal_dst, string dev)
    {
        error("not implemented yet");
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
        error("not implemented yet");
    }
}

class SampleModuleManager : Object
{
    public int id;
}

