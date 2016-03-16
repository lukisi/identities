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

namespace Netsukuku
{
    public interface IIdmgmtNetnsManager : Object
    {
        public abstract void create_namespace(string ns);
        public abstract void create_pseudodev(string dev, string ns, string pseudo_dev, out string pseudo_mac);
        public abstract void add_address(string ns, string pseudo_dev, string linklocal);
        public abstract void add_gateway(string ns, string linklocal_src, string linklocal_dst, string dev);
        public abstract void remove_gateway(string ns, string linklocal_src, string linklocal_dst, string dev);
        public abstract void delete_pseudodev(string ns, string pseudo_dev);
        public abstract void delete_namespace(string ns);
    }

    public interface IIdmgmtStubFactory : Object
    {
        public abstract IIdentityManagerStub get_stub(IIdmgmtArc arc);
        public abstract IIdmgmtArc? get_arc(CallerInfo caller);
    }

    public interface IIdmgmtArc : Object
    {
        public abstract string get_dev();
        public abstract string get_peer_mac();
        public abstract string get_peer_linklocal();
    }

    public interface IIdmgmtIdentityArc : Object
    {
        public abstract NodeID get_peer_nodeid();
        public abstract string get_peer_mac();
        public abstract string get_peer_linklocal();
    }

    internal ITasklet tasklet;
    public class IdentityManager : Object, IIdentityManagerSkeleton
    {
        public IdentityManager(ITasklet _tasklet,
                               Gee.List<string> if_list_dev,
                               Gee.List<string> if_list_mac,
                               Gee.List<string> if_list_linklocal,
                               IIdmgmtNetnsManager netns_manager,
                               IIdmgmtStubFactory stub_factory
                               )
        {
            // Register serializable types internal to the module.
            typeof(DuplicationData).class_peek();
            typeof(NodeID).class_peek();
            typeof(NodeIDAsIdentityID).class_peek();
            tasklet = _tasklet;
            // init collections and stuff
            next_arc_id = 1;
            pending_migrations = new ArrayList<MigrationData>();
            dev_list = new ArrayList<string>();
            arc_list = new HashMap<IIdmgmtArc, int>();
            id_list = new ArrayList<Identity>();
            namespaces = new HashMap<string, string>();
            handled_nics = new HashMap<string, HandledNic>();
            identity_arcs = new HashMap<string, ArrayList<IdentityArc>>();
            // accept arguments
            assert(if_list_dev.size == if_list_mac.size);
            assert(if_list_dev.size == if_list_linklocal.size);
            this.netns_manager = netns_manager;
            this.stub_factory = stub_factory;
            // create first identity in default namespace
            main_id = new Identity();
            id_list.add(main_id);
            namespaces[@"$(main_id)"] = "";
            for (int i = 0; i < if_list_dev.size; i++)
            {
                string dev = if_list_dev[i];
                string mac = if_list_mac[i];
                string linklocal = if_list_linklocal[i];
                add_real_nic(dev, mac, linklocal);
            }
        }

        /* Status
         */

        private ArrayList<MigrationData> pending_migrations;
        private IIdmgmtNetnsManager netns_manager;
        private IIdmgmtStubFactory stub_factory;

        /* Associations
         */

        private ArrayList<string> dev_list;
        private HashMap<IIdmgmtArc, int> arc_list;
        private ArrayList<Identity> id_list;
        private Identity main_id;
        private HashMap<string, string> namespaces;
        private HashMap<string, HandledNic> handled_nics;
        private HashMap<string, ArrayList<IdentityArc>> identity_arcs;

        /* Helper functions for management of associations
         */

        // for arcs to-string
        private int next_arc_id;
        private string arc_to_string(IIdmgmtArc arc)
        {
            assert(arc_list.has_key(arc));
            return @"$(arc_list[arc])";
        }
        private void add_arc_to_list(IIdmgmtArc arc)
        {
            if (arc_list.has_key(arc)) return;
            arc_list[arc] = next_arc_id++;
        }

        // query: set of keys for handled_nics where dev=xyz
        private Gee.List<string> handled_nics_for_dev(string dev)
        {
            ArrayList<string> ret = new ArrayList<string>();
            foreach (string k in handled_nics.keys)
            {
                if (k.has_suffix(@"-$(dev)")) ret.add(k);
            }
            return ret;
        }

