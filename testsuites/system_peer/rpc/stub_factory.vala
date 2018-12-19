using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    class StubFactory : Object
    {
        public StubFactory()
        {
        }

        /* Get a stub for a whole-node unicast request.
         */
        public IAddressManagerStub
        get_stub_whole_node_unicast(
            IdmgmtArc arc,
            bool wait_reply=true)
        {
            WholeNodeSourceID source_id = new WholeNodeSourceID(skeleton_factory.whole_node_id);
            WholeNodeUnicastID unicast_id = new WholeNodeUnicastID(arc.peer_id);
            NeighbourSrcNic src_nic = new NeighbourSrcNic(arc.my_mac);
            string send_pathname = @"conn_$(arc.peer_linklocal)";
            return get_addr_stream_system(send_pathname, source_id, unicast_id, src_nic, wait_reply);
        }
    }
}
