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
    }

    public interface IIdmgmtArc : Object
    {
        public abstract string get_dev();
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
            error("not implemented yet");
        }

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

        /* Remotable methods
         */

        public IDuplicationData? match_duplication
        (int migration_id, IIdentityID peer_id, IIdentityID old_id, IIdentityID new_id,
         string old_id_new_mac, string old_id_new_linklocal, CallerInfo? caller = null)
        {
            error("not implemented yet");
        }
    }

    internal class Identity : Object
    {
        public NodeID id;
        public string to_string()
        {
            error("not implemented yet");
        }
    }

    internal class HandledNic : Object
    {
        public string dev;
        public string mac;
        public string linklocal;
    }

    internal class IdentityArc : Object, IIdmgmtIdentityArc
    {
        public NodeID nodeid;
        public string mac;
        public string linklocal;

        public NodeID get_peer_nodeid()
        {
            return nodeid;
        }

        public string get_peer_mac()
        {
            return mac;
        }

        public string get_peer_linklocal()
        {
            return linklocal;
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
}