        // query: set of keys for handled_nics where id=xyz
        private Gee.List<string> handled_nics_for_identity(Identity id)
        {
            string s_id = id.to_string();
            ArrayList<string> ret = new ArrayList<string>();
            foreach (string k in handled_nics.keys)
            {
                if (k.has_prefix(@"$(s_id)-")) ret.add(k);
            }
            return ret;
        }

        // query: set of keys for identity_arcs where arc=xyz
        private Gee.List<string> identity_arcs_for_arc(IIdmgmtArc arc)
        {
            string s_arc = arc_to_string(arc);
            ArrayList<string> ret = new ArrayList<string>();
            foreach (string k in identity_arcs.keys)
            {
                if (k.has_suffix(@"-$(s_arc)")) ret.add(k);
            }
            return ret;
        }

        // query: set of keys for identity_arcs where if=xyz
        private Gee.List<string> identity_arcs_for_identity(Identity id)
        {
            string s_id = id.to_string();
            ArrayList<string> ret = new ArrayList<string>();
            foreach (string k in identity_arcs.keys)
            {
                if (k.has_prefix(@"$(s_id)-")) ret.add(k);
            }
            return ret;
        }

        // Add a real nic to the dev_list. Give it to the main identity in handled_nics.
        private void add_real_nic(string dev, string mac, string linklocal)
        {
            assert(! dev_list.contains(dev));
            dev_list.add(dev);
            HandledNic handled_nic = new HandledNic();
            handled_nic.dev = dev;
            handled_nic.mac = mac;
            handled_nic.linklocal = linklocal;
            handled_nics[@"$(main_id)-$(dev)"] = handled_nic;
        }

        // Retrieve instance of Identity given the NodeID of one of my identities.
        private Identity find_identity(NodeID id)
        {
            foreach (Identity ret in id_list)
            {
                if (id.equals(ret.id)) return ret;
            }
            assert_not_reached();
        }

        // Add association for an identity-arc
        private void add_in_identity_arcs(NodeID my_nodeid, IIdmgmtArc arc, NodeID peer_nodeid,
                                          string peer_mac, string peer_linklocal)
        {
            IdentityArc new_identity_arc = new IdentityArc();
            new_identity_arc.peer_nodeid = peer_nodeid;
            new_identity_arc.peer_linklocal = peer_linklocal;
            new_identity_arc.peer_mac = peer_mac;
            string k = key_for_identity_arcs(my_nodeid, arc);
            identity_arcs[k].add(new_identity_arc);
            identity_arc_added(arc, my_nodeid, new_identity_arc);
        }

        // Retrieve IdentityArc from associations
        private IdentityArc? get_from_identity_arcs(NodeID my_nodeid, IIdmgmtArc arc, NodeID peer_nodeid)
        {
            string k = key_for_identity_arcs(my_nodeid, arc);
            if (! identity_arcs.has_key(k)) return null;
            foreach (IdentityArc ret in identity_arcs[k])
            {
                if (ret.peer_nodeid.equals(peer_nodeid)) return ret;
            }
            return null;
        }

        private string key_for_identity_arcs(NodeID my_nodeid, IIdmgmtArc arc)
        {
            string s_arc = arc_to_string(arc);
            return @"$(my_nodeid.id)-$(s_arc)";
        }

        /* Public input methods
         */

        public void add_handled_nic(string dev, string mac, string linklocal)
        {
            add_real_nic(dev, mac, linklocal);
        }

        public void remove_handled_nic(string dev)
        {
            assert(dev in dev_list);
            assert(dev_list.size > 2);
            // First, for all the connectivity identities (some of them might be removed)
            ArrayList<Identity> id_list_copy = new ArrayList<Identity>();
            id_list_copy.add_all(id_list);
            foreach (Identity id in id_list_copy) if (id != main_id)
            {
                string k = @"$(id)-$(dev)";
                if (handled_nics.has_key(k))
                {
                    HandledNic hnic = handled_nics[k];
                    // hnic.dev is a pseudodev that has to be deleted.
                    string ns = namespaces[@"$(id)"];
                    netns_manager.delete_pseudodev(ns, hnic.dev);
                    // remove from association
                    handled_nics.unset(k);
                    // check if "id" still has some nics.
                    Gee.List<string> cur_nics = handled_nics_for_identity(id);
                    if (cur_nics.is_empty)
                    {
                        // "id" has no more nics, it has to be removed.
                        remove_identity(id.id);
                    }
                }
            }
            // Then, for the main identity
            string k = @"$(main_id)-$(dev)";
            handled_nics.unset(k);
        }

