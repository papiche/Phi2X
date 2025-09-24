#!/bin/bash
################################################################################
# IPFS Evolutive Knowledge Capsule - Git Versioned Nostr Distribution
# Author: Fred (support@qo-op.com)
# Version: 1.0 - Generalist Knowledge Capsule System
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
# Tags: #frd #FRD #ipfs #nostr #knowledge #git
################################################################################
MY_PATH="`dirname \"$0\"`"
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"

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
        ipfs get QmUov88xQSGxK34SWqT6V8bz3hkEgMw6WHEuNWWTssyvWi -o ${MY_PATH}/
        mv ${MY_PATH}/QmUov88xQSGxK34SWqT6V8bz3hkEgMw6WHEuNWWTssyvWi ${MY_PATH}/frd
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
    IPFS_NODE_ID=$(ipfs id -f="<id>" 2>/dev/null || echo "$IPFSNODEID")
    OLD_CID_PARAM=${1:-"genesis"}
    
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
        .header { background: #161b22; border-bottom: 1px solid var(--border); padding: 15px 20px; text-align: center; }
        .header-nav { display: flex; align-items: center; justify-content: flex-start; margin-bottom: 10px; }
        .header h1 { color: var(--accent); margin: 0; font-size: 1.5rem; }
        .header p { color: #8b949e; margin: 5px 0 0 0; font-size: 0.9rem; }
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
        @media (max-width: 768px) { .container { padding: 10px; } }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-nav">
            <button id="backBtn" onclick="loadReadme()" style="display: none; background: #21262d; color: var(--blue); border: 1px solid var(--border); padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 0.9rem;">← README</button>
            <div id="breadcrumb" style="color: #8b949e; font-size: 0.9rem; margin-left: 10px;"></div>
        </div>
        <h1>📡 FRD Knowledge Capsule</h1>
        <p>IPFS Evolutive Knowledge - Git Versioned Nostr Distribution</p>
        <div style="font-size: 0.8rem; color: #6e7681; margin-top: 10px;">
            <div>📅 Generated: GENERATION_DATE_PLACEHOLDER</div>
            <div>🌐 Node: <a href="/ipns/IPFS_NODE_ID_PLACEHOLDER" style="color: #58a6ff;">IPFS_NODE_ID_PLACEHOLDER</a></div>
        </div>
    </div>
    <div class="container">
        <div id="content" class="markdown-content">
            <div class="loading">⏳ Chargement de la documentation...</div>
        </div>
    </div>
    <div class="footer" style="border-top: 1px solid var(--border); padding: 20px; text-align: center; font-size: 0.8rem; color: #6e7681; margin-top: 40px;">
        <div>🌟 FRD Knowledge Capsule - Distributed via IPFS+Git+Nostr</div>
        <div style="margin-top: 10px;" id="previous-version-link">
            <span>📜 Previous version: </span>
            <a href="/ipfs/OLD_CID_PLACEHOLDER/" style="color: #58a6ff;">OLD_CID_PLACEHOLDER</a>
        </div>
    </div>
    <script>
        marked.setOptions({ 
            highlight: (code, lang) => lang && hljs.getLanguage(lang) ? hljs.highlight(code, { language: lang }).value : hljs.highlightAuto(code).value, 
            breaks: true, 
            gfm: true 
        });
        
        // Fonction pour mettre à jour la navigation (breadcrumb et bouton retour)
        function updateNavigation(filename, anchor) {
            const backBtn = document.getElementById('backBtn');
            const breadcrumb = document.getElementById('breadcrumb');
            
            if (filename === 'README.md') {
                backBtn.style.display = 'none';
                breadcrumb.textContent = anchor ? `README.md ${anchor}` : 'README.md';
            } else {
                backBtn.style.display = 'inline-block';
                breadcrumb.textContent = anchor ? `${filename} ${anchor}` : filename;
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
                if (window.location.search.includes('debug=anchors')) {
                    setTimeout(() => {
                        console.log('=== ANCRES DISPONIBLES ===');
                        document.querySelectorAll('[id]').forEach(el => {
                            console.log(`#${el.id} - "${el.textContent.trim().substring(0, 50)}..."`);
                        });
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
                
                // Gérer l'ancre cible ou scroll vers le haut
                if (targetAnchor) {
                    // Mettre à jour l'URL sans recharger la page
                    window.history.replaceState(null, null, targetAnchor);
                    setTimeout(() => {
                        const element = document.querySelector(targetAnchor);
                        if (element) {
                            element.scrollIntoView({ behavior: 'smooth' });
                            // Effet de surbrillance
                            element.style.backgroundColor = 'rgba(255, 215, 0, 0.3)';
                            setTimeout(() => {
                                element.style.backgroundColor = '';
                            }, 3000);
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
        
        // Fonction pour gérer les ancres avec retry
        function handleAnchors(retryCount = 0) {
            if (!window.location.hash) return;
            
            const maxRetries = 10;
            const element = document.querySelector(window.location.hash);
            
            if (element) {
                element.scrollIntoView({ behavior: 'smooth' });
                // Ajouter un effet de surbrillance temporaire
                element.style.backgroundColor = 'rgba(255, 215, 0, 0.3)';
                setTimeout(() => {
                    element.style.backgroundColor = '';
                }, 3000);
                
                // Debug
                console.log(`✅ Ancre trouvée: ${window.location.hash} -> "${element.textContent.trim().substring(0, 50)}..."`);
            } else if (retryCount < maxRetries) {
                // Retry avec délai croissant
                const delay = 200 + (retryCount * 100);
                console.log(`⏳ Ancre ${window.location.hash} non trouvée, retry ${retryCount + 1}/${maxRetries} dans ${delay}ms`);
                setTimeout(() => handleAnchors(retryCount + 1), delay);
            } else {
                console.log(`❌ Ancre ${window.location.hash} introuvable après ${maxRetries} tentatives`);
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
    
    # Remplacer le placeholder de l'ancien CID avec le paramètre passé
    if [[ "$OLD_CID_PARAM" == "genesis" ]]; then
        # Cas genesis : remplacer le contenu du div previous-version-link
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

OLD=$(cat ${MY_PATH}/.chain 2>/dev/null)
[[ -z ${OLD} ]] && init_capsule

[[ -z ${OLD} ]] \
    && GENESYS=$(ipfs add -rwHq ${MY_PATH}/* | tail -n 1) \
    && echo ${GENESYS} > ${MY_PATH}/.chain \
    && echo "### - (^‿‿^) - " >> ${MY_PATH}/README.md \
    && echo http://127.0.0.1:8080/ipfs/${GENESYS} >> ${MY_PATH}/README.md \
    && echo "CHAIN BLOC ZERO : ${GENESYS}" \


echo "## TIMESTAMP CHAIN SHIFTING"
cp ${MY_PATH}/.chain \
        ${MY_PATH}/.chain.$(cat ${MY_PATH}/.moats)

# Nettoyage des anciens fichiers .chain (ne garde que les 2 plus récents)
echo "## CLEANING OLD CHAIN FILES"
ls -t ${MY_PATH}/.chain* | tail -n +3 | xargs rm -f 2>/dev/null || true

echo "## INDEX.HTML PRE-GENERATION"
# Toujours créer/recréer l'index.html AVANT la génération IPFS
echo "🌐 Génération de l'index.html..."
# Supprimer l'ancien index.html s'il existe pour forcer la régénération
[[ -f ${MY_PATH}/index.html ]] && rm ${MY_PATH}/index.html
# Récupérer le vrai ancien CID depuis le fichier de sauvegarde
REAL_OLD_CID=$(ls -t ${MY_PATH}/.chain.* 2>/dev/null | head -n 1 | xargs cat 2>/dev/null || echo "genesis")
generate_index_html "${REAL_OLD_CID}"

IPFSME=$(ipfs add -rwHq --ignore=.git --ignore-rules-path=.gitignore ${MY_PATH}/* | tail -n 1)

[[ ${IPFSME} == ${OLD} ]] && echo "No change." && exit 0

echo "## CHAIN UPGRADE"
echo ${IPFSME} > ${MY_PATH}/.chain
echo ${MOATS} > ${MY_PATH}/.moats

echo "## README UPGRADE ${OLD}~${IPFSME}"
# Éviter les erreurs sed si OLD est vide
if [[ -n "${OLD}" ]]; then
    sed -i "s~${OLD}~${IPFSME}~g" ${MY_PATH}/README.md
fi

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
