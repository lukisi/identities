using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    class SkeletonFactory : Object
    {
        public SkeletonFactory()
        {
            this.node_skeleton = new NodeSkeleton();
            dlg = new ServerDelegate(this);
        }

        private NodeSkeleton node_skeleton;
        public int /*NeighborhoodNodeID*/ whole_node_id {
            get {
                return node_skeleton.id;
            }
            set {
                node_skeleton.id = value;
            }
        }
        // private List<IdentitySkeleton>...

        private ServerDelegate dlg;
        HashMap<string,IListenerHandle> handles_by_listen_pathname;

        public void start_stream_system_listen(string listen_pathname)
        {
            IErrorHandler stream_system_err = new ServerErrorHandler(@"for stream_system_listen $(listen_pathname)");
            if (handles_by_listen_pathname == null) handles_by_listen_pathname = new HashMap<string,IListenerHandle>();
            handles_by_listen_pathname[listen_pathname] = stream_system_listen(dlg, stream_system_err, listen_pathname);
        }
        public void stop_stream_system_listen(string listen_pathname)
        {
            assert(handles_by_listen_pathname != null);
            assert(handles_by_listen_pathname.has_key(listen_pathname));
            IListenerHandle lh = handles_by_listen_pathname[listen_pathname];
            lh.kill();
            handles_by_listen_pathname.unset(listen_pathname);
        }

        [NoReturn]
        private void abort_tasklet(string msg_warning)
        {
            warning(msg_warning);
            tasklet.exit_tasklet();
        }

        private IAddressManagerSkeleton? get_dispatcher(StreamCallerInfo caller_info)
        {
            // in this test we have only WholeNodeUnicastID
            if (! (caller_info.source_id is WholeNodeSourceID)) abort_tasklet(@"Bad caller_info.source_id");
            WholeNodeSourceID _source_id = (WholeNodeSourceID)caller_info.source_id;
            int /*NeighborhoodNodeID*/ neighbour_id = _source_id.id;
            if (! (caller_info.unicast_id is WholeNodeUnicastID)) abort_tasklet(@"Bad caller_info.unicast_id");
            WholeNodeUnicastID _unicast_id = (WholeNodeUnicastID)caller_info.unicast_id;
            int /*NeighborhoodNodeID*/ my_id = _unicast_id.neighbour_id;
            if (my_id != node_skeleton.id) abort_tasklet(@"caller_info.unicast_id is not me.");
            return node_skeleton;
        }

        public IdmgmtArc?
        from_caller_get_nodearc(CallerInfo rpc_caller)
        {
            // in this test we have only WholeNodeSourceID
            StreamCallerInfo caller_info = (StreamCallerInfo)rpc_caller;
            if (! (caller_info.source_id is WholeNodeSourceID)) abort_tasklet(@"Bad caller_info.source_id");
            WholeNodeSourceID _source_id = (WholeNodeSourceID)caller_info.source_id;
            int /*NeighborhoodNodeID*/ neighbour_id = _source_id.id;
            Listener listener = caller_info.listener;
            assert(listener is StreamSystemListener);
            string listen_pathname = ((StreamSystemListener)listener).listen_pathname;
            assert(caller_info.src_nic is NeighbourSrcNic);
            NeighbourSrcNic src_nic = (NeighbourSrcNic)caller_info.src_nic;
            string neighbour_mac = src_nic.mac;
            foreach (IdmgmtArc arc in arcs)
            {
                PseudoNetworkInterface arc_my_pseudonic = pseudonic_map[arc.my_dev];
                if (arc.peer_id == neighbour_id)
                if (arc.peer_mac == neighbour_mac)
                if (arc_my_pseudonic.st_listen_pathname == listen_pathname)
                    return arc;
            }
            return null;
        }

        // from_caller_get_identityarc not in this test

        private class ServerErrorHandler : Object, IErrorHandler
        {
            private string name;
            public ServerErrorHandler(string name)
            {
                this.name = name;
            }

            public void error_handler(Error e)
            {
                error(@"ServerErrorHandler '$(name)': $(e.message)");
            }
        }

        private class ServerDelegate : Object, IDelegate
        {
            public ServerDelegate(SkeletonFactory skeleton_factory)
            {
                this.skeleton_factory = skeleton_factory;
            }
            private SkeletonFactory skeleton_factory;

            public Gee.List<IAddressManagerSkeleton> get_addr_set(CallerInfo caller_info)
            {
                if (caller_info is StreamCallerInfo)
                {
                    StreamCallerInfo c = (StreamCallerInfo)caller_info;
                    var ret = new ArrayList<IAddressManagerSkeleton>();
                    IAddressManagerSkeleton? d = skeleton_factory.get_dispatcher(c);
                    if (d != null) ret.add(d);
                    return ret;
                }
                else if (caller_info is DatagramCallerInfo)
                {
                    error("not in this test");
                }
                else
                {
                    error(@"Unexpected class $(caller_info.get_type().name())");
                }
            }
        }

        /* A skeleton for the whole-node remotable methods
         */
        private class NodeSkeleton : Object, IAddressManagerSkeleton
        {
            public int /*NeighborhoodNodeID*/ id;

            public unowned INeighborhoodManagerSkeleton
            neighborhood_manager_getter()
            {
                error("not in this test");
            }

            protected unowned IIdentityManagerSkeleton
            identity_manager_getter()
            {
                // global var identity_mgr is IdentityManager, which is a IIdentityManagerSkeleton
                return identity_mgr;
            }

            public unowned IQspnManagerSkeleton
            qspn_manager_getter()
            {
                error("not in this test");
            }

            public unowned IPeersManagerSkeleton
            peers_manager_getter()
            {
                error("not in this test");
            }

            public unowned ICoordinatorManagerSkeleton
            coordinator_manager_getter()
            {
                error("not in this test");
            }

            public unowned IHookingManagerSkeleton
            hooking_manager_getter()
            {
                error("not in this test");
            }

            /* TODO in ntkdrpc
            public unowned IAndnaManagerSkeleton
            andna_manager_getter()
            {
                error("not in this test");
            }
            */
        }
    }
}