        public void add_arc(IIdmgmtArc arc, bool add_main_identities_arc=true)
        {
            assert(! arc_list.has_key(arc));
            add_arc_to_list(arc);
            foreach (Identity id in id_list)
            {
                string k = key_for_identity_arcs(id.id, arc);
                identity_arcs[k] = new ArrayList<IdentityArc>();
            }
            if (add_main_identities_arc)
            {
                IIdentityID _peer_id = stub_factory.get_stub(arc).get_peer_main_id();
                if (_peer_id is NodeIDAsIdentityID)
                {
                    NodeID peer_id = ((NodeIDAsIdentityID)_peer_id).id;
                    add_arc_identity(arc, main_id.id, peer_id, arc.get_peer_mac(), arc.get_peer_linklocal());
                }
            }
        }

        public void remove_arc(IIdmgmtArc arc)
        {
            // First, for all the connectivity identities
            foreach (Identity id in id_list) if (id != main_id)
            {
                string k = key_for_identity_arcs(id.id, arc);
                foreach (IdentityArc id_arc in identity_arcs[k])
                {
                    string ns = namespaces[@"$(id)"];
                    string dev = arc.get_dev();
                    string pseudodev = handled_nics[@"$(id)-$(dev)"].dev;
                    string linklocal = handled_nics[@"$(id)-$(dev)"].linklocal;
                    string peer_linklocal = id_arc.peer_linklocal;
                    netns_manager.remove_gateway(ns, linklocal, peer_linklocal, pseudodev);
                }
                identity_arcs.unset(k);
            }
            // Then, for the main identity
            string k = key_for_identity_arcs(main_id.id, arc);
            identity_arcs.unset(k);
            // Finally remove the arc from the collection
            arc_list.unset(arc);
        }

        /* Public informational methods
         */

        public NodeID get_main_id()
        {
            return main_id.id;
        }

        public Gee.List<NodeID> get_id_list()
        {
            ArrayList<NodeID> ret = new ArrayList<NodeID>();
            foreach (Identity id in id_list) ret.add(id.id);
            return ret;
        }

        public string get_namespace(NodeID id)
        {
            assert(namespaces.has_key(@"$(id.id)"));
            return namespaces[@"$(id.id)"];
        }

        public Gee.List<IIdmgmtIdentityArc> get_identity_arcs(IIdmgmtArc arc, NodeID id)
        {
            string k = key_for_identity_arcs(id, arc);
            assert(identity_arcs.has_key(k));
            return identity_arcs[k];
        }

        /* Public operational methods
         */

        public void set_identity_module(NodeID _id, string name, Object obj)
        {
            Identity id = find_identity(_id);
            id.modules[name] = obj;
        }

        public Object get_identity_module(NodeID _id, string name)
        {
            Identity id = find_identity(_id);
            assert(id.modules.has_key(name));
            return id.modules[name];
        }

        public void prepare_add_identity(int migration_id, NodeID old_id)
        {
            find_identity(old_id); // make sure identity is there
            MigrationData migration_data = new MigrationData();
            migration_data.migration_id = migration_id;
            migration_data.old_id = old_id;
            migration_data.ready = false;
            pending_migrations.add(migration_data);
            // Start a tasklet to remove the data from memory if the module does
            // not take care after a reasonable time.,
            CleanupPendingMigrationTasklet ts = new CleanupPendingMigrationTasklet();
            ts.mgr = this;
            ts.migration_id = migration_id;
            ts.old_id = old_id;
            tasklet.spawn(ts);
        }
        private void cleanup_pending_migration(int migration_id, NodeID old_id)
        {
            tasklet.ms_wait(600000);
            for (int i = 0; i < pending_migrations.size; i++)
            {
                if (pending_migrations[i].migration_id == migration_id &&
                    pending_migrations[i].old_id.equals(old_id))
                {
                    pending_migrations.remove_at(i);
                    break;
                }
            }
        }
        private class CleanupPendingMigrationTasklet : Object, ITaskletSpawnable
        {
            public IdentityManager mgr;
            public int migration_id;
            public NodeID old_id;
            public void * func()
            {
                mgr.cleanup_pending_migration(migration_id, old_id);
                return null;
            }
        }

