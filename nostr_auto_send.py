#!/usr/bin/env python3
"""
Script automatisé pour envoyer des événements NOSTR
Conçu pour être utilisé par microledger.me.sh
"""
import sys
import json
import asyncio
import argparse
from pynostr.event import Event, EventKind
from pynostr.relay_manager import RelayManager
from pynostr.key import PrivateKey

DEFAULT_RELAYS = ["wss://relay.copylaradio.com"]
CONNECT_TIMEOUT = 10
PUBLISH_TIMEOUT = 30

async def send_nostr_event_auto(private_key_nsec: str, content: str, relays: list = None):
    """Envoie un événement NOSTR de manière automatisée"""
    if relays is None:
        relays = DEFAULT_RELAYS
    
    try:
        print(f"🔌 Connexion aux relais: {', '.join(relays)}")
        relay_manager = RelayManager()
        
        for relay_url in relays:
            relay_manager.add_relay(relay_url)
        
        print("⏳ Ouverture des connexions...")
        relay_manager.open_connections()
        
        # Attendre la connexion
        await asyncio.sleep(2)
        
        connected_count = sum(1 for r_obj in relay_manager.relays.values() if r_obj.connected)
        if connected_count == 0:
            print("❌ Aucune connexion établie")
            return False
        
        print(f"✅ Connecté à {connected_count}/{len(relays)} relais")
        
        # Créer et signer l'événement
        priv_key_obj = PrivateKey.from_nsec(private_key_nsec)
        event = Event(
            kind=EventKind.TEXT_NOTE, 
            content=content, 
            tags=[["t", "frd"], ["t", "FRD"], ["t", "ipfs"], ["t", "knowledge"]], 
            pubkey=priv_key_obj.public_key.hex()
        )
        priv_key_obj.sign_event(event)
        
        print(f"📝 Événement créé: {event.id}")
        print(f"📤 Publication...")
        
        # Publier l'événement
        relay_manager.publish_event(event)
        
        # Attendre les réponses
        await asyncio.sleep(3)
        
        relay_manager.close_connections()
        
        print("✅ Événement publié avec succès")
        return True
        
    except Exception as e:
        print(f"❌ Erreur: {e}")
        if 'relay_manager' in locals():
            relay_manager.close_connections()
        return False

async def main():
    parser = argparse.ArgumentParser(description='Envoi automatisé d\'événements NOSTR')
    parser.add_argument('--nsec', required=True, help='Clé privée NOSTR (nsec)')
    parser.add_argument('--content', required=True, help='Contenu du message')
    parser.add_argument('--relays', nargs='+', default=DEFAULT_RELAYS, help='Liste des relais')
    
    args = parser.parse_args()
    
    success = await send_nostr_event_auto(args.nsec, args.content, args.relays)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    asyncio.run(main())
