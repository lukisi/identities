using Netsukuku;
using Netsukuku.Identities;

namespace SystemPeer
{
    public class WholeNodeSourceID : Object, ISourceID
    {
        public WholeNodeSourceID(int /*NeighborhoodNodeID*/ id)
        {
            this.id = id;
        }
        public int /*NeighborhoodNodeID*/ id {get; set;}
    }

    public class WholeNodeUnicastID : Object, IUnicastID
    {
        public WholeNodeUnicastID(int /*NeighborhoodNodeID*/ neighbour_id)
        {
            this.neighbour_id = neighbour_id;
        }
        public int /*NeighborhoodNodeID*/ neighbour_id {get; set;}
    }

    public class NeighbourSrcNic : Object, ISrcNic
    {
        public NeighbourSrcNic(string mac)
        {
            this.mac = mac;
        }
        public string mac {get; set;}
    }
}