        private int next_namespace = 0;
        public NodeID add_identity(int migration_id, NodeID old_id)
        {
            Identity old_identity = find_identity(old_id);
            MigrationData? migration_data = null;
            for (int i = 0; i < pending_migrations.size; i++)
            {
                if (pending_migrations[i].migration_id == migration_id &&
                    pending_migrations[i].old_id.equals(old_id))
                {
                    migration_data = pending_migrations[i];
                    break;
                }
            }
            assert(migration_data != null);
            Identity new_identity = new Identity();
            id_list.add(new_identity);
            migration_data.new_id = new_identity.id;
            // Choose a name for namespace.
            int this_namespace = next_namespace++;
            string ns_temp = @"ntkv$(this_namespace)";
            netns_manager.create_namespace(ns_temp);
            namespaces[@"$(new_identity)"] = namespaces[@"$(old_identity)"];
            namespaces[@"$(old_identity)"] = ns_temp;
            if (main_id == old_identity) main_id = new_identity;
            // Build pseudodevs
            foreach (string dev in dev_list)
            {
                string pseudo_dev = @"$(ns_temp)_$(dev)";
                string pseudo_mac;
                netns_manager.create_pseudodev(dev, ns_temp, pseudo_dev, out pseudo_mac);
                // generate a random IP for this pseudodev
                int i2 = Random.int_range(0, 255);
                int i3 = Random.int_range(0, 255);
                string old_id_new_linklocal = @"169.254.$(i2).$(i3)";
                netns_manager.add_address(ns_temp, pseudo_dev, old_id_new_linklocal);
                // Store values
                HandledNic old_id_new_hnic = new HandledNic();
                old_id_new_hnic.dev = pseudo_dev;
                old_id_new_hnic.mac = pseudo_mac;
                old_id_new_hnic.linklocal = old_id_new_linklocal;
                string old_id_k = @"$(old_identity)-$(dev)";
                string new_id_k = @"$(new_identity)-$(dev)";
                handled_nics[new_id_k] = handled_nics[old_id_k];
                handled_nics[old_id_k] = old_id_new_hnic;
                MigrationDeviceData device_data = new MigrationDeviceData();
                device_data.old_id_new_dev = pseudo_dev;
                device_data.old_id_new_mac = pseudo_mac;
                device_data.old_id_new_linklocal = old_id_new_linklocal;
                migration_data.devices[dev] = device_data;
            }
            migration_data.ready = true;
            // The first phase is done.
            // Duplication of all identity-arcs.
            foreach (IIdmgmtArc arc0 in arc_list.keys)
            {
                string k_old = key_for_identity_arcs(old_identity.id, arc0);
                string k_new = key_for_identity_arcs(new_identity.id, arc0);
                key_for_identity_arcs(old_identity.id, arc0);
                // prepare list of identity-arcs of new_identity
                identity_arcs[k_new] = new ArrayList<IdentityArc>();
                // retrieve the identity-arcs of old_identity
                if (! identity_arcs.has_key(k_old)) continue;
                foreach (IdentityArc w0 in identity_arcs[k_old])
                {
                    IdentityArc w1 = w0.copy();
                    identity_arcs[k_new].add(w1);
                    NodeIDAsIdentityID iid_peer_id = new NodeIDAsIdentityID();
                    iid_peer_id.id = w0.peer_nodeid;
                    NodeIDAsIdentityID iid_old_id = new NodeIDAsIdentityID();
                    iid_old_id.id = migration_data.old_id;
                    NodeIDAsIdentityID iid_new_id = new NodeIDAsIdentityID();
                    iid_new_id.id = migration_data.new_id;
                    string arc0_dev = arc0.get_dev();
                    string old_id_new_dev =
                        migration_data.devices[arc0_dev].old_id_new_dev;
                    string old_id_new_mac =
                        migration_data.devices[arc0_dev].old_id_new_mac;
                    string old_id_new_linklocal =
                        migration_data.devices[arc0_dev].old_id_new_linklocal;
                    IDuplicationData? dup_data = stub_factory.get_stub(arc0).match_duplication
                            (migration_id, iid_peer_id, iid_old_id, iid_new_id,
                             old_id_new_mac, old_id_new_linklocal);
                    if (dup_data != null && dup_data is DuplicationData)
                    {
                        DuplicationData _dup_data = (DuplicationData)dup_data;
                        w0.peer_mac = _dup_data.peer_old_id_new_mac;
                        w0.peer_linklocal = _dup_data.peer_old_id_new_linklocal;
                        w1.peer_nodeid = _dup_data.peer_new_id;
                    }
                    // Add direct route to gateway from the updated link-local of the old identity
                    //  to the link-local that is now set on the updated identity-arc.
                    netns_manager.add_gateway(ns_temp, old_id_new_linklocal, w0.peer_linklocal, old_id_new_dev);
                }
            }
            return new_identity.id;
        }

