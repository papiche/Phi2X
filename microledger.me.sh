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
    
    # Détecter tous les fichiers .md dans le répertoire
    MD_FILES=""
    for file in ${MY_PATH}/*.md; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            if [[ -z "$MD_FILES" ]]; then
                MD_FILES="'$filename'"
            else
                MD_FILES="$MD_FILES, '$filename'"
            fi
        fi
    done
    
    # Si aucun fichier .md trouvé, utiliser README.md par défaut
    [[ -z "$MD_FILES" ]] && MD_FILES="'README.md'"
    
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
        body { font-family: -apple-system, sans-serif; background: var(--bg); color: var(--fg); line-height: 1.6; }
        .container { display: flex; min-height: 100vh; }
        .sidebar { width: 280px; background: #161b22; border-right: 1px solid var(--border); padding: 20px; position: fixed; height: 100vh; overflow-y: auto; }
        .sidebar h2 { color: var(--accent); margin-bottom: 20px; text-align: center; }
        .file-list { list-style: none; }
        .file-list li { margin-bottom: 8px; }
        .file-list a { display: block; padding: 8px 12px; color: #8b949e; text-decoration: none; border-radius: 6px; transition: all 0.2s; }
        .file-list a:hover { background: #21262d; color: var(--fg); }
        .file-list a.active { background: var(--blue); color: white; }
        .main-content { flex: 1; margin-left: 280px; padding: 40px; }
        .markdown-content { max-width: 900px; margin: 0 auto; }
        .markdown-content h1 { color: var(--accent); border-bottom: 2px solid var(--border); padding-bottom: 10px; margin-bottom: 30px; }
        .markdown-content h2 { color: var(--blue); margin-top: 40px; margin-bottom: 20px; }
        .markdown-content code { background: #161b22; padding: 2px 6px; border-radius: 3px; color: var(--accent); }
        .markdown-content pre { background: #161b22; padding: 16px; border-radius: 6px; overflow-x: auto; margin: 20px 0; }
        .markdown-content a { color: var(--blue); text-decoration: none; }
        .markdown-content a:hover { text-decoration: underline; }
        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; padding: 20px; } }
    </style>
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <h2>📡 FRD Docs</h2>
            <ul class="file-list" id="fileList"></ul>
        </nav>
        <main class="main-content">
            <div id="content"><div style="text-align: center; padding: 60px;">⏳ Chargement...</div></div>
        </main>
    </div>
    <script>
        marked.setOptions({ highlight: (code, lang) => lang && hljs.getLanguage(lang) ? hljs.highlight(code, { language: lang }).value : hljs.highlightAuto(code).value, breaks: true, gfm: true });
        
        let currentFile = '';
        
        async function loadMarkdown(filename) {
            const content = document.getElementById('content');
            content.innerHTML = '<div style="text-align: center; padding: 60px;">⏳ Chargement de ' + filename + '...</div>';
            try {
                const response = await fetch(filename);
                if (!response.ok) throw new Error(`Erreur ${response.status}`);
                const markdown = await response.text();
                content.innerHTML = '<div class="markdown-content">' + marked.parse(markdown) + '</div>';
                
                // Mettre à jour l'état actif
                document.querySelectorAll('.file-list a').forEach(a => a.classList.remove('active'));
                document.querySelectorAll('.file-list a').forEach(a => {
                    if (a.textContent === filename) a.classList.add('active');
                });
                
                currentFile = filename;
                if (window.renderMathInElement) {
                    renderMathInElement(content, { 
                        delimiters: [
                            {left: '$$', right: '$$', display: true}, 
                            {left: '$', right: '$', display: false}
                        ] 
                    });
                }
                window.scrollTo(0, 0);
            } catch (error) {
                content.innerHTML = `<div class="markdown-content"><h1>❌ Erreur</h1><p>Impossible de charger ${filename}</p><p>Détails: ${error.message}</p></div>`;
            }
        }
        
        function initFileList() {
            const fileList = document.getElementById('fileList');
            const files = [MD_FILES_PLACEHOLDER];
            
            files.forEach((file, i) => {
                const li = document.createElement('li');
                const a = document.createElement('a');
                a.href = '#';
                a.textContent = file;
                a.addEventListener('click', (e) => {
                    e.preventDefault();
                    loadMarkdown(file);
                });
                if (i === 0) a.classList.add('active');
                li.appendChild(a);
                fileList.appendChild(li);
            });
        }
        
        document.addEventListener('DOMContentLoaded', () => {
            initFileList();
            loadMarkdown('README.md');
        });
    </script>
</body>
</html>
HTMLEOF
    
    # Remplacer le placeholder par la liste des fichiers
    sed -i "s/MD_FILES_PLACEHOLDER/$MD_FILES/g" ${MY_PATH}/index.html
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

IPFSME=$(ipfs add -rwHq --ignore=.git --ignore-rules-path=.gitignore ${MY_PATH}/* | tail -n 1)

[[ ${IPFSME} == ${OLD} ]] && echo "No change." && exit 0

echo "## CHAIN UPGRADE"
echo ${IPFSME} > ${MY_PATH}/.chain
echo ${MOATS} > ${MY_PATH}/.moats

echo "## README UPGRADE ${OLD}~${IPFSME}"
sed -i "s~${OLD}~${IPFSME}~g" ${MY_PATH}/README.md

echo "## INDEX.HTML CHECK & UPDATE"
# Création de l'index.html s'il n'existe pas
if [[ ! -f ${MY_PATH}/index.html ]]; then
    echo "🌐 Création de l'index.html..."
    generate_index_html
fi

# Mise à jour des liens IPFS dans index.html
sed -i "s~${OLD}~${IPFSME}~g" ${MY_PATH}/index.html
echo "✅ index.html mis à jour avec le nouveau CID IPFS"

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
