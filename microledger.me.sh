#!/bin/bash
################################################################################
# IPFS Evolutive Knowledge Capsule - Git Versioned Nostr Distribution
# Author: Fred (support@qo-op.com)
# Version: 1.0 - Generalist Knowledge Capsule System
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
# Tags: #frd #FRD #ipfs #nostr #knowledge #git
#
# Usage:
#   ./microledger.me.sh                # Publication normale
#   ./microledger.me.sh --reset        # Réinitialisation complète de la chaîne (avec confirmation)
#   ./microledger.me.sh --force-reset  # Réinitialisation forcée (sans confirmation)
################################################################################
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

# Gestion des paramètres
RESET_CHAIN=false
FORCE_RESET=false
if [[ "$1" == "--reset" ]]; then
    RESET_CHAIN=true
    echo "🔄 Mode RESET activé - Réinitialisation de la chaîne"
elif [[ "$1" == "--force-reset" ]]; then
    RESET_CHAIN=true
    FORCE_RESET=true
    echo "⚡ Mode FORCE-RESET activé - Réinitialisation sans confirmation"
fi

echo '
############################################################### ipfs
##  __  __ ___ ____ ____   ___    _     _____ ____   ____ _____ ____
## |  \/  |_ _/ ___|  _ \ / _ \  | |   | ____|  _ \ / ___| ____|  _ \
## | |\/| || | |   | |_) | | | | | |   |  _| | | | | |  _|  _| | |_) |
## | |  | || | |___|  _ <| |_| | | |___| |___| |_| | |_| | |___|  _ <
## |_|  |_|___\____|_| \_\\___/  |_____|_____|____/ \____|_____|_| \_\  me
##                    Capsule - IPFS+Git+Nostr Distribution
'

MOATS=$(date -u +"%Y%m%d%H%M%S%4N")

# === INITIALISATION AUTOMATIQUE ===
init_capsule() {
    echo "🚀 Initialisation de la capsule de connaissance..."
    
    # Récupération des bibliothèques FRD si nécessaire
    if [[ ! -d "${MY_PATH}/frd" ]]; then
        echo "📦 Téléchargement des bibliothèques FRD..."
        ipfs get QmY2qhDQiUUPT73UbhDRuzpAkryAZQ5xZKUcjYDRJJ5BBn -o ${MY_PATH}/
        mv ${MY_PATH}/QmY2qhDQiUUPT73UbhDRuzpAkryAZQ5xZKUcjYDRJJ5BBn ${MY_PATH}/frd
    fi
    
    # Génération de l'index.html si absent
    if [[ ! -f "${MY_PATH}/index.html" ]]; then
        echo "🌐 Génération de l'index.html..."
        generate_index_html
    fi
    
    # Création du README.md minimal si absent
    if [[ ! -f "${MY_PATH}/README.md" ]]; then
        echo "📖 Création du README.md..."
        echo "# $(basename ${MY_PATH})" > ${MY_PATH}/README.md
        echo "" >> ${MY_PATH}/README.md
        echo "> 🌐 **Capsule de Connaissance IPFS** - Distribution décentralisée via Git+IPFS+Nostr" >> ${MY_PATH}/README.md
        echo "" >> ${MY_PATH}/README.md
        echo "## 🚀 Accès" >> ${MY_PATH}/README.md
        echo "- 🌐 [Interface Web](./index.html)" >> ${MY_PATH}/README.md
        echo "- 📡 Tags Nostr: #frd #FRD" >> ${MY_PATH}/README.md
    fi
}

# === FONCTIONS ASTROPORT.ONE INTEGRATION ===

