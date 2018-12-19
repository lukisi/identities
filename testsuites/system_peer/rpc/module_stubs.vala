using Gee;
using Netsukuku;
using Netsukuku.Identities;
using TaskletSystem;

namespace SystemPeer
{
    class IdentityManagerStubHolder : Object, IIdentityManagerStub
    {
        public IdentityManagerStubHolder(IAddressManagerStub addr)
        {
            this.addr = addr;
        }
        private IAddressManagerStub addr;

        public IIdentityID get_peer_main_id()
        throws StubError, DeserializeError
        {
            return addr.identity_manager.get_peer_main_id();
        }

        public IDuplicationData? match_duplication
        (int migration_id, IIdentityID peer_id, IIdentityID old_id,
        IIdentityID new_id, string old_id_new_mac, string old_id_new_linklocal)
        throws StubError, DeserializeError
        {
            return addr.identity_manager.match_duplication
                (migration_id, peer_id, old_id,
                 new_id, old_id_new_mac, old_id_new_linklocal);
        }

        public void notify_identity_arc_removed(IIdentityID peer_id, IIdentityID my_id)
        throws StubError, DeserializeError
        {
            addr.identity_manager.notify_identity_arc_removed(peer_id, my_id);
        }
    }
}