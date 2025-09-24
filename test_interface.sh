#!/bin/bash
################################################################################
# Test de l'interface FRD
################################################################################

echo "🧪 TEST DE L'INTERFACE FRD"
echo "=========================="
echo ""

# Récupérer le CID actuel
CID=$(cat .chain 2>/dev/null)
if [[ -z "$CID" ]]; then
    echo "❌ Aucun CID trouvé. Exécutez d'abord ./microledger.me.sh"
    exit 1
fi

echo "📡 CID IPFS actuel: $CID"
echo ""

# Tester l'accès aux fichiers
echo "🔍 Test d'accès aux fichiers:"
echo "-----------------------------"

for file in *.md; do
    if [[ -f "$file" ]]; then
        echo -n "📄 $file: "
        if curl -s --max-time 5 "http://127.0.0.1:8080/ipfs/$CID/$file" > /dev/null; then
            echo "✅ OK"
        else
            echo "❌ ERREUR"
        fi
    fi
done

echo ""
echo "🌐 URLs d'accès:"
echo "----------------"
echo "🏠 Portail principal: http://127.0.0.1:8080/ipfs/$CID/"
echo "📖 Interface docs:    http://127.0.0.1:8080/ipfs/$CID/index.html"
echo "📄 README direct:     http://127.0.0.1:8080/ipfs/$CID/README.md"
echo ""

# Tester l'interface HTML
echo "🧪 Test de l'interface HTML:"
echo "-----------------------------"
if curl -s --max-time 5 "http://127.0.0.1:8080/ipfs/$CID/index.html" | grep -q "FRD Knowledge"; then
    echo "✅ Interface HTML accessible"
else
    echo "❌ Problème avec l'interface HTML"
fi

# Vérifier les bibliothèques FRD
echo ""
echo "📦 Vérification des bibliothèques FRD:"
echo "---------------------------------------"
for lib in frd/*.js frd/*.css; do
    if [[ -f "$lib" ]]; then
        echo -n "📚 $(basename $lib): "
        if curl -s --max-time 5 "http://127.0.0.1:8080/ipfs/$CID/$lib" > /dev/null; then
            echo "✅ OK"
        else
            echo "❌ ERREUR"
        fi
    fi
done

echo ""
echo "🎉 Test terminé !"
echo ""
echo "💡 Pour tester dans le navigateur:"
echo "   Ouvrez: http://127.0.0.1:8080/ipfs/$CID/"
