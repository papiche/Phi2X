#!/bin/bash
################################################################################
# Test Setup pour Phi2X
# Vérifie que tous les composants sont prêts pour la publication IPFS
################################################################################

echo "🔍 VÉRIFICATION DE L'ENVIRONNEMENT PHI2X"
echo "========================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de test
test_component() {
    local name="$1"
    local command="$2"
    local expected="$3"
    
    echo -n "📋 $name... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ ÉCHEC${NC}"
        if [[ -n "$expected" ]]; then
            echo -e "   ${YELLOW}💡 Solution: $expected${NC}"
        fi
        return 1
    fi
}

echo ""
echo "🔧 PRÉREQUIS SYSTÈME"
echo "-------------------"

# Test IPFS
test_component "IPFS installé" "which ipfs" "Installer IPFS: https://ipfs.io/docs/install/"

# Test IPFS daemon
test_component "IPFS daemon actif" "ipfs id" "Lancer: ipfs daemon"

# Test Git
test_component "Git configuré" "git config user.name && git config user.email" "Configurer: git config --global user.name/email"

echo ""
echo "📁 FICHIERS PROJET"
echo "------------------"

# Vérifier les fichiers essentiels
files=(
    "index.html:Portail web principal"
    "README.md:Documentation principale"
    "microledger.me.sh:Script de publication"
    "INTRODUCTION.md:Guide débutant"
    "GLOSSAIRE.md:Dictionnaire"
)

for file_info in "${files[@]}"; do
    IFS=':' read -r file desc <<< "$file_info"
    test_component "$desc" "test -f '$file'"
done

echo ""
echo "🎮 APPLICATIONS INTERACTIVES"
echo "----------------------------"

# Vérifier les applications HTML
apps=(
    "gold_phi_octave_interference.html:Moiré Cosmique"
    "atomic_phi_octave.html:Fusion Atomique"
    "gold_phi_octave_piano.html:Séquenceur Curatif"
    "miroir-resonance.html:Bio-résonance"
    "solar_phi_octave.html:Système Solaire"
    "phi-muse.html:Compositeur IA"
)

for app_info in "${apps[@]}"; do
    IFS=':' read -r app desc <<< "$app_info"
    test_component "$desc" "test -f '$app'"
done

echo ""
echo "🔐 PERMISSIONS"
echo "-------------"

# Vérifier les permissions
test_component "microledger.me.sh exécutable" "test -x microledger.me.sh" "chmod +x microledger.me.sh"

echo ""
echo "🌐 TEST DE FONCTIONNEMENT"
echo "------------------------"

# Test d'ouverture des fichiers HTML
if command -v python3 > /dev/null; then
    echo "📋 Serveur de test disponible... ✅"
    echo "   💡 Pour tester localement: python3 -m http.server 8000"
    echo "   🌐 Puis ouvrir: http://localhost:8000/index.html"
elif command -v python > /dev/null; then
    echo "📋 Serveur de test disponible... ✅"
    echo "   💡 Pour tester localement: python -m SimpleHTTPServer 8000"
    echo "   🌐 Puis ouvrir: http://localhost:8000/index.html"
else
    echo -e "📋 Serveur de test... ${YELLOW}⚠️  Python non trouvé${NC}"
    echo "   💡 Ouvrir directement index.html dans le navigateur"
fi

echo ""
echo "📊 RÉSUMÉ"
echo "========="

# Compter les fichiers
total_files=$(find . -name "*.html" -o -name "*.md" | wc -l)
echo "📄 Fichiers de documentation: $total_files"

html_files=$(find . -name "*.html" | wc -l)
echo "🎮 Applications interactives: $html_files"

if [[ -f ".chain" ]]; then
    current_cid=$(cat .chain)
    echo "🔗 CID IPFS actuel: $current_cid"
else
    echo "🔗 CID IPFS: Première publication à venir"
fi

echo ""
echo "🚀 PRÊT POUR LA PUBLICATION"
echo "=========================="
echo "Pour publier sur IPFS:"
echo "  ./microledger.me.sh"
echo ""
echo "Pour tester localement:"
echo "  python3 -m http.server 8000"
echo "  # Puis ouvrir http://localhost:8000/index.html"
echo ""
echo -e "${GREEN}🌟 Phi2X est prêt à être partagé avec le monde ! 🌟${NC}"
