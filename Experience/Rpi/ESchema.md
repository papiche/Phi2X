Voici un **prototype expérimental** pour faire résonner une **bobine Tesla pancake** en exploitant les interférences de deux fréquences harmoniques issues des gammes Φⁿ et 2ᵐ.

---

## ⚡️ Objectif

Utiliser un **Raspberry Pi**, deux générateurs de fréquence logiciels (PWM via GPIO), et une **bobine Tesla pancake** pour créer une **interférence électromagnétique** dans le plan.

---

## 🧰 Composants nécessaires

| Composant                         | Détail technique                     |
| --------------------------------- | ------------------------------------ |
| 🎛 Raspberry Pi (Pi 3 ou 4)       | avec GPIO et Python                  |
| 🧲 Bobine Tesla pancake           | ≈50 à 100 spires de fil émaillé      |
| 🔌 MOSFET N (IRF540, IRFZ44N…)    | pour commuter le courant             |
| 🔋 Alim 12V (1-3 A)               | pour alimenter la bobine             |
| 📦 Diode de roue libre (1N4007)   | pour protéger le MOSFET              |
| ⚙️ Résistance de gate (220Ω)      | pour limiter l'impulsion de commande |
| 🧱 Breadboard + jumpers           | pour câblage rapide                  |
| 📈 Option : capteur piézo / micro | pour mesurer la résonance            |

---

## ⚙️ Schéma de câblage

```
Raspberry Pi GPIO 18 (PWM1) ----┐
                                │
                             220Ω
                                │
                              Gate
                             |/
12V + ---[Bobine Pancake]---|    IRF540 MOSFET
                             |\\
                             |  Drain
                             |
                           Source ----- GND (alimentation & RPi)
                             |
                          1N4007 (cathode vers +12V)
                             |
                           GND
```

---

## 🧠 Principe

* La bobine pancake est **excitée en fréquence** par un PWM à haute fréquence (5kHz–500kHz).
* Le Raspberry Pi génère deux ondes harmoniques (Φⁿ et 2ᵐ), modulant le signal PWM (via la **fréquence ou le rapport cyclique**).
* L’interférence mécanique/électromagnétique se manifeste sur la bobine — et peut être captée.

---

## 🧾 Script Python : `tesla_pancake_phi2m.py`

```python
import RPi.GPIO as GPIO
import time
import math

# === CONFIGURATION ===
PWM_PIN = 18
FREQ_BASE = 1000  # Hz (f₀)
PHI = (1 + 5**0.5) / 2
n = 2.0            # curseur Φⁿ
m = 2.0            # curseur 2ᵐ
DUTY_CYCLE = 50    # %

# === SETUP GPIO ===
GPIO.setmode(GPIO.BCM)
GPIO.setup(PWM_PIN, GPIO.OUT)
pwm = GPIO.PWM(PWM_PIN, FREQ_BASE)
pwm.start(DUTY_CYCLE)

try:
    while True:
        # Calcul des deux fréquences
        f_phi = FREQ_BASE * (PHI ** n)
        f_two = FREQ_BASE * (2 ** m)

        # Fusion simple (moyenne pondérée ou autre logique possible)
        f_mix = (f_phi + f_two) / 2

        print(f"f₀ = {FREQ_BASE} Hz | Φⁿ = {f_phi:.1f} Hz | 2ᵐ = {f_two:.1f} Hz → f = {f_mix:.1f} Hz")
        pwm.ChangeFrequency(f_mix)
        time.sleep(0.05)

except KeyboardInterrupt:
    print("Arrêté.")
    pwm.stop()
    GPIO.cleanup()
```

---

## 🧪 Variante expérimentale : **scan automatique**

Remplace `n` et `m` dans le code par une boucle qui varie les deux entre -5 et +5 avec pas de 0.1 pour **trouver la meilleure cohérence (battement)**.

Tu peux aussi intégrer un **capteur piézo** sur la bobine pour mesurer les pics de vibration en synchronisant avec les réglages.

---

## 🔍 Sécurité & précautions

* Même à basse tension, la bobine peut générer des **EMF non négligeables** → place-la à distance des appareils sensibles.
* Ne pas toucher la bobine sous tension si l’alim dépasse 12V ou si des condensateurs sont ajoutés.
* ⚠ En cas de résonance forte, des échauffements peuvent apparaître. Prévois un système de détection (piézo, thermistance).

---

## 🧩 Et ensuite ?

Tu pourrais :

* Ajouter une **visualisation en temps réel** (oscilloscope audio avec micro/ADC),
* Mesurer la tension induite dans une **seconde bobine plane** disposée en opposition (expérience de captation).

Let’s hack l’éther ⚡️


