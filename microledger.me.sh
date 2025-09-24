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
        ipfs get QmUtWzpp1pmkBVeeLWJPMhx6ieBZriQd6PhLF4GKSomruJ -o ${MY_PATH}/
        mv ${MY_PATH}/QmUtWzpp1pmkBVeeLWJPMhx6ieBZriQd6PhLF4GKSomruJ ${MY_PATH}/frd
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

# Génération dynamique de l'index.html
generate_index_html() {
    PROJECT_NAME=$(basename ${MY_PATH})
    GENERATION_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    IPFS_NODE_ID=$(ipfs id -f="<id>" 2>/dev/null || echo "unknown")
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
        .nav-dropdown { display: none; position: absolute; top: 100%; left: 0; background: #21262d; border: 1px solid var(--border); border-radius: 6px; min-width: 200px; z-index: 1000; box-shadow: 0 4px 12px rgba(0,0,0,0.3); }
        .nav-dropdown.show { display: block; }
        .nav-dropdown a { display: block; padding: 8px 12px; color: var(--fg); text-decoration: none; border-bottom: 1px solid var(--border); transition: background 0.2s; }
        .nav-dropdown a:hover { background: #30363d; }
        .nav-dropdown a:last-child { border-bottom: none; }
        .nav-section-title { padding: 8px 12px; font-weight: bold; color: #58a6ff; border-top: 1px solid var(--border); margin-top: 4px; font-size: 0.9em; background: #161b22; }
        .nav-subsection a { padding-left: 24px; font-size: 0.9em; }
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
        .copy-btn { 
            background: linear-gradient(45deg, hsl(calc(var(--primary-hue) + 120), 70%, 60%), hsl(calc(var(--primary-hue) + 120), 70%, 50%)); 
            color: white; 
            border: none; 
            padding: 4px 8px; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 0.8rem; 
            text-decoration: none; 
            transition: all 0.3s ease; 
            margin-left: 8px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .copy-btn:hover { 
            background: linear-gradient(45deg, hsl(calc(var(--primary-hue) + 120), 70%, 50%), hsl(calc(var(--primary-hue) + 120), 70%, 40%)); 
            text-decoration: none; 
            color: white; 
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        .copy-btn:disabled { opacity: 0.5; cursor: not-allowed; }
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
            .nav-dropdown { min-width: 180px; right: 0; left: auto; }
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
                <button id="copyBtn" class="copy-btn" onclick="copyToUDrive()" disabled>📋 Copier</button>
            </div>
            <div class="header-right">
                <span style="font-size: 0.7rem; color: #6e7681;">GENERATION_DATE_PLACEHOLDER</span>
                <a href="/ipns/IPFS_NODE_ID_PLACEHOLDER" class="header-icon" title="IPFS Node: IPFS_NODE_ID_PLACEHOLDER">🌐</a>
                <a href="/ipfs/OLD_CID_PLACEHOLDER/" class="header-icon" id="prevVersionBtn" title="Version précédente">⏮️</a>
                <a href="/ipfs/GENESIS_CID_PLACEHOLDER/" class="header-icon" id="genesisBtn" title="Version Genesis">🌱</a>
                <span class="header-icon" id="evolutionCounter" title="Évolutions depuis Genesis">🔄 EVOLUTION_COUNT_PLACEHOLDER</span>
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
                
                // Debug : afficher les ancres disponibles dans la console
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
                
                if (window.location.search.includes('debug=anchors')) {
                    setTimeout(() => {
                        console.log('=== MODE DEBUG ANCHORS ACTIVÉ ===');
                    }, 500);
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
                // Afficher les ancres disponibles pour debug
                console.log('🔍 Ancres disponibles:');
                document.querySelectorAll('[id]').forEach(el => {
                    console.log(`  #${el.id} - "${el.textContent.trim().substring(0, 50)}..."`);
                });
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
                const copyBtn = document.getElementById('copyBtn');
                
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
                            copyBtn.disabled = false;
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
                                    copyBtn.disabled = false;
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
                try {
                    console.log('🔐 Début de l\'authentification NIP42...');
                    
                    // Obtenir l'URL du relai automatiquement
                    const relayUrl = getRelayURL();
                    console.log('🌐 URL du relai détectée:', relayUrl);
                    
                    // Créer un événement d'authentification NIP42 (kind 22242)
                    const authEvent = {
                        kind: 22242,
                        created_at: Math.floor(Date.now() / 1000),
                        tags: [
                            ['relay', relayUrl],
                            ['challenge', 'auth_' + Date.now()]
                        ],
                        content: 'Authentication for UPlanet API access',
                        pubkey: userPublicKey
                    };
                    
                    // Signer l'événement
                    let signedEvent;
                    if (window.nostr && window.nostr.signEvent) {
                        // Utiliser l'extension Nostr pour signer
                        signedEvent = await window.nostr.signEvent(authEvent);
                    } else if (userPrivateKey) {
                        // Signer avec la clé privée locale
                        signedEvent = NostrTools.finishEvent(authEvent, userPrivateKey);
                    } else {
                        throw new Error('Impossible de signer l\'événement d\'authentification');
                    }
                    
                    console.log('📝 Événement d\'authentification signé:', signedEvent);
                    
                    // Publier l'événement sur le relai
                    const published = await publishToRelay(signedEvent, relayUrl);
                    
                    if (published) {
                        console.log('✅ Authentification NIP42 réussie');
                        // Charger et afficher le profil utilisateur dans le footer
                        await loadUserProfile();
                        return true;
                    } else {
                        console.error('❌ Échec de la publication de l\'événement d\'authentification');
                        return false;
                    }
                    
                } catch (error) {
                    console.error('❌ Erreur lors de l\'authentification NIP42:', error);
                    return false;
                }
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
            function displayUserProfile(profileData) {
                try {
                    // Créer ou mettre à jour le footer
                    let footer = document.querySelector('.footer');
                    if (!footer) {
                        footer = document.createElement('div');
                        footer.className = 'footer';
                        document.body.appendChild(footer);
                    }
                    
                    // Construire le HTML du profil
                    const name = profileData.name || profileData.display_name || 'Utilisateur Nostr';
                    const picture = profileData.picture || '';
                    const about = profileData.about || '';
                    const pubkeyShort = userPublicKey.substring(0, 8) + '...' + userPublicKey.substring(-8);
                    
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
                                <button onclick="disconnectNostr()" class="disconnect-btn">🚪 Déconnecter</button>
                            </div>
                        </div>
                    `;
                    
                    footer.innerHTML = profileHTML;
                    footer.style.display = 'block';
                    
                    console.log('✅ Profil utilisateur affiché dans le footer');
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
                const copyBtn = document.getElementById('copyBtn');
                
                if (connectBtn) {
                    connectBtn.textContent = '🔗 Connect';
                    connectBtn.classList.remove('connected');
                }
                
                if (copyBtn) {
                    copyBtn.disabled = true;
                }
                
                // Masquer le footer
                const footer = document.querySelector('.footer');
                if (footer) {
                    footer.style.display = 'none';
                }
                
                console.log('👋 Utilisateur déconnecté');
            }
            
            // Fonction pour copier le projet vers uDRIVE
            async function copyToUDrive() {
                if (!nostrConnected || !userPublicKey) {
                    alert('Veuillez vous connecter à Nostr d\'abord');
                    return;
                }
                
                const copyBtn = document.getElementById('copyBtn');
                const originalText = copyBtn.textContent;
                
                try {
                    copyBtn.textContent = '⏳ Copie...';
                    copyBtn.disabled = true;
                    
                    // Détecter l'URL de l'API UPlanet
                    const currentURL = new URL(window.location.href);
                    const hostname = currentURL.hostname;
                    const protocol = currentURL.protocol;
                    let port = currentURL.port;
                    
                    if (port === "8080") {
                        port = "54321";
                    }
                    
                    const uHost = hostname.replace("ipfs", "u");
                    const apiUrl = protocol + "//" + uHost + (port ? ":" + port : "");
                    
                    console.log('API UPlanet détectée:', apiUrl);
                    
                    // Obtenir le CID actuel du projet
                    const currentCID = getCurrentProjectCID();
                    if (!currentCID) {
                        throw new Error('Impossible de déterminer le CID du projet');
                    }
                    
                    console.log('CID du projet à copier:', currentCID);
                    
                    // Préparer les données pour l'API
                    const copyData = {
                        project_url: currentCID,
                        npub: userPublicKey,
                        project_name: getProjectName()
                    };
                    
                    console.log('Données de copie:', copyData);
                    
                    // Appeler l'API de copie
                    const response = await fetch(apiUrl + '/api/copy_project', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(copyData)
                    });
                    
                    if (!response.ok) {
                        let errorMessage = `Erreur HTTP ${response.status}`;
                        try {
                            const errorData = await response.json();
                            if (errorData.detail) {
                                if (typeof errorData.detail === 'string') {
                                    errorMessage = errorData.detail;
                                } else if (errorData.detail.message) {
                                    errorMessage = errorData.detail.message;
                                } else {
                                    errorMessage = JSON.stringify(errorData.detail);
                                }
                            }
                        } catch (e) {
                            // Si ce n'est pas du JSON, essayer de lire comme texte
                            try {
                                const textError = await response.text();
                                if (textError) errorMessage = textError;
                            } catch (e2) {
                                errorMessage = `Erreur HTTP ${response.status}: ${response.statusText}`;
                            }
                        }
                        throw new Error(errorMessage);
                    }
                    
                    const result = await response.json();
                    console.log('Résultat de la copie:', result);
                    
                    copyBtn.textContent = '✅ Copié!';
                    
                    // Rediriger vers le nouveau CID si disponible
                    if (result.new_cid) {
                        setTimeout(() => {
                            const newUrl = protocol + "//" + hostname + (currentURL.port ? ":" + currentURL.port : "") + "/ipfs/" + result.new_cid + "/";
                            console.log('Redirection vers:', newUrl);
                            window.location.href = newUrl;
                        }, 1500);
                    } else {
                        setTimeout(() => {
                            copyBtn.textContent = originalText;
                            copyBtn.disabled = false;
                        }, 2000);
                    }
                    
                } catch (error) {
                    console.error('Erreur de copie:', error);
                    copyBtn.textContent = '❌ Erreur';
                    setTimeout(() => {
                        copyBtn.textContent = originalText;
                        copyBtn.disabled = false;
                    }, 2000);
                    alert('Erreur de copie: ' + error.message);
                }
            }
            
            // Fonction utilitaire pour obtenir le CID actuel
            function getCurrentProjectCID() {
                const url = window.location.href;
                const ipfsMatch = url.match(/\/ipfs\/([a-zA-Z0-9]+)/);
                return ipfsMatch ? ipfsMatch[1] : null;
            }
            
            // Fonction utilitaire pour obtenir le nom du projet
            function getProjectName() {
                const title = document.title;
                return title.replace(/[^a-zA-Z0-9\s]/g, '').trim() || 'Projet-FRD';
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
    ls -la ${MY_PATH}/.chain* ${MY_PATH}/.moats 2>/dev/null || echo "   (Aucun fichier de chaîne trouvé)"
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
    rm -f ${MY_PATH}/.chain*
    rm -f ${MY_PATH}/.moats
    echo "✅ Chaîne réinitialisée - Prochaine publication sera une nouvelle Genesis"
    echo "🌱 Nouveau départ : Evolution #0"
}

# Gestion du reset si demandé
if [[ "$RESET_CHAIN" == "true" ]]; then
    reset_chain
fi

OLD=$(cat ${MY_PATH}/.chain 2>/dev/null)
[[ -z ${OLD} ]] && init_capsule

[[ -z ${OLD} ]] \
    && GENESYS=$(ipfs add -rwHq ${MY_PATH}/* | tail -n 1) \
    && echo ${GENESYS} > ${MY_PATH}/.chain \
    && echo "CHAIN BLOC ZERO : ${GENESYS}" \


echo "## TIMESTAMP CHAIN SHIFTING"
cp ${MY_PATH}/.chain \
        ${MY_PATH}/.chain.$(cat ${MY_PATH}/.moats)

# Nettoyage des anciens fichiers .chain (ne garde que les 2 plus récents, mais préserve genesis et n)
echo "## CLEANING OLD CHAIN FILES"
ls -t ${MY_PATH}/.chain.* 2>/dev/null | grep -v ".chain.genesis" | grep -v ".chain.n" | tail -n +3 | xargs rm -f 2>/dev/null || true

echo "## INDEX.HTML PRE-GENERATION"
# Toujours créer/recréer l'index.html AVANT la génération IPFS
echo "🌐 Génération de l'index.html..."
# Supprimer l'ancien index.html s'il existe pour forcer la régénération
[[ -f ${MY_PATH}/index.html ]] && rm ${MY_PATH}/index.html

# Préparer le compteur d'évolutions (prévoir l'incrémentation)
if [[ ! -f ${MY_PATH}/.chain.genesis ]]; then
    # Premier run : sera genesis, mais on ne connaît pas encore le CID final
    NEXT_EVOLUTION_COUNT="0"
    # Utiliser l'ancien CID comme genesis temporaire (sera corrigé après)
    GENESIS_CID=${OLD:-"genesis"}
else
    # Run suivant : incrémenter le compteur
    CURRENT_COUNT=$(cat ${MY_PATH}/.chain.n 2>/dev/null || echo "0")
    NEXT_EVOLUTION_COUNT=$((CURRENT_COUNT + 1))
    GENESIS_CID=$(cat ${MY_PATH}/.chain.genesis)
fi

# Récupérer le vrai ancien CID depuis le fichier de sauvegarde
REAL_OLD_CID=$(ls -t ${MY_PATH}/.chain.* 2>/dev/null | grep -v ".chain.genesis" | grep -v ".chain.n" | head -n 1 | xargs cat 2>/dev/null || echo "genesis")

generate_index_html "${REAL_OLD_CID}" "${GENESIS_CID}" "${NEXT_EVOLUTION_COUNT}"

IPFSME=$(ipfs add -rwHq --ignore=.git --ignore-rules-path=.gitignore ${MY_PATH}/* | tail -n 1)

[[ ${IPFSME} == ${OLD} ]] && echo "No change." && exit 0

echo "## CHAIN UPGRADE"
echo ${IPFSME} > ${MY_PATH}/.chain
echo ${MOATS} > ${MY_PATH}/.moats

# Gestion du CID genesis et du compteur d'évolutions
if [[ ! -f ${MY_PATH}/.chain.genesis ]]; then
    # Premier run : sauvegarder le CID genesis
    echo ${IPFSME} > ${MY_PATH}/.chain.genesis
    echo "0" > ${MY_PATH}/.chain.n
    echo "🌱 Genesis CID sauvegardé: ${IPFSME}"
else
    # Sauvegarder le compteur d'évolutions (déjà calculé dans NEXT_EVOLUTION_COUNT)
    echo ${NEXT_EVOLUTION_COUNT} > ${MY_PATH}/.chain.n
    echo "🔄 Évolution #${NEXT_EVOLUTION_COUNT} depuis Genesis"
fi

echo "## README UPGRADE ${OLD}~${IPFSME}"

echo "## INDEX.HTML UPDATE"
# L'index.html est déjà généré avec les bons CIDs, pas besoin de mise à jour supplémentaire
echo "✅ index.html généré avec les métadonnées à jour"

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
echo "📡 Message Nostr à publier:"
echo "---"
echo "${NOSTR_MSG}"
echo "---"
echo ""
echo "💾 CID: ${IPFSME}"
echo "🌟 ================================== 🌟"

exit 0
