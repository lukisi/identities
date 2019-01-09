using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    void identities_identity_arc_added(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, IIdmgmtIdentityArc? prev_id_arc)
    {
        tester_events.add(@"Identities:Signal:identity_arc_added");
        print(@"Identities: Signal identity_arc_added:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        if (prev_id_arc == null)
            print(@"    prev_id_arc: null\n");
        else
            print(@"    prev_id_arc: nodeid $(prev_id_arc.get_peer_nodeid().id) peer_mac $(prev_id_arc.get_peer_mac()) peer_linklocal $(prev_id_arc.get_peer_linklocal())\n");
    }

    void identities_identity_arc_changed(IIdmgmtArc arc, NodeID id, IIdmgmtIdentityArc id_arc, bool only_neighbour_migrated)
    {
        tester_events.add(@"Identities:Signal:identity_arc_changed");
        print(@"Identities: Signal identity_arc_changed:\n");
        print(@"    arc: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        print(@"    my identity: nodeid $(id.id)\n");
        print(@"    id_arc: nodeid $(id_arc.get_peer_nodeid().id) peer_mac $(id_arc.get_peer_mac()) peer_linklocal $(id_arc.get_peer_linklocal())\n");
        print(@"    only_neighbour_migrated: $(only_neighbour_migrated)\n");
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
        tester_events.add(@"Identities:Signal:arc_removed");
        // The module Identities has removed an arc. The user (ntkd) should actually remove the arc (from Neighborhood).
        print(@"Identities: Signal arc_removed: dev $(arc.get_dev()) peer_mac $(arc.get_peer_mac()) peer_linklocal $(arc.get_peer_linklocal())\n");
        arcs.remove((IdmgmtArc)arc);
    }
}
