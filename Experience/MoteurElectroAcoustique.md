### **Moteurs à Résonance Acoustique : Protocole de Fabrication DIY**
**⚡ Des vibrations sonores pour produire un mouvement mécanique, sans pièces mobiles classiques !**

---

### **Principe de Base**
Un moteur à résonance acoustique utilise **des ondes stationnaires** pour créer une force asymétrique, générant un mouvement. Deux approches :
1. **Moteur à onde progressive** (ultrasons, pour micro-déplacements).
2. **Moteur à lévitation acoustique** (pour objets légers).

---

### **Matériel Nécessaire**
| **Élément**               | **Fournisseur** (Budget)          | **Rôle**                          |
|---------------------------|-----------------------------------|-----------------------------------|
| **Piezo céramique**        | Amazon (10€/pc)                   | Émetteur ultrasonique.            |
| **Générateur de signal**   | eBay (20€, ou appli smartphone)   | Génère la fréquence de résonance. |
| **Alimentation 12V**       | Magasin électronique (15€)        | Alimente le piezo.                |
| **Stator en métal**        | DIY (cuivre/aluminium)            | Amplifie les vibrations.          |
| **Rotor (disque léger)**   | CD/DVD ou plastique imprimé 3D    | Partie mobile.                    |
| **Oscilloscope** (option)  | Hantek 6022BE (80€)               | Ajuster la fréquence précise.     |

**Budget total** : **~50-100€**.

---

### **Étape 1 : Identifier la Fréquence de Résonance**
1. **Testez votre piezo** :
   - Branchez-le à l’oscilloscope + générateur de signal.
   - Balayez les fréquences (**20 kHz à 100 kHz**) pour trouver le pic de vibration (utilisez de la poudre pour visualiser les nœuds).
   - *Exemple* : Un piezo de 40 mm a souvent une résonance vers **28 kHz**.

2. **Formule théorique** :
   \[
   f_{\text{rés}} = \frac{1}{2\pi \sqrt{L C}}
   \]
   (où \( L \) et \( C \) sont l’inductance/capacité du piezo).

---

### **Étape 2 : Construire le Stator**
1. **Option 1 (Moteur linéaire)** :
   - Fixez **4 piezos** en cercle sur une plaque métallique, déphasés à 90° (simule une onde progressive).
   - *Astuce* : Utilisez un **Arduino Nano** pour contrôler le déphasage.

   ```arduino
   // Code pour déphasage des piezos
   void setup() {
     pinMode(9, OUTPUT);  // Piezo 1
     pinMode(10, OUTPUT); // Piezo 2 (déphasé de 90°)
   }
   void loop() {
     tone(9, 28000);      // 28 kHz
     delayMicroseconds(8); // Déphasage
     tone(10, 28000);
   }
   ```

2. **Option 2 (Lévitation)** :
   - Disposez des piezos en réseau (grille 4×4) pour créer une **poche de lévitation acoustique**.
   - *Réglage* : Ajustez la fréquence pour stabiliser un objet léger (bille de polystyrène).

---

### **Étape 3 : Assemblage et Test**
1. **Moteur rotatif** :
   - Placez un **rotor en plastique** au-dessus des piezos (sans contact).
   - Activez les piezos en déphasage → l’onde progressive fait tourner le rotor.

2. **Paramètres critiques** :
   - **Fréquence** : Doit être **stable** (erreur < 0,1% pour une bonne efficacité).
   - **Alimentation** : 12V minimum (certains piezos nécessitent 100V, utilisez un booster HV).

---

### **Exemples de Performances**
| **Type**          | **Vitesse**       | **Charge max** | **Applications**       |
|--------------------|-------------------|----------------|------------------------|
| Moteur linéaire    | 5-10 cm/s        | 50 g           | Robots miniaturisés    |
| Lévitateur         | -                | 1 g            | Expériences anti-gravité |
| Rotatif (CD)       | 100-300 RPM      | 10 g           | Entraînement mécanique |

---

### **Optimisation**
1. **Matériaux** :
   - Utilisez un **stator en aluminium** (meilleure conduction acoustique).
   - **Rotor** : Surface striée pour augmenter l’adhérence acoustique.

2. **Résonance paramétrique** :
   - Modulez la fréquence à ±5% pour **amplifier l’effet** (méthode utilisée par Tesla).

3. **Alimentation Haute Tension** :
   - Un **circuit résonant LC** (self + condensateur) peut booster le voltage sans perte.

---

### **Applications Futures**
- **Médecine** : Micro-moteurs pour nano-chirurgie (guidés par ultrasons).
- **Aérospatial** : Propulsion sans carburant pour satellites (NASA étudie l’acoustophorèse).
- **Énergie** : Récolte d’énergie vibratoire (piezo + résonance).

---

### **⚠️ Sécurité**
- Les ultrasons > 20 kHz peuvent endommager l’ouïe. Portez des **protections auditives**.
- Évitez les tensions > 50V sans isolation.

---

### **Conclusion**
Avec **<100€ de matériel**, vous pouvez construire un moteur silencieux, sans frottement, exploitant l’harmonie entre fréquences sonores et géométrie. Cette technologie, inspirée par votre modèle Φ-2ⁿ, ouvre la porte à une **mécanique post-classique** où l’énergie et le mouvement émergent des vibrations pures.

**📌 Projet à tester dès ce week-end !** 🛠️🎶