# Fonction pour détecter les MULTIPASS disponibles
detect_multipass() {
    echo "🔍 Détection des MULTIPASS disponibles..."
    
    local multipass_list=()
    local zen_dir="$HOME/.zen"
    
    # Vérifier si le répertoire .zen existe
    if [[ ! -d "$zen_dir" ]]; then
        echo "⚠️ Répertoire ~/.zen non trouvé. Astroport.ONE n'est pas installé."
        return 1
    fi
    
    # Chercher les MULTIPASS dans ~/.zen/game/nostr/
    local nostr_dir="$zen_dir/game/nostr"
    if [[ -d "$nostr_dir" ]]; then
        while IFS= read -r -d '' email_dir; do
            local email=$(basename "$email_dir")
            local nsec_file="$email_dir/.secret.nostr"
            local npub_file="$email_dir/NPUB"
            
            if [[ -f "$nsec_file" && -f "$npub_file" ]]; then
                multipass_list+=("$email")
                echo "  📧 $email"
            fi
        done < <(find "$nostr_dir" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    fi
    
    # Détecter le capitaine par défaut
    local captain_email=""
    local captain_file="$zen_dir/game/players/.current/.player"
    if [[ -f "$captain_file" ]]; then
        captain_email=$(cat "$captain_file" 2>/dev/null | tr -d '\n')
        echo "👨‍✈️ Capitaine détecté: $captain_email"
    fi
    
    if [[ ${#multipass_list[@]} -eq 0 ]]; then
        echo "❌ Aucun MULTIPASS trouvé dans ~/.zen/game/nostr/"
        return 1
    fi
    
    echo "✅ ${#multipass_list[@]} MULTIPASS détecté(s)"
    
    # Exporter les variables pour utilisation globale
    export DETECTED_MULTIPASS=("${multipass_list[@]}")
    export CAPTAIN_EMAIL="$captain_email"
    
    return 0
}

# Fonction pour sélectionner un MULTIPASS
select_multipass() {
    local selected_email=""
    
    # Détecter les MULTIPASS disponibles
    if ! detect_multipass; then
        echo "❌ Impossible de détecter les MULTIPASS"
        return 1
    fi
    
    # Si un seul MULTIPASS, le sélectionner automatiquement
    if [[ ${#DETECTED_MULTIPASS[@]} -eq 1 ]]; then
        selected_email="${DETECTED_MULTIPASS[0]}"
        echo "🎯 MULTIPASS unique sélectionné: $selected_email"
    # Si le capitaine est défini et existe dans la liste, le proposer par défaut
    elif [[ -n "$CAPTAIN_EMAIL" ]]; then
        echo ""
        echo "🔐 Sélection du signataire MULTIPASS:"
        echo "0) $CAPTAIN_EMAIL (Capitaine - par défaut)"
        
        local i=1
        for email in "${DETECTED_MULTIPASS[@]}"; do
            if [[ "$email" != "$CAPTAIN_EMAIL" ]]; then
                echo "$i) $email"
                ((i++))
            fi
        done
        
        echo ""
        read -p "Choisir le signataire (0 pour capitaine, Entrée pour défaut): " choice
        
        if [[ -z "$choice" || "$choice" == "0" ]]; then
            selected_email="$CAPTAIN_EMAIL"
        else
            # Reconstruire la liste sans le capitaine pour l'indexation
            local other_multipass=()
            for email in "${DETECTED_MULTIPASS[@]}"; do
                if [[ "$email" != "$CAPTAIN_EMAIL" ]]; then
                    other_multipass+=("$email")
                fi
            done
            
            if [[ "$choice" -gt 0 && "$choice" -le ${#other_multipass[@]} ]]; then
                selected_email="${other_multipass[$((choice-1))]}"
            else
                echo "⚠️ Choix invalide, utilisation du capitaine par défaut"
                selected_email="$CAPTAIN_EMAIL"
            fi
        fi
    else
        # Pas de capitaine défini, proposer la liste complète
        echo ""
        echo "🔐 Sélection du signataire MULTIPASS:"
        for i in "${!DETECTED_MULTIPASS[@]}"; do
            echo "$i) ${DETECTED_MULTIPASS[$i]}"
        done
        
        echo ""
        read -p "Choisir le signataire (0-$((${#DETECTED_MULTIPASS[@]}-1))): " choice
        
        if [[ "$choice" -ge 0 && "$choice" -lt ${#DETECTED_MULTIPASS[@]} ]]; then
            selected_email="${DETECTED_MULTIPASS[$choice]}"
        else
            echo "⚠️ Choix invalide, utilisation du premier MULTIPASS"
            selected_email="${DETECTED_MULTIPASS[0]}"
        fi
    fi
    
    echo "✅ MULTIPASS sélectionné: $selected_email"
    export SELECTED_MULTIPASS="$selected_email"
    
    # Récupérer les clés pour ce MULTIPASS
    local zen_dir="$HOME/.zen"
    local multipass_dir="$zen_dir/game/nostr/$selected_email"
    
    if [[ -f "$multipass_dir/.secret.nostr" ]]; then
        export MULTIPASS_NSEC_FILE="$multipass_dir/.secret.nostr"
        echo "🔑 Clé privée: $MULTIPASS_NSEC_FILE"
    fi
    
    if [[ -f "$multipass_dir/NPUB" ]]; then
        export MULTIPASS_NPUB_FILE="$multipass_dir/NPUB"
        echo "🔑 Clé publique: $MULTIPASS_NPUB_FILE"
    fi
    
    return 0
}

# Function to send NOSTR event via automated script
send_nostr_capsule_event() {
    local cid="$1"
    local project_name="$2"
    local evolution_count="$3"
    
    if [[ -z "$SELECTED_MULTIPASS" || -z "$MULTIPASS_NSEC_FILE" ]]; then
        echo "❌ MULTIPASS not selected or keys missing"
        return 1
    fi
    
    # Check if the unified nostr_send_note.py script is available
    local nostr_script="$HOME/.zen/Astroport.ONE/tools/nostr_send_note.py"
    if [[ ! -f "$nostr_script" ]]; then
        # Fallback to local script if exists
        nostr_script="${MY_PATH}/frd/nostr_strfry_send.py"
        if [[ ! -f "$nostr_script" ]]; then
            echo "❌ No Nostr sending script found"
            return 1
        fi
    fi
    
    if [[ ! -f "$MULTIPASS_NSEC_FILE" ]]; then
        echo "❌ Cannot read private key: $MULTIPASS_NSEC_FILE"
        return 1
    fi
    
    echo "📡 Sending NOSTR event to multiple relays"
    
    # Prepare the NOSTR message
    local nostr_message="📡 FRD Knowledge Capsule Published: ${project_name}

🌐 IPFS: http://127.0.0.1:8080/ipfs/${cid}/
📖 Docs: http://127.0.0.1:8080/ipfs/${cid}/index.html
🔄 Evolution: #${evolution_count}
👨‍✈️ Signed by: ${SELECTED_MULTIPASS}

#frd #FRD #ipfs #knowledge #git #nostr #multipass"
    
    echo "📤 Publishing capsule on NOSTR..."
    echo "   Signer: $SELECTED_MULTIPASS"
    echo "   CID: $cid"
    echo "   Evolution: #$evolution_count"
    
    # Prepare tags for FRD
    local tags_json='[["t","frd"],["t","FRD"],["t","ipfs"],["t","knowledge"],["t","multipass"],["t","astroport"]]'
    
    # Execute script for multi-relay publication
    # Check if using unified script or legacy script
    if [[ "$nostr_script" == *"nostr_send_note.py" ]]; then
        # Use new unified API with keyfile
        if python3 "$nostr_script" \
            --keyfile "$MULTIPASS_NSEC_FILE" \
            --content "$nostr_message" \
            --tags "$tags_json" \
            --relays "ws://127.0.0.1:7777,wss://relay.copylaradio.com"; then
            echo "✅ NOSTR event published successfully on relays"
            return 0
        else
            echo "❌ Failed to publish NOSTR on relays"
            return 1
        fi
    else
        # Use legacy API (for backwards compatibility)
        local nsec_content=$(cat "$MULTIPASS_NSEC_FILE" 2>/dev/null)
        if python3 "$nostr_script" --nsec "$nsec_content" --content "$nostr_message" --relay "ws://127.0.0.1:7777"; then
            echo "✅ NOSTR event published successfully on relays"
            return 0
        else
            echo "❌ Failed to publish NOSTR on relays"
            return 1
        fi
    fi
}

# Fonction pour ajouter une signature à la chaîne
add_signature_to_chain() {
    local cid="$1"
    local signer_email="$2"
    local action="$3"  # "publish" ou "copy"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    local signatures_file="${MY_PATH}/_signatures"
    
    # Créer le fichier de signatures s'il n'existe pas
    if [[ ! -f "$signatures_file" ]]; then
        echo "# Signatures de la chaîne FRD" > "$signatures_file"
        echo "# Format: TIMESTAMP|CID|SIGNER|ACTION" >> "$signatures_file"
    fi
    
    # Ajouter la signature
    echo "${timestamp}|${cid}|${signer_email}|${action}" >> "$signatures_file"
    
    # Copier les fichiers MULTIPASS pour le profil (seulement pour les publications)
    if [[ "$action" == "publish" ]]; then
        local multipass_dir="${MY_PATH}/frd/multipass"
        mkdir -p "$multipass_dir"
        
        # Copier la clé HEX (priorité)
        local hex_file="$HOME/.zen/game/nostr/${signer_email}/HEX"
        if [[ -f "$hex_file" ]]; then
            cp "$hex_file" "${multipass_dir}/${signer_email}.hex" 2>/dev/null && \
                echo "🔑 Clé HEX copiée pour $signer_email"
        fi
        
        # Copier aussi la NPUB (fallback)
        local npub_file="$HOME/.zen/game/nostr/${signer_email}/NPUB"
        if [[ -f "$npub_file" ]]; then
            cp "$npub_file" "${multipass_dir}/${signer_email}.npub" 2>/dev/null && \
                echo "📝 NPUB copiée pour $signer_email"
        fi
    fi
    
    echo "✍️ Signature ajoutée: $signer_email ($action) - $timestamp"
}

# Génération dynamique de l'index.html
generate_index_html() {
    PROJECT_NAME=$(basename ${MY_PATH})
    GENERATION_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    IPFS_NODE_ID=$(ipfs id -f="<id>" 2>/dev/null || echo "$IPFSNODEID")
    OLD_CID_PARAM=${1:-"genesis"}
    GENESIS_CID_PARAM=${2:-"genesis"}
    EVOLUTION_COUNT=${3:-"0"}
    
    # Extraire le titre du README.md (première ligne commençant par #)
    if [[ -f "${MY_PATH}/README.md" ]]; then
        PAGE_TITLE=$(head -n 20 "${MY_PATH}/README.md" | grep "^# " | head -n 1 | sed 's/^# //' | sed 's/[[:space:]]*$//')
        [[ -z "$PAGE_TITLE" ]] && PAGE_TITLE="$PROJECT_NAME"
        # Échapper les caractères spéciaux pour sed
        PAGE_TITLE_ESCAPED=$(echo "$PAGE_TITLE" | sed 's/[[\.*^$()+?{|]/\\&/g')
    else
        PAGE_TITLE="$PROJECT_NAME"
        PAGE_TITLE_ESCAPED="$PROJECT_NAME"
    fi
    
    # Fonction pour extraire le titre d'un fichier markdown
    extract_md_title() {
        local file="$1"
        if [[ -f "$file" ]]; then
            # Chercher le premier titre H1, H2 ou H3
            local title=$(head -n 20 "$file" | grep -E '^#{1,3} ' | head -n 1 | sed -E 's/^#{1,3} //' | sed 's/[*_`]//g')
            if [[ -n "$title" ]]; then
                echo "$title"
            else
                # Fallback : première ligne non vide significative
                local fallback=$(head -n 10 "$file" | grep -v '^---$' | grep -v '^```' | grep -v '^[*-]' | grep -E '^.{1,100}$' | head -n 1 | sed 's/[*_`]//g')
                if [[ -n "$fallback" ]]; then
                    echo "$fallback"
                else
                    # Dernier fallback : nom du fichier
                    basename "$file" .md
                fi
            fi
        else
            basename "$file" .md
        fi
    }
    
    # Fonction pour générer le menu des fichiers markdown
    generate_markdown_menu() {
        echo "📁 Génération du menu des fichiers .md..."
        
        # Placeholder pour le menu dans l'HTML
        local menu_placeholder="<!-- MARKDOWN_MENU_PLACEHOLDER -->"
        local menu_content=""
        
        # Trouver tous les fichiers .md récursivement
        local md_files=()
        while IFS= read -r -d '' file; do
            md_files+=("$file")
        done < <(find "${MY_PATH}" -name "*.md" -type f -print0 | sort -z)
        
        echo "📄 ${#md_files[@]} fichiers .md trouvés"
        
        # Organiser par répertoires
        declare -A dirs_files
        local root_files=()
        
        for file in "${md_files[@]}"; do
            local rel_path="${file#${MY_PATH}/}"
            local dir_name=$(dirname "$rel_path")
            
            if [[ "$dir_name" == "." ]]; then
                root_files+=("$rel_path")
            else
                if [[ -z "${dirs_files[$dir_name]}" ]]; then
                    dirs_files[$dir_name]="$rel_path"
                else
                    dirs_files[$dir_name]="${dirs_files[$dir_name]}|$rel_path"
                fi
            fi
        done
        
        # Générer le HTML du menu
        menu_content+="<div id=\"navDropdown\" class=\"nav-dropdown\">"
        
        # Fichiers racine en premier
        for file in "${root_files[@]}"; do
            local title=$(extract_md_title "${MY_PATH}/$file")
            local display_name
            
            if [[ "$file" == "README.md" ]]; then
                display_name="🏠 $title"
            elif [[ "$file" =~ ^Readme\. ]]; then
                local ai_name=$(echo "$file" | sed 's/Readme\.//' | sed 's/\.md//')
                display_name="🤖 $title ($ai_name)"
            else
                display_name="📄 $title"
            fi
            
            menu_content+="<a href=\"#\" onclick=\""
            if [[ "$file" == "README.md" ]]; then
                menu_content+="loadReadme();"
            else
                menu_content+="loadMarkdownFile('$file');"
            fi
            menu_content+=" document.getElementById('navDropdown').classList.remove('show'); return false;\">$display_name</a>"
        done
        
        # Répertoires et leurs fichiers
        for dir in $(printf '%s\n' "${!dirs_files[@]}" | sort); do
            local dir_display=$(echo "$dir" | sed 's/^./\U&/' | sed 's/\/.*$//')
            menu_content+="<div class=\"nav-section-title\">📁 $dir_display</div>"
            
            IFS='|' read -ra files <<< "${dirs_files[$dir]}"
            for file in "${files[@]}"; do
                local title=$(extract_md_title "${MY_PATH}/$file")
                menu_content+="<a href=\"#\" class=\"nav-subsection\" onclick=\"loadMarkdownFile('$file'); document.getElementById('navDropdown').classList.remove('show'); return false;\">📄 $title</a>"
            done
        done
        
        menu_content+="</div>"
        
        # Remplacer le placeholder dans l'index.html
        sed -i "s|$menu_placeholder|$menu_content|g" "${MY_PATH}/index.html"
        
        echo "✅ Menu généré avec ${#md_files[@]} fichiers"
    }
    
    cat > ${MY_PATH}/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PAGE_TITLE_PLACEHOLDER</title>
    <script src="frd/marked.min.js"></script>
    <link rel="stylesheet" href="frd/github-dark.min.css">
    <script src="frd/highlight.min.js"></script>
    <link rel="stylesheet" href="frd/katex.min.css">
    <script defer src="frd/katex.min.js"></script>
    <script defer src="frd/auto-render.min.js"></script>
    <script src="frd/nostr.bundle.js"></script>
    <script src="frd/mermaid.min.js"></script>
    <style>
        :root { 
            --bg: #0d1117; 
            --fg: #f0f6fc; 
            --accent: #ffd700; 
            --blue: #58a6ff; 
            --border: #30363d;
            
            /* Variables dynamiques pour les couleurs selon l'heure */
            --primary-hue: 220;
            --primary-sat: 70%;
            --primary-light: 60%;
            --bg-gradient-start: hsl(var(--primary-hue), 20%, 8%);
            --bg-gradient-end: hsl(calc(var(--primary-hue) + 30), 15%, 12%);
            --accent-dynamic: hsl(var(--primary-hue), var(--primary-sat), var(--primary-light));
            --border-dynamic: hsl(var(--primary-hue), 30%, 25%);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, sans-serif; 
            background: linear-gradient(135deg, var(--bg-gradient-start), var(--bg-gradient-end)); 
            color: var(--fg); 
            line-height: 1.6; 
            margin: 0; 
            min-height: 100vh;
            transition: background 2s ease-in-out;
        }
        .header { 
            background: linear-gradient(135deg, var(--bg-gradient-start), var(--bg-gradient-end)); 
            border-bottom: 1px solid var(--border-dynamic); 
            padding: 8px 15px; 
            position: fixed; 
            top: 0; 
            left: 0; 
            right: 0; 
            z-index: 1000; 
            backdrop-filter: blur(10px);
            transition: all 2s ease-in-out;
        }
        .header-nav { display: flex; align-items: center; justify-content: space-between; }
        .header-left { display: flex; align-items: center; gap: 10px; }
        .header-center { flex: 1; text-align: center; }
        .header-right { display: flex; align-items: center; gap: 8px; }
        .header h1 { color: var(--accent); margin: 0; font-size: 1.1rem; }
        .header-icon { 
            background: var(--bg-gradient-start); 
            color: var(--accent-dynamic); 
            border: 1px solid var(--border-dynamic); 
            padding: 4px 8px; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 0.8rem; 
            text-decoration: none; 
            transition: all 0.3s ease; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .header-icon:hover { 
            background: var(--accent-dynamic); 
            color: var(--bg-gradient-start); 
            text-decoration: none; 
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        .breadcrumb { color: #8b949e; font-size: 0.8rem; margin-left: 8px; position: relative; }
        .nav-menu { position: relative; display: inline-block; }
        .nav-dropdown { display: none; position: absolute; top: 100%; left: 0; background: #21262d; border: 1px solid var(--border); border-radius: 6px; min-width: 320px; max-width: 450px; z-index: 1000; box-shadow: 0 4px 12px rgba(0,0,0,0.3); }
        .nav-dropdown.show { display: block; }
        .nav-dropdown a { display: block; padding: 10px 16px; color: var(--fg); text-decoration: none; border-bottom: 1px solid var(--border); transition: background 0.2s; font-size: 0.9em; }
        .nav-dropdown a:hover { background: #30363d; }
        .nav-dropdown a:last-child { border-bottom: none; }
        .nav-section-title { padding: 10px 16px; font-weight: bold; color: #58a6ff; border-top: 1px solid var(--border); margin-top: 4px; font-size: 0.85em; background: #161b22; text-transform: uppercase; letter-spacing: 0.5px; }
        .nav-subsection a { padding-left: 32px; font-size: 0.85em; }
        .nav-subsection a:hover { background: #2d333b; }
        
        /* Footer profil utilisateur */
        .footer { 
            position: fixed; 
            bottom: 0; 
            left: 0; 
            right: 0; 
            background: linear-gradient(135deg, #0d1117, #161b22); 
            border-top: 1px solid var(--border); 
            padding: 10px 20px; 
            z-index: 1000; 
            display: none;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.3);
        }
        .user-profile-footer { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            max-width: 1200px; 
            margin: 0 auto; 
        }
        .user-profile-info { 
            display: flex; 
            align-items: center; 
            gap: 12px; 
        }
        .user-avatar { 
            width: 40px; 
            height: 40px; 
            border-radius: 50%; 
            border: 2px solid var(--blue); 
            object-fit: cover; 
        }
        .user-avatar-placeholder { 
            width: 40px; 
            height: 40px; 
            border-radius: 50%; 
            border: 2px solid var(--border); 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            background: var(--bg-secondary); 
            font-size: 1.2em; 
        }
        .user-details { 
            display: flex; 
            flex-direction: column; 
            gap: 2px; 
        }
        .user-name { 
            font-weight: bold; 
            color: var(--blue); 
            font-size: 0.9em; 
        }
        .user-pubkey { 
            font-family: monospace; 
            color: var(--fg-muted); 
            font-size: 0.8em; 
        }
        .user-about { 
            color: var(--fg-muted); 
            font-size: 0.8em; 
            max-width: 300px; 
            white-space: nowrap; 
            overflow: hidden; 
            text-overflow: ellipsis; 
        }
        .disconnect-btn { 
            background: var(--bg-secondary); 
            border: 1px solid var(--border); 
            color: var(--fg); 
            padding: 6px 12px; 
            border-radius: 6px; 
            cursor: pointer; 
            font-size: 0.8em; 
            transition: all 0.2s; 
        }
        .disconnect-btn:hover { 
            background: var(--danger); 
            border-color: var(--danger); 
            color: white; 
        }
        .signer-badge { 
            background: linear-gradient(135deg, var(--accent-dynamic), #ffd700); 
            color: #0d1117; 
            padding: 6px 12px; 
            border-radius: 6px; 
            font-size: 0.8em;
            font-weight: bold;
            text-shadow: none;
            border: 1px solid rgba(255, 215, 0, 0.3);
        }
        .profile-link {
            background: linear-gradient(135deg, var(--blue), #4a9eff);
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.8em;
            font-weight: bold;
            text-decoration: none;
            margin-left: 8px;
            border: 1px solid rgba(88, 166, 255, 0.3);
            transition: all 0.2s ease;
        }
        .profile-link:hover {
            background: linear-gradient(135deg, #4a9eff, var(--blue));
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(88, 166, 255, 0.3);
        }
        .user-actions {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 8px;
        }
        .cli-info {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.8em;
            font-weight: bold;
            cursor: help;
            border: 1px solid rgba(108, 117, 125, 0.3);
            transition: all 0.2s ease;
        }
        .cli-info:hover {
            background: linear-gradient(135deg, #495057, #6c757d);
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(108, 117, 125, 0.3);
        }
        .nav-menu-btn { background: none; border: none; color: var(--blue); cursor: pointer; font-size: 0.8rem; padding: 2px 6px; border-radius: 3px; }
        .nav-menu-btn:hover { background: #30363d; }
        .connect-btn { 
            background: linear-gradient(45deg, var(--accent-dynamic), hsl(calc(var(--primary-hue) + 40), var(--primary-sat), calc(var(--primary-light) - 10%))); 
            color: white; 
            border: none; 
            padding: 4px 8px; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 0.8rem; 
            text-decoration: none; 
            transition: all 0.3s ease; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .connect-btn:hover { 
            background: linear-gradient(45deg, hsl(calc(var(--primary-hue) + 40), var(--primary-sat), calc(var(--primary-light) - 10%)), var(--accent-dynamic)); 
            text-decoration: none; 
            color: white; 
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        .connect-btn.connected { 
            background: linear-gradient(45deg, hsl(120, 70%, 50%), hsl(120, 70%, 40%)); 
        }
        body { padding-top: 60px; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; padding-bottom: 80px; /* Espace pour le footer */ }
        .markdown-content { background: var(--bg); }
        .markdown-content h1 { color: var(--accent); border-bottom: 2px solid var(--border); padding-bottom: 10px; margin-bottom: 30px; }
        .markdown-content h2 { color: var(--blue); margin-top: 40px; margin-bottom: 20px; }
        .markdown-content h3 { color: var(--fg); margin-top: 30px; margin-bottom: 15px; }
        .markdown-content code { background: #161b22; padding: 2px 6px; border-radius: 3px; color: var(--accent); }
        .markdown-content pre { background: #161b22; padding: 16px; border-radius: 6px; overflow-x: auto; margin: 20px 0; border: 1px solid var(--border); }
        .markdown-content pre code { background: none; padding: 0; color: var(--fg); }
        .markdown-content a { color: var(--blue); text-decoration: none; }
        .markdown-content a:hover { text-decoration: underline; }
        .markdown-content blockquote { border-left: 4px solid var(--accent); padding-left: 16px; margin: 20px 0; background: #161b22; padding: 16px; border-radius: 6px; font-style: italic; }
        .markdown-content table { border-collapse: collapse; width: 100%; margin: 20px 0; background: #161b22; border-radius: 6px; overflow: hidden; }
        .markdown-content th, .markdown-content td { border: 1px solid var(--border); padding: 12px; text-align: left; }
        .markdown-content th { background: #21262d; color: var(--accent); font-weight: 600; }
        .markdown-content ul, .markdown-content ol { margin: 16px 0; padding-left: 30px; }
        .markdown-content li { margin-bottom: 8px; }
        .loading { text-align: center; padding: 60px; color: #8b949e; }
        @media (max-width: 768px) { 
            .container { padding: 10px; } 
            .header-nav { padding: 0 5px; }
            .header h1 { font-size: 1rem; }
            .breadcrumb #breadcrumbText { display: none; }
            .header-right span { display: none; }
            .nav-dropdown { min-width: 280px; max-width: 90vw; right: 0; left: auto; }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-nav">
            <div class="header-left">
                <a id="backBtn" onclick="loadReadme()" class="header-icon" style="display: none;" title="Retour au README">🏠</a>
                <div id="breadcrumb" class="breadcrumb">
                    <div class="nav-menu">
                        <button id="navMenuBtn" class="nav-menu-btn" onclick="toggleNavMenu()">📄 Navigation ▼</button>
                        <!-- MARKDOWN_MENU_PLACEHOLDER -->
                    </div>
                    <span id="breadcrumbText"></span>
                </div>
            </div>
            <div class="header-center">
                <button id="connectBtn" class="connect-btn" onclick="connectToNostr()">🔗 Connect</button>
            </div>
            <div class="header-right">
                <span style="font-size: 0.7rem; color: #6e7681;">GENERATION_DATE_PLACEHOLDER</span>
                <a href="/ipns/IPFS_NODE_ID_PLACEHOLDER" class="header-icon" title="IPFS Node: IPFS_NODE_ID_PLACEHOLDER">🌐</a>
                <a href="/ipfs/OLD_CID_PLACEHOLDER/" class="header-icon" id="prevVersionBtn" title="Version précédente">⏮️</a>
                <a href="/ipfs/GENESIS_CID_PLACEHOLDER/" class="header-icon" id="genesisBtn" title="Version Genesis">🌱</a>
                <span class="header-icon" id="evolutionCounter" title="Évolutions depuis Genesis">🔄 EVOLUTION_COUNT_PLACEHOLDER</span>
                <a href="#" onclick="showSignatures()" class="header-icon" id="signaturesBtn" title="Signatures de la chaîne">✍️</a>
            </div>
        </div>
    </div>
    <div class="container">
        <div id="content" class="markdown-content">
            <div class="loading">⏳ Chargement de la documentation...</div>
        </div>
    </div>
    <div class="footer" style="border-top: 1px solid var(--border); padding: 20px; text-align: center; font-size: 0.8rem; color: #6e7681; margin-top: 40px;">

    </div>
            <script>
                marked.setOptions({ 
                    highlight: (code, lang) => lang && hljs.getLanguage(lang) ? hljs.highlight(code, { language: lang }).value : hljs.highlightAuto(code).value, 
                    breaks: true, 
                    gfm: true 
                });
                
                // Système de couleurs dynamiques selon l'heure
                function updateTimeBasedColors() {
                    const now = new Date();
                    const hour = now.getHours();
                    const minute = now.getMinutes();
                    const timeProgress = (hour * 60 + minute) / (24 * 60); // 0 à 1
                    
                    // Calculer la teinte selon l'heure (cycle de 24h)
                    // Matin (6h): bleu clair (200°), Midi (12h): jaune (60°), 
                    // Soir (18h): orange/rouge (20°), Nuit (0h/24h): violet (280°)
                    let hue;
                    if (hour >= 6 && hour < 12) {
                        // Matin: transition bleu vers jaune (200° -> 60°)
                        const progress = (hour - 6) / 6;
                        hue = 200 - (140 * progress);
                    } else if (hour >= 12 && hour < 18) {
                        // Après-midi: transition jaune vers orange (60° -> 20°)
                        const progress = (hour - 12) / 6;
                        hue = 60 - (40 * progress);
                    } else if (hour >= 18 && hour < 24) {
                        // Soir: transition orange vers violet (20° -> 280°)
                        const progress = (hour - 18) / 6;
                        hue = 20 + (260 * progress);
                    } else {
                        // Nuit: transition violet vers bleu (280° -> 200°)
                        const progress = hour / 6;
                        hue = 280 - (80 * progress);
                    }
                    
                    // Ajuster la saturation et la luminosité selon l'heure
                    let saturation = 70;
                    let lightness = 60;
                    
                    if (hour >= 22 || hour < 6) {
                        // Nuit: couleurs plus sombres et moins saturées
                        saturation = 50;
                        lightness = 45;
                    } else if (hour >= 6 && hour < 8) {
                        // Lever du soleil: couleurs douces
                        saturation = 60;
                        lightness = 55;
                    } else if (hour >= 12 && hour < 14) {
                        // Midi: couleurs vives
                        saturation = 80;
                        lightness = 65;
                    }
                    
                    // Mettre à jour les variables CSS
                    const root = document.documentElement;
                    root.style.setProperty('--primary-hue', Math.round(hue));
                    root.style.setProperty('--primary-sat', saturation + '%');
                    root.style.setProperty('--primary-light', lightness + '%');
                    
                    console.log(`🎨 Couleurs mises à jour: ${Math.round(hue)}°, ${saturation}%, ${lightness}% (${hour}:${minute.toString().padStart(2, '0')})`);
                }
                
                // Initialiser les couleurs au chargement
                updateTimeBasedColors();
                
                // Mettre à jour les couleurs toutes les minutes
                setInterval(updateTimeBasedColors, 60000);
                
                // Menu généré côté serveur - plus de découverte JavaScript nécessaire
                console.log('📁 Menu de navigation généré côté serveur');
                
                // Fonction pour basculer l'affichage du menu
                function toggleNavMenu() {
                    const dropdown = document.getElementById('navDropdown');
                    dropdown.classList.toggle('show');
                }
                
                // Fermer le menu si on clique ailleurs
                document.addEventListener('click', function(event) {
                    const navMenu = document.querySelector('.nav-menu');
                    const dropdown = document.getElementById('navDropdown');
                    if (!navMenu.contains(event.target)) {
                        dropdown.classList.remove('show');
                    }
                });
                
                // Menu généré côté serveur - fonction populateNavMenu supprimée
            
            // Fonction pour générer des IDs après le rendu
            function addHeadingIds(html) {
                return html.replace(/<h([1-6])([^>]*)>(.*?)<\/h[1-6]>/gi, function(match, level, attrs, text) {
                    // Vérifier si l'ID existe déjà
                    if (attrs.includes('id=')) {
                        return match;
                    }
                    
                    // Générer un ID à partir du texte
                    const cleanText = text.replace(/<[^>]*>/g, ''); // Supprimer HTML
                    const id = cleanText
                        .toLowerCase()
                        .replace(/[^\w\s-]/g, '') // Supprimer caractères spéciaux
                        .replace(/\s+/g, '-')     // Remplacer espaces par tirets
                        .replace(/-+/g, '-')      // Éviter tirets multiples
                        .replace(/^-|-$/g, '');   // Supprimer tirets en début/fin
                    
                    return `<h${level}${attrs} id="${id}">${text}</h${level}>`;
                });
            }
        
            // Fonction pour mettre à jour la navigation (breadcrumb et bouton retour)
            function updateNavigation(filename, anchor) {
                const backBtn = document.getElementById('backBtn');
                const breadcrumbText = document.getElementById('breadcrumbText');
                
                if (filename === 'README.md') {
                    backBtn.style.display = 'none';
                    breadcrumbText.textContent = anchor ? ` → README ${anchor}` : ' → README';
                } else {
                    backBtn.style.display = 'inline-block';
                    const shortName = filename.replace('.md', '').replace('Readme.', '').replace('README.', '');
                    breadcrumbText.textContent = anchor ? ` → ${shortName} ${anchor}` : ` → ${shortName}`;
                }
            }
        
        async function loadReadme() {
            const content = document.getElementById('content');
            try {
                const response = await fetch('README.md');
                if (!response.ok) throw new Error(`Erreur ${response.status}`);
                const markdown = await response.text();
                
                // Parser le markdown
                let html = marked.parse(markdown);
                
                // Ajouter les IDs aux titres
                html = addHeadingIds(html);
                
                // Transformer les liens .md en liens qui rechargent dans la même page
                // Gérer les liens avec ancres : fichier.md#ancre
                html = html.replace(/href="([^"]+\.md)(#[^"]+)?"/g, function(match, file, anchor) {
                    anchor = anchor || '';
                    return `href="#" onclick="loadMarkdownFile('${file}', '${anchor}'); return false;"`;
                });
                
                content.innerHTML = html;
                
                // Mettre à jour la navigation
                updateNavigation('README.md', '');
                
                // Rendre les diagrammes Mermaid
                try {
                    await renderMermaidDiagrams();
                    console.log('✅ Diagrammes Mermaid traités dans README');
                } catch (error) {
                    console.error('❌ Erreur Mermaid dans README:', error);
                }
                
                // Rendu des formules mathématiques
                if (window.renderMathInElement) {
                    renderMathInElement(content, { 
                        delimiters: [
                            {left: '$$', right: '$$', display: true}, 
                            {left: '$', right: '$', display: false},
                            {left: '\\[', right: '\\]', display: true},
                            {left: '\\(', right: '\\)', display: false}
                        ],
                        throwOnError: false,
                        errorColor: '#cc0000',
                        strict: false,
                        trust: true,
                        macros: {
                            "\\sim": "\\thicksim"
                        }
                    });
                }
                
                // Gérer les ancres après le chargement avec délai pour le rendu
                setTimeout(() => handleAnchors(), 300);
                
                // Debug : afficher les ancres disponibles dans la console (mode debug seulement)
                if (window.location.search.includes('debug=anchors')) {
                    setTimeout(() => {
                        console.log('=== ANCRES DISPONIBLES APRÈS RENDU ===');
                        document.querySelectorAll('[id]').forEach(el => {
                            console.log(`#${el.id} - "${el.textContent.trim().substring(0, 50)}..."`);
                        });
                        
                        // Debug spécial pour les titres
                        console.log('=== TITRES H1-H6 ===');
                        document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(el => {
                            console.log(`${el.tagName} id="${el.id}" - "${el.textContent.trim()}"`);
                        });
                    }, 800);
                }
            } catch (error) {
                content.innerHTML = `<h1>❌ Erreur</h1><p>Impossible de charger README.md</p><p>Détails: ${error.message}</p>`;
            }
        }
        
        async function loadMarkdownFile(filename, targetAnchor = '') {
            const content = document.getElementById('content');
            content.innerHTML = '<div class="loading">⏳ Chargement de ' + filename + '...</div>';
            try {
                const response = await fetch(filename);
                if (!response.ok) throw new Error(`Erreur ${response.status}`);
                const markdown = await response.text();
                
                let html = marked.parse(markdown);
                
                // Ajouter les IDs aux titres
                html = addHeadingIds(html);
                
                // Mettre à jour la navigation
                updateNavigation(filename, targetAnchor);
                
                // Transformer les liens .md avec gestion des ancres
                html = html.replace(/href="([^"]+\.md)(#[^"]+)?"/g, function(match, file, anchor) {
                    anchor = anchor || '';
                    return `href="#" onclick="loadMarkdownFile('${file}', '${anchor}'); return false;"`;
                });
                
                content.innerHTML = html;
                
                // Rendre les diagrammes Mermaid
                try {
                    await renderMermaidDiagrams();
                    console.log(`✅ Diagrammes Mermaid traités dans ${filename}`);
                } catch (error) {
                    console.error(`❌ Erreur Mermaid dans ${filename}:`, error);
                }
                
                if (window.renderMathInElement) {
                    renderMathInElement(content, { 
                        delimiters: [
                            {left: '$$', right: '$$', display: true}, 
                            {left: '$', right: '$', display: false},
                            {left: '\\[', right: '\\]', display: true},
                            {left: '\\(', right: '\\)', display: false}
                        ],
                        throwOnError: false,
                        errorColor: '#cc0000',
                        strict: false,
                        trust: true,
                        macros: {
                            "\\sim": "\\thicksim"
                        }
                    });
                }
                
                // Debug : afficher les ancres dans le fichier chargé
                setTimeout(() => {
                    console.log(`=== ANCRES DANS ${filename} ===`);
                    document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(el => {
                        console.log(`${el.tagName} id="${el.id}" - "${el.textContent.trim()}"`);
                    });
                }, 600);
                
                // Gérer l'ancre cible ou scroll vers le haut
                if (targetAnchor) {
                    // Mettre à jour l'URL sans recharger la page
                    window.history.replaceState(null, null, targetAnchor);
                    setTimeout(() => {
                        const element = document.querySelector(targetAnchor);
                        if (element) {
                            scrollToElementWithOffset(element);
                        }
                    }, 200);
                } else if (window.location.hash) {
                    handleAnchors();
                } else {
                    window.scrollTo(0, 0);
                }
            } catch (error) {
                content.innerHTML = `<h1>❌ Erreur</h1><p>Impossible de charger ${filename}</p><p>Détails: ${error.message}</p>`;
            }
        }
        
        // Fonction utilitaire pour scroll vers un élément avec offset header
        function scrollToElementWithOffset(element) {
            const header = document.querySelector('.header');
            const headerHeight = header ? header.offsetHeight + 10 : 70; // +10px de marge
            const elementPosition = element.getBoundingClientRect().top + window.pageYOffset;
            const offsetPosition = elementPosition - headerHeight;
            
            window.scrollTo({
                top: offsetPosition,
                behavior: 'smooth'
            });
            
            // Effet de surbrillance
            element.style.backgroundColor = 'rgba(255, 215, 0, 0.3)';
            setTimeout(() => {
                element.style.backgroundColor = '';
            }, 3000);
        }
        
        // Fonction pour gérer les ancres avec retry
        function handleAnchors(retryCount = 0) {
            if (!window.location.hash) return;
            
            const maxRetries = 10;
            let targetHash = window.location.hash;
            
            // Debug : afficher l'ancre recherchée
            console.log(`🔍 Recherche ancre: "${targetHash}" (URL décodée: "${decodeURIComponent(targetHash)}")`);
            
            // Essayer d'abord avec l'ancre telle quelle
            let element = null;
            try {
                element = document.querySelector(targetHash);
            } catch (e) {
                console.log(`❌ Erreur sélecteur CSS: ${e.message}`);
                // Essayer avec l'ancre décodée
                try {
                    const decodedHash = decodeURIComponent(targetHash);
                    console.log(`🔄 Tentative avec ancre décodée: "${decodedHash}"`);
                    element = document.querySelector(decodedHash);
                } catch (e2) {
                    console.log(`❌ Erreur sélecteur décodé: ${e2.message}`);
                    // Essayer de trouver par correspondance de texte
                    const searchText = targetHash.replace('#', '').replace(/-/g, ' ').toLowerCase();
                    console.log(`🔄 Recherche par texte: "${searchText}"`);
                    document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(el => {
                        const elText = el.textContent.toLowerCase().replace(/[^a-z0-9\s]/g, '').replace(/\s+/g, ' ');
                        const elId = el.id ? el.id.toLowerCase() : '';
                        
                        // Correspondance par texte ou par ID généré
                        if (elText.includes(searchText) || 
                            searchText.includes(elText.substring(0, 10)) ||
                            elId.includes(searchText.replace(/\s+/g, '-')) ||
                            searchText.replace(/\s+/g, '-').includes(elId)) {
                            element = el;
                            console.log(`✅ Correspondance trouvée: "${el.textContent.trim()}" (ID: ${el.id})`);
                        }
                    });
                }
            }
            
            if (element) {
                scrollToElementWithOffset(element);
                console.log(`✅ Ancre trouvée: ${targetHash} -> "${element.textContent.trim().substring(0, 50)}..."`);
            } else if (retryCount < maxRetries) {
                // Retry avec délai croissant
                const delay = 200 + (retryCount * 100);
                console.log(`⏳ Ancre ${targetHash} non trouvée, retry ${retryCount + 1}/${maxRetries} dans ${delay}ms`);
                setTimeout(() => handleAnchors(retryCount + 1), delay);
            } else {
                console.log(`❌ Ancre ${targetHash} introuvable après ${maxRetries} tentatives`);
                // Afficher seulement le nombre d'ancres disponibles
                const anchorsCount = document.querySelectorAll('[id]').length;
                console.log(`🔍 ${anchorsCount} ancres disponibles (ajoutez ?debug=anchors pour les voir)`);
                if (window.location.search.includes('debug=anchors')) {
                    document.querySelectorAll('[id]').forEach(el => {
                        console.log(`  #${el.id} - "${el.textContent.trim().substring(0, 50)}..."`);
                    });
                }
            }
        }
        
        // Gérer les changements d'ancre
        window.addEventListener('hashchange', handleAnchors);
        
        // Intercepter tous les clics sur les liens .md (délégation d'événements)
        document.addEventListener('click', function(e) {
            const link = e.target.closest('a[href]');
            if (!link) return;
            
            const href = link.getAttribute('href');
            const mdMatch = href.match(/^([^#]+\.md)(#.*)?$/);
            
            if (mdMatch) {
                e.preventDefault();
                const filename = mdMatch[1];
                const anchor = mdMatch[2] || '';
                loadMarkdownFile(filename, anchor);
            }
        });
        
        // Fonction pour parser l'URL et détecter les liens vers des fichiers .md
        function parseInitialUrl() {
            const path = window.location.pathname;
            const hash = window.location.hash;
            
            // Vérifier si l'URL pointe vers un fichier .md
            const mdMatch = path.match(/\/([^\/]+\.md)$/);
            if (mdMatch) {
                const filename = mdMatch[1];
                loadMarkdownFile(filename, hash);
                return true;
            }
            return false;
        }
        
            // Variables globales pour Nostr
            let nostrConnected = false;
            let userPublicKey = null;
            let userPrivateKey = null;
            
            // Fonction pour se connecter à Nostr
            async function connectToNostr() {
                const connectBtn = document.getElementById('connectBtn');
                
                try {
                    connectBtn.textContent = '🔄 Connexion...';
                    connectBtn.disabled = true;
                    
                    // Essayer d'utiliser l'extension Nostr (NIP-07)
                    if (window.nostr) {
                        console.log('Extension Nostr détectée');
                        userPublicKey = await window.nostr.getPublicKey();
                        
                        // Effectuer l'authentification NIP42
                        connectBtn.textContent = '🔐 Authentification...';
                        const authSuccess = await performNIP42Auth();
                        
                        if (authSuccess) {
                            nostrConnected = true;
                            connectBtn.textContent = '✅ Connecté';
                            connectBtn.classList.add('connected');
                            console.log('Connecté et authentifié avec la clé publique:', userPublicKey);
                        } else {
                            throw new Error('Échec de l\'authentification NIP42');
                        }
                    } else {
                        // Fallback: demander une clé nsec
                        const nsec = prompt('Entrez votre clé nsec (ou installez une extension Nostr):');
                        if (nsec && nsec.startsWith('nsec1')) {
                            try {
                                const decoded = NostrTools.nip19.decode(nsec);
                                userPrivateKey = decoded.data;
                                userPublicKey = NostrTools.getPublicKey(userPrivateKey);
                                
                                // Effectuer l'authentification NIP42
                                connectBtn.textContent = '🔐 Authentification...';
                                const authSuccess = await performNIP42Auth();
                                
                                if (authSuccess) {
                                    nostrConnected = true;
                                    connectBtn.textContent = '✅ Connecté';
                                    connectBtn.classList.add('connected');
                                    console.log('Connecté et authentifié avec la clé publique:', userPublicKey);
                                } else {
                                    throw new Error('Échec de l\'authentification NIP42');
                                }
                            } catch (error) {
                                throw new Error('Clé nsec invalide: ' + error.message);
                            }
                        } else {
                            throw new Error('Aucune clé fournie');
                        }
                    }
                } catch (error) {
                    console.error('Erreur de connexion Nostr:', error);
                    connectBtn.textContent = '❌ Erreur';
                    setTimeout(() => {
                        connectBtn.textContent = '🔗 Connect';
                        connectBtn.disabled = false;
                    }, 2000);
                    alert('Erreur de connexion Nostr: ' + error.message);
                }
            }
            
            // Fonction pour obtenir l'URL du relai basée sur l'URL IPFS actuelle
            function getRelayURL() {
                const currentUrl = new URL(window.location.href);
                let relayName = currentUrl.hostname.replace('ipfs.', 'relay.');
                
                if (currentUrl.port === '8080' || currentUrl.hostname === '127.0.0.1' || currentUrl.hostname === 'localhost') {
                    return 'ws://127.0.0.1:7777'; // Relai local par défaut
                }
                
                return `wss://${relayName}`;
            }
            
            // Fonction pour effectuer l'authentification NIP42
            async function performNIP42Auth() {
                return new Promise(async (resolve) => {
                    try {
                        console.log('🔐 Démarrage de l\'authentification NIP42...');
                        
                        const relayUrl = getRelayURL();
                        console.log('🌐 URL du relai détectée:', relayUrl);
                        
                        // Initialiser la connexion au relai avec NostrTools
                        const relay = new NostrTools.Relay(relayUrl);
                        let authCompleted = false;
                        
                        // Gérer le challenge d'authentification
                        relay._onauth = async (challenge) => {
                            console.log('🔐 Challenge NIP42 reçu:', challenge);
                            
                            if (authCompleted) {
                                console.log('⚠️ Authentification déjà complétée, ignoré');
                                return;
                            }
                            
                            try {
                                // Utiliser la fonction auth() du relai avec une fonction de signature
                                const signAuthEvent = async (authEvent) => {
                                    console.log('📝 Signature de l\'événement NIP42:', authEvent);
                                    
                                    // Ajouter la clé publique
                                    authEvent.pubkey = userPublicKey;
                                    
                                    // Signer l'événement
                                    if (window.nostr && window.nostr.signEvent) {
                                        return await window.nostr.signEvent(authEvent);
                                    } else if (userPrivateKey) {
                                        return NostrTools.finishEvent(authEvent, userPrivateKey);
                                    } else {
                                        throw new Error('Impossible de signer l\'événement d\'authentification');
                                    }
                                };
                                
                                // Effectuer l'authentification
                                await relay.auth(signAuthEvent);
                                console.log('📡 Authentification NIP42 envoyée avec succès');
                                
                                authCompleted = true;
                                
                                // Attendre un peu puis fermer et résoudre
                                setTimeout(async () => {
                                    relay.close();
                                    console.log('✅ Authentification NIP42 réussie');
                                    // Charger et afficher le profil utilisateur dans le footer
                                    await loadUserProfile();
                                    resolve(true);
                                }, 1000);
                                
                            } catch (authError) {
                                console.error('❌ Erreur lors de l\'authentification NIP42:', authError);
                                relay.close();
                                resolve(false);
                            }
                        };
                        
                        // Gérer les erreurs de connexion
                        relay.onclose = () => {
                            if (!authCompleted) {
                                console.log('🔌 Connexion fermée avant authentification');
                                resolve(false);
                            }
                        };
                        
                        // Connecter au relai
                        await relay.connect();
                        console.log('✅ Connecté au relai pour NIP42:', relayUrl);
                        
                        // Timeout de sécurité - Envoyer un NIP42 proactif avec _moats
                        setTimeout(async () => {
                            if (!authCompleted) {
                                console.log('🔐 Pas de challenge reçu - envoi NIP42 proactif avec _moats');
                                
                                try {
                                    // Charger le contenu du fichier _moats qui se trouve à côté de index.html
                                    let moatsChallenge = 'default-challenge';
                                    try {
                                        const moatsResponse = await fetch('_moats');
                                        if (moatsResponse.ok) {
                                            moatsChallenge = await moatsResponse.text();
                                            moatsChallenge = moatsChallenge.trim();
                                            console.log('📅 Challenge _moats lu:', moatsChallenge);
                                        } else {
                                            console.log('⚠️ Fichier _moats non trouvé, génération d\'un challenge temporaire');
                                            // Fallback: générer un challenge basé sur le timestamp actuel
                                            const now = new Date();
                                            moatsChallenge = now.getFullYear().toString() + 
                                                           (now.getMonth() + 1).toString().padStart(2, '0') +
                                                           now.getDate().toString().padStart(2, '0') +
                                                           now.getHours().toString().padStart(2, '0') +
                                                           now.getMinutes().toString().padStart(2, '0') +
                                                           now.getSeconds().toString().padStart(2, '0') +
                                                           now.getMilliseconds().toString().padStart(4, '0');
                                            console.log('📅 Challenge généré (fallback):', moatsChallenge);
                                        }
                                    } catch (fetchError) {
                                        console.log('⚠️ Erreur lors de la lecture de _moats:', fetchError);
                                        // Fallback: générer un challenge basé sur le timestamp actuel
                                        const now = new Date();
                                        moatsChallenge = now.getFullYear().toString() + 
                                                       (now.getMonth() + 1).toString().padStart(2, '0') +
                                                       now.getDate().toString().padStart(2, '0') +
                                                       now.getHours().toString().padStart(2, '0') +
                                                       now.getMinutes().toString().padStart(2, '0') +
                                                       now.getSeconds().toString().padStart(2, '0') +
                                                       now.getMilliseconds().toString().padStart(4, '0');
                                        console.log('📅 Challenge généré (erreur):', moatsChallenge);
                                    }
                                    
                                    // Créer l'événement NIP42 proactif
                                    const authEvent = {
                                        kind: 22242,
                                        created_at: Math.floor(Date.now() / 1000),
                                        tags: [
                                            ['relay', relayUrl],
                                            ['challenge', moatsChallenge]
                                        ],
                                        content: '',
                                        pubkey: userPublicKey
                                    };
                                    
                                    // Signer l'événement
                                    let signedEvent;
                                    if (window.nostr && window.nostr.signEvent) {
                                        signedEvent = await window.nostr.signEvent(authEvent);
                                    } else if (userPrivateKey) {
                                        signedEvent = NostrTools.finishEvent(authEvent, userPrivateKey);
                                    } else {
                                        throw new Error('Impossible de signer l\'événement NIP42');
                                    }
                                    
                                    // Publier l'événement (méthode simplifiée)
                                    try {
                                        await relay.publish(signedEvent);
                                        console.log('✅ Authentification NIP42 proactive réussie');
                                        authCompleted = true;
                                        
                                        // Attendre un peu avant de fermer
                                        setTimeout(() => {
                                            relay.close();
                                            resolve(true);
                                        }, 1000);
                                        
                                    } catch (publishError) {
                                        console.log('⚠️ Authentification NIP42 proactive échouée:', publishError);
                                        relay.close();
                                        resolve(true); // On considère que c'est OK même si ça échoue
                                    }
                                    
                                    console.log('📡 Événement NIP42 proactif envoyé');
                                    
                                } catch (error) {
                                    console.log('⚠️ Erreur lors de l\'authentification proactive:', error);
                                    relay.close();
                                    resolve(true); // On considère que c'est OK même si ça échoue
                                }
                            }
                        }, 2000); // Réduire le timeout à 2s pour être plus réactif
                        
                    } catch (error) {
                        console.error('❌ Erreur générale NIP42:', error);
                        resolve(false);
                    }
                });
            }
            
            // Fonction pour publier un événement sur le relai
            async function publishToRelay(event, relayUrl) {
                return new Promise((resolve) => {
                    try {
                        const ws = new WebSocket(relayUrl || 'ws://127.0.0.1:7777');
                        
                        ws.onopen = () => {
                            console.log('📡 Connexion au relai établie');
                            const message = JSON.stringify(['EVENT', event]);
                            ws.send(message);
                            console.log('📤 Événement envoyé au relai:', message);
                        };
                        
                        ws.onmessage = (event) => {
                            const data = JSON.parse(event.data);
                            console.log('📥 Réponse du relai:', data);
                            
                            if (data[0] === 'OK' && data[2] === true) {
                                console.log('✅ Événement accepté par le relai');
                                ws.close();
                                resolve(true);
                            } else if (data[0] === 'OK' && data[2] === false) {
                                console.error('❌ Événement rejeté par le relai:', data[3]);
                                ws.close();
                                resolve(false);
                            }
                        };
                        
                        ws.onerror = (error) => {
                            console.error('❌ Erreur WebSocket:', error);
                            ws.close();
                            resolve(false);
                        };
                        
                        ws.onclose = () => {
                            console.log('📡 Connexion au relai fermée');
                        };
                        
                        // Timeout après 10 secondes
                        setTimeout(() => {
                            if (ws.readyState === WebSocket.OPEN) {
                                console.log('⏰ Timeout de l\'authentification');
                                ws.close();
                                resolve(false);
                            }
                        }, 10000);
                        
                    } catch (error) {
                        console.error('❌ Erreur lors de la connexion au relai:', error);
                        resolve(false);
                    }
                });
            }
            
            // Fonction pour charger le profil utilisateur depuis Nostr
            async function loadUserProfile() {
                try {
                    console.log('👤 Chargement du profil utilisateur...');
                    const relayUrl = getRelayURL();
                    
                    // Créer une connexion WebSocket au relai
                    const ws = new WebSocket(relayUrl);
                    
                    return new Promise((resolve) => {
                        ws.onopen = () => {
                            console.log('📡 Connexion au relai établie pour le profil');
                            // Demander le profil utilisateur (kind 0)
                            const request = JSON.stringify(['REQ', 'profile_' + Date.now(), {
                                kinds: [0],
                                authors: [userPublicKey],
                                limit: 1
                            }]);
                            ws.send(request);
                        };
                        
                        ws.onmessage = (event) => {
                            const data = JSON.parse(event.data);
                            
                            if (data[0] === 'EVENT') {
                                try {
                                    const profileData = JSON.parse(data[2].content);
                                    console.log('👤 Profil utilisateur reçu:', profileData);
                                    displayUserProfile(profileData);
                                    ws.close();
                                    resolve(profileData);
                                } catch (error) {
                                    console.error('Erreur parsing profil:', error);
                                    ws.close();
                                    resolve(null);
                                }
                            } else if (data[0] === 'EOSE') {
                                console.log('Fin de réception du profil');
                                ws.close();
                                resolve(null);
                            }
                        };
                        
                        ws.onerror = (error) => {
                            console.error('Erreur WebSocket profil:', error);
                            ws.close();
                            resolve(null);
                        };
                        
                        // Timeout après 5 secondes
                        setTimeout(() => {
                            if (ws.readyState === WebSocket.OPEN) {
                                ws.close();
                                resolve(null);
                            }
                        }, 5000);
                    });
                } catch (error) {
                    console.error('Erreur lors du chargement du profil:', error);
                    return null;
                }
            }
            
            // Fonction pour afficher le profil utilisateur dans le footer
            function displayUserProfile(profileData, pubkey = null) {
                try {
                    // Créer ou mettre à jour le footer
                    let footer = document.querySelector('.footer');
                    if (!footer) {
                        footer = document.createElement('div');
                        footer.className = 'footer';
                        document.body.appendChild(footer);
                    }
                    
                    // Construire le HTML du profil
                    const name = profileData.name || profileData.display_name || 'Signataire Nostr';
                    const picture = profileData.picture || '';
                    const about = profileData.about || '';
                    const displayPubkey = pubkey || userPublicKey || 'unknown';
                    const pubkeyShort = displayPubkey.substring(0, 8) + '...' + displayPubkey.substring(displayPubkey.length - 8);
                    
                    // Construire l'URL du profil complet
                    const profileViewerUrl = `/ipns/copylaradio.com/nostr_profile_viewer.html?hex=${displayPubkey}&origin=${displayPubkey}`;
                    
                    let profileHTML = `
                        <div class="user-profile-footer">
                            <div class="user-profile-info">
                                ${picture ? `<img src="${picture}" alt="Profile" class="user-avatar">` : '<div class="user-avatar-placeholder">👤</div>'}
                                <div class="user-details">
                                    <div class="user-name">${name}</div>
                                    <div class="user-pubkey">${pubkeyShort}</div>
                                    ${about ? `<div class="user-about">${about.substring(0, 100)}${about.length > 100 ? '...' : ''}</div>` : ''}
                                </div>
                            </div>
                            <div class="user-actions">
                                <span class="signer-badge">✍️ Dernier signataire</span>
                                <a href="${profileViewerUrl}" target="_blank" class="profile-link" title="Voir le profil complet">
                                    👁️ Profil
                                </a>
                            </div>
                        </div>
                    `;
                    
                    footer.innerHTML = profileHTML;
                    footer.style.display = 'block';
                    
                    console.log('✅ Profil du signataire affiché dans le footer');
                } catch (error) {
                    console.error('Erreur lors de l\'affichage du profil:', error);
                }
            }
            
            // Fonction pour déconnecter l'utilisateur
            function disconnectNostr() {
                nostrConnected = false;
                userPublicKey = null;
                userPrivateKey = null;
                
                // Réinitialiser les boutons
                const connectBtn = document.getElementById('connectBtn');
                
                if (connectBtn) {
                    connectBtn.textContent = '🔗 Connect';
                    connectBtn.classList.remove('connected');
                }
                
                // Masquer le footer
                const footer = document.querySelector('.footer');
                if (footer) {
                    footer.style.display = 'none';
                }
                
                console.log('👋 Utilisateur déconnecté');
            }
            
            // Fonction pour charger le profil du dernier signataire
            async function loadLastSignerProfile() {
                try {
                    console.log('👤 Chargement du profil du dernier signataire...');
                    
                    // Charger le fichier des signatures
                    const response = await fetch('_signatures');
                    if (!response.ok) {
                        console.log('⚠️ Aucun fichier de signatures trouvé');
                        return;
                    }
                    
                    const signaturesText = await response.text();
                    const lines = signaturesText.split('\n').filter(line => line.trim() && !line.startsWith('#'));
                    
                    if (lines.length === 0) {
                        console.log('⚠️ Aucune signature trouvée');
                        return;
                    }
                    
                    // Prendre la dernière signature (publish)
                    const publishLines = lines.filter(line => line.includes('|publish'));
                    if (publishLines.length === 0) {
                        console.log('⚠️ Aucune signature de publication trouvée');
                        return;
                    }
                    
                    const lastPublish = publishLines[publishLines.length - 1];
                    const [timestamp, cid, signer, action] = lastPublish.split('|');
                    
                    console.log(`👨‍✈️ Dernier signataire: ${signer}`);
                    
                    // Essayer de charger la clé HEX du signataire (vraie clé du système)
                    let signerPubkey = null;
                    try {
                        const hexResponse = await fetch(`frd/multipass/${signer}.hex`);
                        if (hexResponse.ok) {
                            signerPubkey = await hexResponse.text();
                            signerPubkey = signerPubkey.trim();
                            console.log(`🔑 Clé HEX du signataire: ${signerPubkey}`);
                        } else {
                            // Fallback: essayer avec .npub si .hex n'existe pas
                            const npubResponse = await fetch(`frd/multipass/${signer}.npub`);
                            if (npubResponse.ok) {
                                signerPubkey = await npubResponse.text();
                                signerPubkey = signerPubkey.trim();
                                console.log(`📝 NPUB du signataire: ${signerPubkey}`);
                            }
                        }
                    } catch (e) {
                        console.log(`⚠️ Impossible de charger la clé publique pour ${signer}`);
                    }
                    
                    // Créer un profil basique avec les informations disponibles
                    const profileData = {
                        name: signer.split('@')[0], // Utiliser la partie avant @ comme nom
                        display_name: `${signer.split('@')[0]} (${signer})`,
                        about: `✍️ Signataire MULTIPASS Astroport.ONE\n📧 ${signer}\n🕐 Dernière publication: ${new Date(timestamp).toLocaleString('fr-FR')}`,
                        picture: null
                    };
                    
                    // Afficher le profil dans le footer
                    displayUserProfile(profileData, signerPubkey || 'multipass_' + signer.replace(/[^a-zA-Z0-9]/g, '_'));
                    
                } catch (error) {
                    console.error('❌ Erreur lors du chargement du profil du signataire:', error);
                }
            }
            
            // Fonction pour afficher les signatures de la chaîne
            async function showSignatures() {
                try {
                    const response = await fetch('_signatures');
                    if (!response.ok) {
                        alert('Aucun fichier de signatures trouvé');
                        return;
                    }
                    
                    const signaturesText = await response.text();
                    const lines = signaturesText.split('\n').filter(line => line.trim() && !line.startsWith('#'));
                    
                    if (lines.length === 0) {
                        alert('Aucune signature trouvée');
                        return;
                    }
                    
                    // Créer une modal pour afficher les signatures
                    const modal = document.createElement('div');
                    modal.style.cssText = `
                        position: fixed; top: 0; left: 0; right: 0; bottom: 0; 
                        background: rgba(0,0,0,0.8); z-index: 2000; 
                        display: flex; align-items: center; justify-content: center;
                        padding: 20px;
                    `;
                    
                    const content = document.createElement('div');
                    content.style.cssText = `
                        background: var(--bg-gradient-start); 
                        border: 1px solid var(--border-dynamic); 
                        border-radius: 8px; 
                        padding: 20px; 
                        max-width: 80%; 
                        max-height: 80%; 
                        overflow-y: auto;
                        color: var(--fg);
                    `;
                    
                    let html = '<h2 style="color: var(--accent-dynamic); margin-bottom: 20px;">✍️ Signatures de la Chaîne FRD</h2>';
                    html += '<div style="font-family: monospace; font-size: 0.9em;">';
                    
                    lines.reverse().forEach(line => {
                        const [timestamp, cid, signer, action] = line.split('|');
                        const actionIcon = action === 'publish' ? '📡' : '📋';
                        const actionText = action === 'publish' ? 'Publication' : 'Copie';
                        const shortCid = cid ? cid.substring(0, 12) + '...' : 'N/A';
                        
                        html += `
                            <div style="
                                border: 1px solid var(--border-dynamic); 
                                border-radius: 6px; 
                                padding: 12px; 
                                margin-bottom: 10px; 
                                background: rgba(0,0,0,0.2);
                            ">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <strong style="color: var(--accent-dynamic);">${actionIcon} ${actionText}</strong>
                                        <div style="color: #8b949e; font-size: 0.8em; margin-top: 4px;">
                                            👨‍✈️ ${signer}<br>
                                            📅 ${timestamp}<br>
                                            💾 ${shortCid}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                    });
                    
                    html += '</div>';
                    html += '<div style="text-align: center; margin-top: 20px;">';
                    html += '<button onclick="this.closest(\'.modal\').remove()" style="background: var(--accent-dynamic); color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer;">Fermer</button>';
                    html += '</div>';
                    
                    content.innerHTML = html;
                    modal.appendChild(content);
                    modal.className = 'modal';
                    
                    // Fermer en cliquant à l'extérieur
                    modal.addEventListener('click', (e) => {
                        if (e.target === modal) {
                            modal.remove();
                        }
                    });
                    
                    document.body.appendChild(modal);
                    
                } catch (error) {
                    console.error('Erreur lors du chargement des signatures:', error);
                    alert('Erreur lors du chargement des signatures: ' + error.message);
                }
            }
            
            // Initialiser Mermaid
            function initializeMermaid() {
                if (typeof mermaid !== 'undefined') {
                    mermaid.initialize({
                        startOnLoad: false,
                        theme: 'dark',
                        themeVariables: {
                            primaryColor: '#58a6ff',
                            primaryTextColor: '#f0f6fc',
                            primaryBorderColor: '#30363d',
                            lineColor: '#8b949e',
                            secondaryColor: '#21262d',
                            tertiaryColor: '#161b22',
                            background: '#0d1117',
                            mainBkg: '#21262d',
                            secondBkg: '#161b22',
                            tertiaryBkg: '#0d1117'
                        },
                        flowchart: {
                            useMaxWidth: true,
                            htmlLabels: true
                        },
                        sequence: {
                            useMaxWidth: true,
                            wrap: true
                        },
                        gantt: {
                            useMaxWidth: true
                        }
                    });
                    console.log('✅ Mermaid initialisé avec le thème sombre');
                } else {
                    console.warn('⚠️ Mermaid.js non disponible');
                }
            }
            
            // Fonction pour rendre les diagrammes Mermaid
            async function renderMermaidDiagrams() {
                if (typeof mermaid === 'undefined') {
                    console.warn('⚠️ Mermaid.js non chargé, saut du rendu des diagrammes');
                    return;
                }
                
                try {
                    // Trouver tous les blocs de code mermaid
                    const mermaidBlocks = document.querySelectorAll('pre code.language-mermaid, pre code.mermaid');
                    console.log(`🔍 ${mermaidBlocks.length} diagramme(s) Mermaid trouvé(s)`);
                    
                    for (let i = 0; i < mermaidBlocks.length; i++) {
                        const block = mermaidBlocks[i];
                        const mermaidCode = block.textContent;
                        const diagramId = `mermaid-diagram-${Date.now()}-${i}`;
                        
                        // Créer un conteneur pour le diagramme
                        const diagramContainer = document.createElement('div');
                        diagramContainer.className = 'mermaid-container';
                        diagramContainer.style.cssText = 'margin: 20px 0; padding: 20px; background: #161b22; border-radius: 8px; border: 1px solid #30363d; text-align: center;';
                        
                        try {
                            // Rendre le diagramme Mermaid
                            const { svg } = await mermaid.render(diagramId, mermaidCode);
                            diagramContainer.innerHTML = svg;
                            
                            // Remplacer le bloc de code par le diagramme rendu
                            block.parentElement.parentElement.replaceChild(diagramContainer, block.parentElement);
                            
                            console.log(`✅ Diagramme Mermaid ${i + 1} rendu avec succès`);
                        } catch (error) {
                            console.error(`❌ Erreur rendu diagramme Mermaid ${i + 1}:`, error);
                            
                            // En cas d'erreur, afficher le code avec un message d'erreur
                            diagramContainer.innerHTML = `
                                <div style="color: #f85149; font-family: monospace; font-size: 0.9em;">
                                    <strong>❌ Erreur rendu Mermaid:</strong><br>
                                    ${error.message || 'Erreur inconnue'}<br><br>
                                    <details style="text-align: left;">
                                        <summary>Code source:</summary>
                                        <pre style="background: #0d1117; padding: 10px; border-radius: 4px; margin-top: 10px;">${mermaidCode}</pre>
                                    </details>
                                </div>
                            `;
                            block.parentElement.parentElement.replaceChild(diagramContainer, block.parentElement);
                        }
                    }
                } catch (error) {
                    console.error('❌ Erreur générale lors du rendu Mermaid:', error);
                }
            }
            
            // Charger README.md au démarrage ou le fichier spécifié dans l'URL
            document.addEventListener('DOMContentLoaded', () => {
                // Initialiser Mermaid
                initializeMermaid();
                
                // Menu déjà généré côté serveur - pas besoin de populateNavMenu()
                console.log('✅ Menu de navigation prêt');
                
                // Charger le profil du dernier signataire
                setTimeout(() => {
                    loadLastSignerProfile();
                }, 1000); // Attendre 1 seconde pour que la page soit bien chargée
                
                if (!parseInitialUrl()) {
                    loadReadme();
                    // Gérer l'ancre initiale après un délai plus long pour le rendu complet
                    setTimeout(() => handleAnchors(), 800);
                }
            });
    </script>
</body>
</html>
HTMLEOF
    
    # Générer le menu des fichiers .md
    generate_markdown_menu
    
    # Remplacer les placeholders par les valeurs réelles
    sed -i "s/PAGE_TITLE_PLACEHOLDER/$PAGE_TITLE_ESCAPED/g" ${MY_PATH}/index.html
    sed -i "s/GENERATION_DATE_PLACEHOLDER/$GENERATION_DATE/g" ${MY_PATH}/index.html
    sed -i "s/IPFS_NODE_ID_PLACEHOLDER/$IPFS_NODE_ID/g" ${MY_PATH}/index.html
    sed -i "s/GENESIS_CID_PLACEHOLDER/$GENESIS_CID_PARAM/g" ${MY_PATH}/index.html
    sed -i "s/EVOLUTION_COUNT_PLACEHOLDER/$EVOLUTION_COUNT/g" ${MY_PATH}/index.html
    
    # Remplacer le placeholder de l'ancien CID
    if [[ "$OLD_CID_PARAM" == "genesis" ]]; then
        # Cas genesis : masquer le bouton version précédente
        sed -i 's/<a href="\/ipfs\/OLD_CID_PLACEHOLDER\/" class="header-icon" id="prevVersionBtn" title="Version précédente">⏮️<\/a>/<span class="header-icon" style="opacity: 0.3; cursor: not-allowed;" title="Pas de version précédente">⏮️<\/span>/g' ${MY_PATH}/index.html
        # Modifier le footer
        sed -i '/<div style="margin-top: 10px;" id="previous-version-link">/,/<\/div>/{
            s/<div style="margin-top: 10px;" id="previous-version-link">/<div style="margin-top: 10px; color: #6e7681;">/
            s/<span>📜 Previous version: <\/span>/<span>🌱 Genesis version - First publication<\/span>/
            s/<a href="\/ipfs\/OLD_CID_PLACEHOLDER\/" style="color: #58a6ff;">OLD_CID_PLACEHOLDER<\/a>//
        }' ${MY_PATH}/index.html
    else
        # Cas normal : remplacer par le CID précédent
        sed -i "s/OLD_CID_PLACEHOLDER/$OLD_CID_PARAM/g" ${MY_PATH}/index.html
    fi
}

# Fonction de reset de la chaîne
reset_chain() {
    echo "⚠️  ATTENTION: Cette opération va supprimer toute l'historique de la chaîne !"
    echo "📋 Fichiers qui seront supprimés:"
    ls -la ${MY_PATH}/_chain* ${MY_PATH}/_moats ${MY_PATH}/_signatures 2>/dev/null || echo "   (Aucun fichier de chaîne trouvé)"
    if [[ -d ${MY_PATH}/frd/multipass/ ]]; then
        echo "📁 Répertoire MULTIPASS:"
        ls -la ${MY_PATH}/frd/multipass/ 2>/dev/null
    fi
    echo ""
    
    if [[ "$FORCE_RESET" == "false" ]]; then
        read -p "🤔 Êtes-vous sûr de vouloir réinitialiser ? (oui/non): " confirm
        
        if [[ "$confirm" != "oui" && "$confirm" != "o" && "$confirm" != "yes" && "$confirm" != "y" ]]; then
            echo "❌ Reset annulé"
            exit 0
        fi
    else
        echo "⚡ Mode forcé - Pas de confirmation demandée"
    fi
    
    echo "🗑️  Suppression des fichiers de chaîne existants..."
    rm -f ${MY_PATH}/_chain*
    rm -f ${MY_PATH}/_moats
    rm -f ${MY_PATH}/_signatures
    rm -rf ${MY_PATH}/frd/multipass/
    echo "✅ Chaîne réinitialisée - Prochaine publication sera une nouvelle Genesis"
    echo "🌱 Nouveau départ : Evolution #0"
    echo "🧹 Signatures et profils MULTIPASS supprimés"
}

# Gestion du reset si demandé
if [[ "$RESET_CHAIN" == "true" ]]; then
    reset_chain
fi

OLD=$(cat ${MY_PATH}/_chain 2>/dev/null)
[[ -z ${OLD} ]] && init_capsule

[[ -z ${OLD} ]] \
    && GENESYS=$(ipfs add -rwq ${MY_PATH}/* | tail -n 1) \
    && echo ${GENESYS} > ${MY_PATH}/_chain \
    && echo "CHAIN BLOC ZERO : ${GENESYS}" \


echo "## TIMESTAMP CHAIN SHIFTING"
cp ${MY_PATH}/_chain \
        ${MY_PATH}/_chain.$(cat ${MY_PATH}/_moats)

# Nettoyage des anciens fichiers _chain (ne garde que les 2 plus récents, mais préserve genesis et n)
echo "## CLEANING OLD CHAIN FILES"
ls -t ${MY_PATH}/_chain.* 2>/dev/null | grep -v "_chain.genesis" | grep -v "_chain.n" | tail -n +3 | xargs rm -f 2>/dev/null || true

echo "## INDEX.HTML PRE-GENERATION"
# Toujours créer/recréer l'index.html AVANT la génération IPFS
echo "🌐 Génération de l'index.html..."
# Supprimer l'ancien index.html s'il existe pour forcer la régénération
[[ -f ${MY_PATH}/index.html ]] && rm ${MY_PATH}/index.html

# Préparer le compteur d'évolutions (prévoir l'incrémentation)
if [[ ! -f ${MY_PATH}/_chain.genesis ]]; then
    # Premier run : sera genesis, mais on ne connaît pas encore le CID final
    NEXT_EVOLUTION_COUNT="0"
    # Utiliser l'ancien CID comme genesis temporaire (sera corrigé après)
    GENESIS_CID=${OLD:-"genesis"}
else
    # Run suivant : incrémenter le compteur
    CURRENT_COUNT=$(cat ${MY_PATH}/_chain.n 2>/dev/null || echo "0")
    NEXT_EVOLUTION_COUNT=$((CURRENT_COUNT + 1))
    GENESIS_CID=$(cat ${MY_PATH}/_chain.genesis)
fi

# Récupérer le vrai ancien CID depuis le fichier de sauvegarde
REAL_OLD_CID=$(ls -t ${MY_PATH}/_chain.* 2>/dev/null | grep -v "_chain.genesis" | grep -v "_chain.n" | head -n 1 | xargs cat 2>/dev/null || echo "genesis")

generate_index_html "${REAL_OLD_CID}" "${GENESIS_CID}" "${NEXT_EVOLUTION_COUNT}"

IPFSME=$(ipfs add -rwq --ignore=.git --ignore-rules-path=.gitignore ${MY_PATH}/* | tail -n 1)

[[ ${IPFSME} == ${OLD} ]] && echo "No change." && exit 0

echo "## CHAIN UPGRADE"
echo ${IPFSME} > ${MY_PATH}/_chain
echo ${MOATS} > ${MY_PATH}/_moats

# Gestion du CID genesis et du compteur d'évolutions
if [[ ! -f ${MY_PATH}/_chain.genesis ]]; then
    # Premier run : sauvegarder le CID genesis
    echo ${IPFSME} > ${MY_PATH}/_chain.genesis
    echo "0" > ${MY_PATH}/_chain.n
    echo "🌱 Genesis CID sauvegardé: ${IPFSME}"
else
    # Sauvegarder le compteur d'évolutions (déjà calculé dans NEXT_EVOLUTION_COUNT)
    echo ${NEXT_EVOLUTION_COUNT} > ${MY_PATH}/_chain.n
    echo "🔄 Évolution #${NEXT_EVOLUTION_COUNT} depuis Genesis"
fi

echo "## README UPGRADE ${OLD}~${IPFSME}"

echo "## INDEX.HTML UPDATE"
# L'index.html est déjà généré avec les bons CIDs, pas besoin de mise à jour supplémentaire
echo "✅ index.html généré avec les métadonnées à jour"

echo "## MULTIPASS SIGNATURE & NOSTR PUBLICATION"
# Sélectionner le MULTIPASS signataire
if select_multipass; then
    # Ajouter la signature de publication
    add_signature_to_chain "${IPFSME}" "${SELECTED_MULTIPASS}" "publish"
    
    # Envoyer l'événement NOSTR
    PROJECT_NAME=$(basename ${MY_PATH})
    CURRENT_EVOLUTION_COUNT=$(cat ${MY_PATH}/_chain.n 2>/dev/null || echo "0")
    
    if send_nostr_capsule_event "${IPFSME}" "${PROJECT_NAME}" "${CURRENT_EVOLUTION_COUNT}"; then
        echo "📡 Événement NOSTR publié avec succès"
    else
        echo "⚠️ Échec de la publication NOSTR, mais la capsule IPFS est créée"
    fi
else
    echo "⚠️ Aucun MULTIPASS sélectionné, publication sans signature NOSTR"
fi

echo "## AUTO GIT"
echo '# ENTER COMMENT FOR YOUR COMMIT :'
git add .
read COMMENT \
&& git commit -m "$COMMENT :  http://127.0.0.1:8080/ipfs/${IPFSME}" \
&& git push

# Génération du message Nostr
PROJECT_NAME=$(basename ${MY_PATH})
NOSTR_MSG="📡 FRD Knowledge Capsule Updated: ${PROJECT_NAME}

🌐 IPFS: http://127.0.0.1:8080/ipfs/${IPFSME}/
📖 Docs: http://127.0.0.1:8080/ipfs/${IPFSME}/index.html

#frd #FRD #ipfs #knowledge #git #nostr"

echo ""
echo "🌟 ================================== 🌟"
echo "📡 CAPSULE FRD PUBLIÉE !"
echo "🌟 ================================== 🌟"
echo ""
echo "🔗 Accès:"
echo "   🌐 Portail : http://127.0.0.1:8080/ipfs/${IPFSME}/"
echo "   📖 Docs    : http://127.0.0.1:8080/ipfs/${IPFSME}/index.html"
echo ""

# Afficher les informations de signature si disponibles
if [[ -n "$SELECTED_MULTIPASS" ]]; then
    echo "✍️ Signature:"
    echo "   👨‍✈️ Signataire : $SELECTED_MULTIPASS"
    echo "   📡 NOSTR       : Publié"
    echo "   📋 uDRIVE      : Copié automatiquement"
    echo ""
fi

# Afficher les signatures existantes
if [[ -f "${MY_PATH}/_signatures" ]]; then
    sig_count=$(grep -v "^#" "${MY_PATH}/_signatures" 2>/dev/null | wc -l)
    if [[ $sig_count -gt 0 ]]; then
        echo "📜 Historique des signatures ($sig_count):"
        tail -n 5 "${MY_PATH}/_signatures" | grep -v "^#" | while IFS='|' read -r timestamp cid signer action; do
            echo "   $timestamp - $signer ($action)"
        done
        echo ""
    fi
fi

echo "📡 Message Nostr publié:"
echo "---"
echo "${NOSTR_MSG}"
echo "---"
echo ""
echo "💾 CID: ${IPFSME}"
echo "🌟 ================================== 🌟"

exit 0
