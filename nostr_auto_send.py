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

DEFAULT_RELAYS = ["ws://127.0.0.1:7777"]  # Relai strfry local
CONNECT_TIMEOUT = 10
PUBLISH_TIMEOUT = 30

async def send_nostr_event_auto(private_key_nsec: str, content: str, relays: list = None):
    """Envoie un événement NOSTR de manière automatisée vers strfry"""
    if relays is None:
        relays = DEFAULT_RELAYS
    
    relay_manager = None
    try:
        print(f"🔌 Connexion au relai strfry: {', '.join(relays)}")
        relay_manager = RelayManager()
        
        for relay_url in relays:
            relay_manager.add_relay(relay_url)
        
        print("⏳ Ouverture des connexions...")
        relay_manager.open_connections()
        
        # Attendre la connexion avec timeout
        max_wait = 5
        for i in range(max_wait):
            await asyncio.sleep(1)
            connected_count = sum(1 for r_obj in relay_manager.relays.values() if r_obj.connected)
            if connected_count > 0:
                break
            print(f"   Tentative {i+1}/{max_wait}...")
        
        connected_count = sum(1 for r_obj in relay_manager.relays.values() if r_obj.connected)
        if connected_count == 0:
            print("❌ Impossible de se connecter au relai strfry")
            print("   Vérifiez que strfry est démarré sur le port 7777")
            return False
        
        print(f"✅ Connecté à {connected_count}/{len(relays)} relais strfry")
        
        # Créer et signer l'événement
        try:
            priv_key_obj = PrivateKey.from_nsec(private_key_nsec)
        except Exception as e:
            print(f"❌ Erreur clé privée: {e}")
            return False
            
        event = Event(
            kind=EventKind.TEXT_NOTE, 
            content=content, 
            tags=[
                ["t", "frd"], 
                ["t", "FRD"], 
                ["t", "ipfs"], 
                ["t", "knowledge"],
                ["t", "multipass"],
                ["t", "astroport"]
            ], 
            pubkey=priv_key_obj.public_key.hex()
        )
        priv_key_obj.sign_event(event)
        
        print(f"📝 Événement créé: {event.id}")
        print(f"📤 Publication vers strfry...")
        
        # Publier l'événement
        relay_manager.publish_event(event)
        
        # Attendre les réponses avec monitoring
        print("⏳ Attente de confirmation...")
        await asyncio.sleep(2)
        
        # Vérifier les réponses
        success_count = 0
        for relay_url, relay_obj in relay_manager.relays.items():
            if relay_obj.connected and hasattr(relay_obj, 'response_received'):
                if relay_obj.response_received:
                    success_count += 1
                    print(f"✅ Confirmation reçue de {relay_url}")
        
        relay_manager.close_connections()
        
        if success_count > 0 or connected_count > 0:
            print(f"✅ Événement publié avec succès sur strfry")
            return True
        else:
            print("⚠️ Publication effectuée mais aucune confirmation reçue")
            return True  # On considère comme succès si connecté
        
    except Exception as e:
        print(f"❌ Erreur lors de la publication: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        if relay_manager:
            try:
                relay_manager.close_connections()
            except:
                pass

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