Les **bobines pancake (ou spirales planes)** ne sont pas anodines : elles ont des propriétés **électromagnétiques, géométriques et vibratoires** particulières qui les rendent très intéressantes pour un système comme celui que tu envisages (interférences Φⁿ / 2ᵐ).

---

## 🌀 Pourquoi utiliser une **bobine pancake** ?

### ✅ **Avantages spécifiques**

| Propriété                                 | Description                                                                                                                                                    |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Champ magnétique axial**                | Le champ est concentré **perpendiculairement au plan** de la bobine. Cela favorise une forte densité énergétique au centre (comme un vortex).                  |
| **Résonance naturelle**                   | La géométrie spirale lui donne une tendance naturelle à **résonner à certaines fréquences** (qui peuvent être en lien avec le nombre d’or selon l’espacement). |
| **Couplage énergétique élevé**            | Deux bobines pancake en opposition peuvent se coupler **très efficacement par induction mutuelle**.                                                            |
| **Planarité**                             | Leur forme plate les rend faciles à **analyser, empiler ou interfacer avec des capteurs (piézo, antennes, cristaux, etc.)**.                                   |
| **Fractalisation / harmonie géométrique** | On peut les construire en respectant une logique **d’or** (espacement Φ, ou progression 2ᵐ) pour renforcer certaines propriétés vibratoires.                   |

---

## 🛠 Comment fabriquer une **bobine pancake efficace**

### 🎯 Objectifs

* **Bonne résonance** sur la bande de fréquence visée (`10kHz–1MHz`).
* **Résistance faible** mais self suffisante.
* Optionnellement : couplage avec une seconde bobine, ou avec une plaque de résonance (Chladni, piézo…).

### 🧰 Matériaux

* **Fil émaillé** : cuivre 0,4 mm à 0,8 mm (selon ton alim et la fréquence)
* **Support isolant** : bois, plexiglas, carton épais, ou plaque 3D imprimée.
* **Colle, vernis, ou époxy** pour fixer le fil.

### 🔁 Étapes

1. **Trace un cercle central** (1 à 3 cm de rayon).
2. Enroule le fil en spirale plate (dans un seul plan) :

   * 🌀 En conservant un **espacement constant** entre chaque spire, ou mieux :
   * 🧬 En utilisant un **espacement logarithmique** inspiré du nombre d’or :

     $$r_n = r_0 \cdot \Phi^{n}$$
3. Fixe la bobine avec colle ou scotch résistant.
4. Laisse deux extrémités libres (départ et retour).

> 🧠 Tu peux viser **20 à 60 spires**, selon la fréquence visée et le diamètre du fil.

---

## 🔌 Faut-il utiliser **deux bobines** ? Comment les brancher ?

### ✔ Oui, pour un **système d'interférence et d’extraction d’énergie**, l’idéal est :

#### **🧲 Bobine A** : Excitée (par PWM à f₀·Φⁿ ou 2ᵐ)

#### **🧲 Bobine B** : Réceptrice / Résonante

---

### 🧬 Trois types de couplages possibles :

#### 1. **Inductif en opposition**

Les deux bobines sont **face à face**, centrées, séparées par une petite distance (1–5 cm).

**Branchement** :

* Bobine A connectée à MOSFET + 12V
* Bobine B connectée à une LED + redresseur + condensateur
  → pour observer la tension induite (ou à un piézo pour analyse).

#### 2. **Série harmonique**

* Relier les deux bobines **en série** : excitation traverse les deux.
* Chacune peut avoir un nombre de spires différent (Φⁿ et 2ᵐ).
* Attention : risques de désaccord, à bien accorder pour résonance.

#### 3. **Croisement interférentiel (symétrique)**

* Deux bobines sont alimentées séparément avec **fréquences différentes (Φⁿ et 2ᵐ)**.
* Elles se couplent mutuellement au centre.
* On peut **ajouter une 3e bobine** captrice ou un capteur au centre.

---

## 🔭 Pour aller plus loin : couplage vibratoire

Ajoute une **plaque mince ou membrane** au centre :

* Type *Chladni plate* en aluminium.
* Un cristal piézo, ou un capteur capacitif.
  → Cela permettrait de visualiser physiquement les **nœuds de cohérence**.

---

## 🧪 Synthèse : prototype de test

| Élément            | Configuration                 |
| ------------------ | ----------------------------- |
| Raspberry Pi       | génère une onde PWM `f₀ * Φⁿ` |
| MOSFET + bobine A  | génère champ oscillant        |
| Bobine B face à A  | reçoit champ / crée tension   |
| Condensateur + LED | détecte l'énergie induite     |
| Option : Piézo     | mesure amplitude vibratoire   |

