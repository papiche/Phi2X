#!/usr/bin/env python3
"""
Script simplifié pour envoyer des événements NOSTR vers strfry
Utilise websockets directement pour éviter les conflits d'event loop
"""
import sys
import json
import time
import hashlib
import hmac
import argparse
import websocket
from pynostr.key import PrivateKey

def create_nostr_event(private_key_nsec: str, content: str):
    """Crée un événement NOSTR signé"""
    try:
        # Nettoyer la clé privée (extraire seulement la partie nsec)
        if private_key_nsec.startswith('NSEC='):
            private_key_nsec = private_key_nsec[5:]
        
        # Extraire seulement la partie nsec (avant le premier point-virgule)
        if ';' in private_key_nsec:
            private_key_nsec = private_key_nsec.split(';')[0]
        
        private_key_nsec = private_key_nsec.strip()
        
        # Créer la clé privée
        priv_key_obj = PrivateKey.from_nsec(private_key_nsec)
        
        # Créer l'événement
        event = {
            "kind": 1,  # TEXT_NOTE
            "created_at": int(time.time()),
            "tags": [
                ["t", "frd"],
                ["t", "FRD"], 
                ["t", "ipfs"],
                ["t", "knowledge"],
                ["t", "multipass"],
                ["t", "astroport"]
            ],
            "content": content,
            "pubkey": priv_key_obj.public_key.hex()
        }
        
        # Calculer l'ID de l'événement
        event_json = json.dumps([
            0,
            event["pubkey"],
            event["created_at"],
            event["kind"],
            event["tags"],
            event["content"]
        ], separators=(',', ':'), ensure_ascii=False)
        
        event_id = hashlib.sha256(event_json.encode('utf-8')).hexdigest()
        event["id"] = event_id
        
        # Signer l'événement
        signature = priv_key_obj.sign(bytes.fromhex(event_id)).hex()
        event["sig"] = signature
        
        return event
        
    except Exception as e:
        print(f"❌ Erreur création événement: {e}")
        return None

def send_to_relay(event, relay_url="ws://127.0.0.1:7777"):
    """Envoie l'événement à un relai NOSTR via WebSocket"""
    success = False
    error_msg = ""
    
    def on_message(ws, message):
        nonlocal success
        try:
            data = json.loads(message)
            print(f"📥 Réponse strfry: {data}")
            
            # Vérifier si c'est une réponse OK
            if isinstance(data, list) and len(data) >= 3 and data[0] == "OK":
                if data[2]:  # Success
                    print(f"✅ Événement accepté par strfry: {data[1]}")
                    success = True
                else:
                    print(f"❌ Événement rejeté par strfry: {data[3] if len(data) > 3 else 'Raison inconnue'}")
            
        except json.JSONDecodeError:
            print(f"⚠️ Réponse non-JSON: {message}")
    
    def on_error(ws, error):
        nonlocal error_msg
        error_msg = str(error)
        print(f"❌ Erreur WebSocket: {error}")
    
    def on_close(ws, close_status_code, close_msg):
        print(f"🔌 Connexion fermée (code: {close_status_code})")
    
    def on_open(ws):
        relay_name = "strfry local" if "127.0.0.1" in relay_url else "relay distant"
        print(f"✅ Connecté au {relay_name}: {relay_url}")
        
        # Envoyer l'événement
        event_msg = json.dumps(["EVENT", event])
        print(f"📤 Envoi événement: {event['id'][:16]}...")
        ws.send(event_msg)
        
        # Fermer après 3 secondes
        def close_connection():
            time.sleep(3)
            ws.close()
        
        import threading
        threading.Thread(target=close_connection, daemon=True).start()
    
    try:
        relay_name = "strfry local" if "127.0.0.1" in relay_url else "relay distant"
        print(f"🔌 Connexion au {relay_name}: {relay_url}")
        
        # Créer la connexion WebSocket
        ws = websocket.WebSocketApp(
            relay_url,
            on_open=on_open,
            on_message=on_message,
            on_error=on_error,
            on_close=on_close
        )
        
        # Lancer la connexion avec timeout
        ws.run_forever(ping_interval=30, ping_timeout=10)
        
        return success
        
    except Exception as e:
        print(f"❌ Erreur connexion {relay_name}: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Envoi vers relais NOSTR multiples')
    parser.add_argument('--nsec', required=True, help='Clé privée NOSTR (nsec)')
    parser.add_argument('--content', required=True, help='Contenu du message')
    parser.add_argument('--relay', default='ws://127.0.0.1:7777', help='URL du relai principal')
    
    args = parser.parse_args()
    
    print("📡 Publication NOSTR vers relais multiples")
    print(f"🔑 Clé: {args.nsec[:12]}...")
    print(f"📝 Contenu: {args.content[:50]}...")
    
    # Créer l'événement
    event = create_nostr_event(args.nsec, args.content)
    if not event:
        sys.exit(1)
    
    print(f"📝 Événement créé: {event['id']}")
    
    # Liste des relais à utiliser
    relays = [
        args.relay,  # Relai principal (strfry local)
        "wss://relay.copylaradio.com"  # Relai distant
    ]
    
    success_count = 0
    total_relays = len(relays)
    
    # Publier sur chaque relai
    for relay_url in relays:
        print(f"\n🔄 Publication sur {relay_url}...")
        try:
            if send_to_relay(event, relay_url):
                success_count += 1
                print(f"✅ Succès sur {relay_url}")
            else:
                print(f"❌ Échec sur {relay_url}")
        except Exception as e:
            print(f"❌ Erreur sur {relay_url}: {e}")
    
    print(f"\n📊 Résultat: {success_count}/{total_relays} relais réussis")
    
    if success_count > 0:
        print("✅ Publication réussie sur au moins un relai")
        sys.exit(0)
    else:
        print("❌ Échec sur tous les relais")
        sys.exit(1)

if __name__ == "__main__":
    main()
