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
        ipfs get QmYLBpxWsXxYhoxomQTMMyZbnZas63Jpb8P6xdaGZzGwan -o ${MY_PATH}/
        mv ${MY_PATH}/QmYLBpxWsXxYhoxomQTMMyZbnZas63Jpb8P6xdaGZzGwan ${MY_PATH}/frd
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
    
    cat > ${MY_PATH}/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IPFS Evolutive Knowledge Capsule - Git Versioned Nostr Distribution</title>
    <script src="frd/marked.min.js"></script>
    <link rel="stylesheet" href="frd/github-dark.min.css">
    <script src="frd/highlight.min.js"></script>
    <link rel="stylesheet" href="frd/katex.min.css">
    <script defer src="frd/katex.min.js"></script>
    <script defer src="frd/auto-render.min.js"></script>
    <style>
        :root { --bg: #0d1117; --fg: #f0f6fc; --accent: #ffd700; --blue: #58a6ff; --border: #30363d; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, sans-serif; background: var(--bg); color: var(--fg); line-height: 1.6; margin: 0; }
        .header { background: #161b22; border-bottom: 1px solid var(--border); padding: 8px 15px; position: fixed; top: 0; left: 0; right: 0; z-index: 1000; }
        .header-nav { display: flex; align-items: center; justify-content: space-between; }
        .header-left { display: flex; align-items: center; gap: 10px; }
        .header-center { flex: 1; text-align: center; }
        .header-right { display: flex; align-items: center; gap: 8px; }
        .header h1 { color: var(--accent); margin: 0; font-size: 1.1rem; }
        .header-icon { background: #21262d; color: var(--blue); border: 1px solid var(--border); padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 0.8rem; text-decoration: none; transition: background 0.2s; }
        .header-icon:hover { background: #30363d; text-decoration: none; }
        .breadcrumb { color: #8b949e; font-size: 0.8rem; margin-left: 8px; }
        body { padding-top: 60px; }
        .container { max-width: 1000px; margin: 0 auto; padding: 20px; }
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
            .breadcrumb { display: none; }
            .header-right span { display: none; }
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-nav">
            <div class="header-left">
                <a id="backBtn" onclick="loadReadme()" class="header-icon" style="display: none;" title="Retour au README">🏠</a>
                <div id="breadcrumb" class="breadcrumb"></div>
            </div>
            <div class="header-center">
                <h1>📡 FRD</h1>
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
            const breadcrumb = document.getElementById('breadcrumb');
            
            if (filename === 'README.md') {
                backBtn.style.display = 'none';
                breadcrumb.textContent = anchor ? `📄 README ${anchor}` : '📄 README';
            } else {
                backBtn.style.display = 'inline-block';
                const shortName = filename.replace('.md', '').replace('Readme.', '').replace('README.', '');
                breadcrumb.textContent = anchor ? `📄 ${shortName} ${anchor}` : `📄 ${shortName}`;
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
                
                // Rendu des formules mathématiques
                if (window.renderMathInElement) {
                    renderMathInElement(content, { 
                        delimiters: [
                            {left: '$$', right: '$$', display: true}, 
                            {left: '$', right: '$', display: false},
                            {left: '\\[', right: '\\]', display: true},
                            {left: '\\(', right: '\\)', display: false}
                        ] 
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
                
                if (window.renderMathInElement) {
                    renderMathInElement(content, { 
                        delimiters: [
                            {left: '$$', right: '$$', display: true}, 
                            {left: '$', right: '$', display: false},
                            {left: '\\[', right: '\\]', display: true},
                            {left: '\\(', right: '\\)', display: false}
                        ] 
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
        
        // Charger README.md au démarrage ou le fichier spécifié dans l'URL
        document.addEventListener('DOMContentLoaded', () => {
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
    
    # Remplacer les placeholders par les valeurs réelles
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