        public void add_arc_identity(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid, string peer_mac, string peer_linklocal)
        {
            add_in_identity_arcs(id, arc, peer_nodeid, peer_mac, peer_linklocal);
            // Do we need to add a gateway with netns-manager?
            if ((! main_id.id.equals(id)) || (peer_linklocal != arc.get_peer_linklocal()))
            {
                string ns = namespaces[@"$(id.id)"];
                string dev = arc.get_dev();
                string pseudodev = handled_nics[@"$(id.id)-$(dev)"].dev;
                string linklocal = handled_nics[@"$(id.id)-$(dev)"].linklocal;
                netns_manager.add_gateway(ns, linklocal, peer_linklocal, pseudodev);
            }
        }

        public void remove_arc_identity(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
        {
            IdentityArc? to_remove = get_from_identity_arcs(id, arc, peer_nodeid);
            if (to_remove == null) return;
            if (main_id.id.equals(id) && to_remove.peer_linklocal == arc.get_peer_linklocal())
                error("Trying to force remove an identity-arc between main identities.");
            string k = key_for_identity_arcs(id, arc);
            identity_arcs[k].remove(to_remove);
            // remove a gateway with netns-manager
            string ns = namespaces[@"$(id.id)"];
            string dev = arc.get_dev();
            string pseudodev = handled_nics[@"$(id.id)-$(dev)"].dev;
            string linklocal = handled_nics[@"$(id.id)-$(dev)"].linklocal;
            netns_manager.remove_gateway(ns, linklocal, to_remove.peer_linklocal, pseudodev);
        }

        public void remove_identity(NodeID _id)
        {
            Identity id = find_identity(_id);
            error("not implemented yet");
        }

        /* Signals
         */

        public signal void identity_arc_added(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc);
        public signal void identity_arc_changed(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc);
        public signal void identity_arc_removed(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid);

        /* Remotable methods
         */

        public IIdentityID get_peer_main_id (CallerInfo? caller = null)
        {
            NodeIDAsIdentityID ret = new NodeIDAsIdentityID();
            ret.id = main_id.id;
            return ret;
        }

        public IDuplicationData? match_duplication
        (int migration_id, IIdentityID peer_id, IIdentityID old_id, IIdentityID new_id,
         string old_id_new_mac, string old_id_new_linklocal, CallerInfo? caller = null)
        {
            if (caller == null) tasklet.exit_tasklet(null);
            IIdmgmtArc? arc = stub_factory.get_arc(caller);
            if (arc == null) tasklet.exit_tasklet(null);
            if (! (peer_id is NodeIDAsIdentityID)) tasklet.exit_tasklet(null);
            if (! (old_id is NodeIDAsIdentityID)) tasklet.exit_tasklet(null);
            if (! (new_id is NodeIDAsIdentityID)) tasklet.exit_tasklet(null);
            NodeID my_old_id = ((NodeIDAsIdentityID)peer_id).id;
            NodeID my_peer_old_id = ((NodeIDAsIdentityID)old_id).id;
            NodeID my_peer_new_id = ((NodeIDAsIdentityID)new_id).id;
            string my_peer_old_id_new_mac = old_id_new_mac;
            string my_peer_old_id_new_linklocal = old_id_new_linklocal;
            MigrationData? migration_data = null;
            foreach (MigrationData pending_migration in pending_migrations)
            {
                if (pending_migration.old_id.equals(my_old_id) &&
                    pending_migration.migration_id == migration_id)
                {
                    migration_data = pending_migration;
                    break;
                }
            }
            if (migration_data != null)
            {
                while (! migration_data.ready) tasklet.ms_wait(50);
                string ir_dev = arc.get_dev();
                DuplicationData ret = new DuplicationData();
                ret.peer_new_id = migration_data.new_id;
                ret.peer_old_id_new_mac = migration_data.devices[ir_dev].old_id_new_mac;
                ret.peer_old_id_new_linklocal = migration_data.devices[ir_dev].old_id_new_linklocal;
                return ret;
            }
            else
            {
                // immediately answer <null> and in a tasklet add the new identity-arc.
                NeighbourMigratedTasklet ts = new NeighbourMigratedTasklet();
                ts.mgr = this;
                ts.my_id = my_old_id; // in this case my id remains invariated
                ts.my_peer_old_id = my_peer_old_id;
                ts.my_peer_new_id = my_peer_new_id;
                ts.my_peer_old_id_new_mac = my_peer_old_id_new_mac;
                ts.my_peer_old_id_new_linklocal = my_peer_old_id_new_linklocal;
                ts.arc = arc;
                tasklet.spawn(ts);
                return null;
            }
        }
        private void neighbour_migrated
        (NodeID my_id,
         NodeID my_peer_old_id,
         NodeID my_peer_new_id,
         string my_peer_old_id_new_mac,
         string my_peer_old_id_new_linklocal,
         IIdmgmtArc arc)
        {
            // Search old identity-arc
            IdentityArc? old_identity_arc = get_from_identity_arcs(my_id, arc, my_peer_old_id);
            if (old_identity_arc == null) return;
            // Add new identity-arc
            add_in_identity_arcs(my_id, arc, my_peer_new_id,
                                 old_identity_arc.peer_mac, old_identity_arc.peer_linklocal);
            // Modify old identity-arc
            old_identity_arc.peer_linklocal = my_peer_old_id_new_linklocal;
            old_identity_arc.peer_mac = my_peer_old_id_new_mac;
            identity_arc_changed(arc, my_id, old_identity_arc);
            // Add direct route to gateway from the link-local of my identity for this arc
            //  to the updated peer-link-local of the old identity-arc.
            string ns = namespaces[@"$(my_id.id)"];
            string dev = arc.get_dev();
            string pseudodev = handled_nics[@"$(my_id.id)-$(dev)"].dev;
            string linklocal = handled_nics[@"$(my_id.id)-$(dev)"].linklocal;
            string peer_linklocal = old_identity_arc.peer_linklocal;
            netns_manager.add_gateway(ns, linklocal, peer_linklocal, pseudodev);
        }
        private class NeighbourMigratedTasklet : Object, ITaskletSpawnable
        {
            public IdentityManager mgr;
            public NodeID my_id;
            public NodeID my_peer_old_id;
            public NodeID my_peer_new_id;
            public string my_peer_old_id_new_mac;
            public string my_peer_old_id_new_linklocal;
            public IIdmgmtArc arc;
            public void * func()
            {
                mgr.neighbour_migrated(my_id,
                                       my_peer_old_id,
                                       my_peer_new_id,
                                       my_peer_old_id_new_mac,
                                       my_peer_old_id_new_linklocal,
                                       arc);
                return null;
            }
        }
    }

