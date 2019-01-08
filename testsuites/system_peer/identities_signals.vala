using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    void identities_identity_arc_added(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, IIdmgmtIdentityArc? prev_id_arc)
    {
        warning("unused signal identities_identity_arc_added");
    }

    void identities_identity_arc_changed(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, bool only_neighbour_migrated)
    {
        warning("unused signal identities_identity_arc_changed");
    }

    void identities_identity_arc_removing(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        warning("unused signal identities_identity_arc_removing");
    }

    void identities_identity_arc_removed(IIdmgmtArc arc, NodeID id, NodeID peer_nodeid)
    {
        warning("unused signal identities_identity_arc_removed");
    }

    void identities_arc_removed(IIdmgmtArc arc)
    {
        // The module Identities has removed an arc. The user (ntkd) should actually remove the arc (from Neighborhood).
        print(@"Signal identities_arc_removed: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        arcs.remove((IdmgmtArc)arc);
    }
}
