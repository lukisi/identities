using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    class IdmgmtNetnsManager : Object, IIdmgmtNetnsManager
    {
        public void create_namespace(string ns)
        {
            assert(ns != "");
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"add", @"$(ns)"}));
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"sysctl", @"net.ipv4.ip_forward=1"}));
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"sysctl", @"net.ipv4.conf.all.rp_filter=0"}));
        }

        public void create_pseudodev(string dev, string ns, string pseudo_dev, out string pseudo_mac)
        {
            assert(ns != "");
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"link", @"add", @"dev", @"$(pseudo_dev)", @"link", @"$(dev)", @"type", @"macvlan"}));
            // (optional) set pseudo-random MAC
            string newmac = "4E";
            for (int i = 0; i < 5; i++)
            {
                uint8 b = (uint8)PRNGen.int_range(0, 256);
                string sb = b.to_string("%02x").up();
                newmac += @":$(sb)";
            }
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"link", @"set", @"dev", @"$(pseudo_dev)", @"address", @"$(newmac)"}));
            pseudo_mac = macgetter.get_mac(pseudo_dev).up();
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"link", @"set", @"dev", @"$(pseudo_dev)", @"netns", @"$(ns)"}));
            // disable rp_filter
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"sysctl", @"net.ipv4.conf.$(pseudo_dev).rp_filter=0"}));
            // arp policies
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"sysctl", @"net.ipv4.conf.$(pseudo_dev).arp_ignore=1"}));
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"sysctl", @"net.ipv4.conf.$(pseudo_dev).arp_announce=2"}));
            // up
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)",
                @"ip", @"link", @"set", @"dev", @"$(pseudo_dev)", @"up"}));
        }

        public void add_address(string ns, string pseudo_dev, string linklocal)
        {
            // ns may be empty-string.
            ArrayList<string> argv = new ArrayList<string>();
            if (ns != "") argv.add_all_array({@"ip", @"netns", @"exec", @"$(ns)"});
            argv.add_all_array({
                @"ip", @"address", @"add", @"$(linklocal)", @"dev", @"$(pseudo_dev)"});
            cm.single_command(argv);
        }

        public void add_gateway(string ns, string linklocal_src, string linklocal_dst, string dev)
        {
            // ns may be empty-string.
            ArrayList<string> argv = new ArrayList<string>();
            if (ns != "") argv.add_all_array({@"ip", @"netns", @"exec", @"$(ns)"});
            argv.add_all_array({
                @"ip", @"route", @"add", @"$(linklocal_dst)", @"dev", @"$(dev)", @"src", @"$(linklocal_src)"});
            cm.single_command(argv);
        }

        public void remove_gateway(string ns, string linklocal_src, string linklocal_dst, string dev)
        {
            // ns may be empty-string.
            ArrayList<string> argv = new ArrayList<string>();
            if (ns != "") argv.add_all_array({@"ip", @"netns", @"exec", @"$(ns)"});
            argv.add_all_array({
                @"ip", @"route", @"del", @"$(linklocal_dst)", @"dev", @"$(dev)", @"src", @"$(linklocal_src)"});
            cm.single_command(argv);
        }

        public void flush_table(string ns)
        {
            assert(ns != "");
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)", @"ip", @"route", @"flush", @"table", @"main"}));
        }

        public void delete_pseudodev(string ns, string pseudo_dev)
        {
            assert(ns != "");
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"exec", @"$(ns)", @"ip", @"link", @"delete", @"$(pseudo_dev)", @"type", @"macvlan"}));
        }

        public void delete_namespace(string ns)
        {
            assert(ns != "");
            cm.single_command(new ArrayList<string>.wrap({
                @"ip", @"netns", @"del", @"$(ns)"}));
        }
    }

    class IdmgmtStubFactory : Object, IIdmgmtStubFactory
    {
        public IIdmgmtArc? get_arc(CallerInfo rpc_caller)
        {
            NodeArc? node_arc = skeleton_factory.from_caller_get_nodearc(rpc_caller);
            if (node_arc != null) return node_arc.i_arc;
            return null;
        }

        public IIdentityManagerStub get_stub(IIdmgmtArc arc)
        {
            IdmgmtArc _arc = (IdmgmtArc)arc;
            IAddressManagerStub addrstub = stub_factory.get_stub_whole_node_unicast(_arc);
            IdentityManagerStubHolder ret = new IdentityManagerStubHolder(addrstub);
            return ret;
        }
    }

    class IdmgmtArc : Object, IIdmgmtArc
    {
        public IdmgmtArc(string my_dev, string my_mac, int /*NeighborhoodNodeID*/ peer_id, string peer_mac, string peer_linklocal)
        {
            this.my_dev = my_dev;
            this.my_mac = my_mac;
            this.peer_id = peer_id;
            this.peer_mac = peer_mac;
            this.peer_linklocal = peer_linklocal;
        }
        public string my_dev;
        public string my_mac;
        public int /*NeighborhoodNodeID*/ peer_id;
        public string peer_mac;
        public string peer_linklocal;

        public string get_dev()
        {
            return my_dev;
        }

        public string get_peer_mac()
        {
            return peer_mac;
        }

        public string get_peer_linklocal()
        {
            return peer_linklocal;
        }
    }
}