    internal class Identity : Object
    {
        public NodeID id;
        public Identity()
        {
            id = new NodeID(Random.int_range(1, int.MAX));
            modules = new HashMap<string, Object>();
        }

        public string to_string()
        {
            return @"$(id.id)";
        }

        public HashMap<string, Object> modules;
    }

    internal class HandledNic : Object
    {
        public string dev;
        public string mac;
        public string linklocal;
    }

    internal class IdentityArc : Object, IIdmgmtIdentityArc
    {
        public NodeID peer_nodeid;
        public string peer_mac;
        public string peer_linklocal;

        public NodeID get_peer_nodeid()
        {
            return peer_nodeid;
        }

        public string get_peer_mac()
        {
            return peer_mac;
        }

        public string get_peer_linklocal()
        {
            return peer_linklocal;
        }

        public IdentityArc copy()
        {
            IdentityArc ret = new IdentityArc();
            ret.peer_nodeid = peer_nodeid;
            ret.peer_mac = peer_mac;
            ret.peer_linklocal = peer_linklocal;
            return ret;
        }
    }

    internal class NodeIDAsIdentityID : Object, IIdentityID
    {
        public NodeID id {get; set;}
    }

    internal class DuplicationData : Object, IDuplicationData
    {
        public NodeID peer_new_id {get; set;}
        public string peer_old_id_new_mac {get; set;}
        public string peer_old_id_new_linklocal {get; set;}
    }

    internal class MigrationData : Object
    {
        public MigrationData()
        {
            devices = new HashMap<string, MigrationDeviceData>();
        }

        public bool ready;
        public int migration_id;
        public NodeID old_id;
        public NodeID new_id;
        public HashMap<string, MigrationDeviceData> devices;
    }

    internal class MigrationDeviceData : Object
    {
        public string old_id_new_dev;
        public string old_id_new_mac;
        public string old_id_new_linklocal;
    }
}

