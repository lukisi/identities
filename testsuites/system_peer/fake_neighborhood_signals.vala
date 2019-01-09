using Gee;
using TaskletSystem;

namespace SystemPeer
{
    // In response to the signal neighborhood:arc_added the app shall add arc to module Identities
    IdmgmtArc fake_neighborhood_arc_added(string my_dev, string my_mac, int /*NeighborhoodNodeID*/ peer_id, string peer_mac, string peer_linklocal)
    {
        IdmgmtArc arc = new IdmgmtArc(my_dev, my_mac, peer_id, peer_mac, peer_linklocal);
        arcs.add(arc);
        identity_mgr.add_arc(arc);
        return arc;
    }

    // In response to the signal neighborhood:arc_removing and arc_removed the app shall remove arc from module Identities
    void fake_neighborhood_arc_removing_then_removed(IdmgmtArc arc)
    {
        identity_mgr.remove_arc(arc);
        arcs.remove(arc);
    }
}