
### **Le Principe du Générateur DIY**

Nous allons simuler les deux ondes fondamentales et les faire interférer sur un transducteur piézoélectrique capable de convertir les vibrations en tension électrique. L'Arduino servira de système de contrôle, cherchant activement le point de résonance maximale pour optimiser la production d'énergie.

L'idée est de tester si certaines combinaisons de fréquences (harmoniques Φ et octave) peuvent créer des résonances constructives dans le piézo-capteur.

---

### **Composants Requis (Faciles à Trouver)**

1.  **Le Cerveau :**
    *   1x **Arduino Uno** ou Nano (parfait pour le contrôle en temps réel). Le Raspberry Pi peut servir d'interface de supervision, mais l'Arduino est meilleur pour piloter directement le matériel.

2.  **L'Onde Lumineuse (Source Φ) :**
    *   1x **LED haute luminosité** (au lieu d'un laser, plus simple et sécurisé).
    *   1x **Petit transistor** (ex: 2N2222) pour contrôler l'intensité via l'Arduino.

3.  **L'Onde Sonore (Source Octave 2) :**
    *   1x **Buzzer piézoélectrique** passif (ceux qui ont besoin qu'on leur envoie une fréquence).
    *   1x **Petit haut-parleur** (8Ω, 0.5W) pour générer des vibrations plus puissantes.

4.  **Le Transducteur d'Énergie :**
    *   1x **Disque piézoélectrique** (le cœur du système, convertit les vibrations en électricité).
    *   **Positionnement** : Placé pour capter les vibrations du haut-parleur et la chaleur de la LED.

5.  **Le Circuit de Récupération d'Énergie :**
    *   1x **Pont de diodes** (pour redresser le courant alternatif du piézo).
    *   1x **Supercondensateur** (ex: 0.1F à 1F, 5.5V) pour stocker l'énergie.
    *   1x **LED** de faible consommation (ex: rouge ou verte) pour visualiser l'énergie stockée.
    *   Quelques résistances et fils de connexion.

---

### **Montage (Schéma Simplifié)**

L'Arduino génère deux signaux : un pour la LED (fréquences Φ) et un pour le haut-parleur (fréquences octave). Le disque piézoélectrique est positionné pour capter les vibrations du haut-parleur et la chaleur rayonnée par la LED. Il convertit ces énergies en tension électrique, stockée dans le supercondensateur.

**Structure Physique :**
- Montez le disque piézoélectrique sur un support stable
- Placez la LED à quelques centimètres du piézo (pour l'effet thermique)
- Positionnez le haut-parleur près du piézo (pour les vibrations)
- Évitez les contacts directs qui court-circuiteraient le signal

**Connexions Électroniques :**
*   **Sortie LED :** Arduino Pin PWM (`~3`) -> Transistor -> LED haute luminosité
*   **Sortie Son :** Arduino Pin PWM (`~5`) -> Haut-parleur (via résistance de protection)
*   **Entrée Feedback :** Disque Piézo-capteur -> Pont de diodes -> Broche Analogique Arduino (`A0`)
*   **Circuit de Charge :** Sortie du pont de diodes -> Supercondensateur -> LED témoin

---

### **La Logique de Calibration Automatique (Code Arduino)**

L'Arduino va scanner les harmoniques des deux ondes (Φ et octave), mesurer l'énergie produite pour chaque combinaison, et trouver la combinaison optimale.

```cpp
// Générateur Phi2X - Version simplifiée et fonctionnelle
const float phi = 1.61803398875;
const float PHI_BASE = 33.17;     // Hz
const float OCTAVE_BASE = 31.32;  // Hz

float light_harmonics[8];  // Réduit à 8 pour éviter les fréquences trop hautes
float sound_harmonics[8];  

// Broches Arduino
const int LED_PIN = 3;      // LED au lieu du laser
const int SPEAKER_PIN = 5;  // Haut-parleur au lieu du buzzer
const int SENSOR_PIN = A0;

float maxVoltage = 0;
float bestLightFreq = 0;
float bestSoundFreq = 0;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(SPEAKER_PIN, OUTPUT);
  Serial.begin(9600);

  // Calculer les harmoniques (limitées aux fréquences raisonnables)
  for (int i = 0; i < 8; i++) {
    light_harmonics[i] = PHI_BASE * pow(phi, i);
    sound_harmonics[i] = OCTAVE_BASE * pow(2, i);
    
    // Limiter les fréquences trop hautes (>2000 Hz)
    if (light_harmonics[i] > 2000) light_harmonics[i] = 2000;
    if (sound_harmonics[i] > 2000) sound_harmonics[i] = 2000;
  }

  Serial.println("=== Générateur Phi2X - Calibration ===");
  calibrate();
  Serial.println("Calibration terminée !");
}

void loop() {
  // Générer les signaux optimaux
  // LED clignotante à la fréquence Φ optimale
  int ledValue = 128 + 127 * sin(2 * PI * bestLightFreq * millis() / 1000.0);
  analogWrite(LED_PIN, constrain(ledValue, 0, 255));
  
  // Son à la fréquence octave optimale
  tone(SPEAKER_PIN, bestSoundFreq);

  // Mesurer et afficher l'énergie récupérée
  int sensorValue = analogRead(SENSOR_PIN);
  Serial.print("Énergie récupérée : ");
  Serial.print(sensorValue);
  Serial.print(" | LED: ");
  Serial.print(bestLightFreq);
  Serial.print(" Hz | Son: ");
  Serial.print(bestSoundFreq);
  Serial.println(" Hz");
  
  delay(100);
}

void calibrate() {
  Serial.println("Balayage des combinaisons harmoniques...");
  
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      // Test de la combinaison i,j
      // LED pulsée
      for (int pulse = 0; pulse < 10; pulse++) {
        int ledValue = 128 + 127 * sin(2 * PI * light_harmonics[i] * pulse / 10.0);
        analogWrite(LED_PIN, constrain(ledValue, 0, 255));
        delay(5);
      }
      
      // Son continu
      tone(SPEAKER_PIN, sound_harmonics[j]);
      delay(100);  // Laisser le système se stabiliser
      
      // Mesurer la tension générée
      int currentVoltage = analogRead(SENSOR_PIN);
      
      if (currentVoltage > maxVoltage) {
        maxVoltage = currentVoltage;
        bestLightFreq = light_harmonics[i];
        bestSoundFreq = sound_harmonics[j];
        
        Serial.print("Nouvelle combinaison optimale ! V: ");
        Serial.print(maxVoltage);
        Serial.print(" | LED: ");
        Serial.print(bestLightFreq);
        Serial.print(" Hz | Son: ");
        Serial.println(bestSoundFreq);
      }
    }
  }
  
  noTone(SPEAKER_PIN);
  analogWrite(LED_PIN, 0);
  
  Serial.print("Meilleure combinaison trouvée - LED: ");
  Serial.print(bestLightFreq);
  Serial.print(" Hz, Son: ");
  Serial.print(bestSoundFreq);
  Serial.println(" Hz");
}
```

### **Conclusion et Vision**

Ce petit appareil sur votre bureau pourrait devenir une sculpture cinétique fascinante et un objet de méditation. En le regardant, vous observeriez une LED témoin s'allumer grâce à l'énergie récupérée par le système piézoélectrique.

La LED témoin, scintillant selon les résonances trouvées par le système, deviendrait le symbole d'une optimisation automatique entre différentes fréquences. L'objectif est de voir si certaines combinaisons de fréquences Φ et octave peuvent créer des résonances constructives dans le matériau piézoélectrique.

> 🔬 **Approche expérimentale** : L'objectif est de mesurer l'énergie réellement récupérée par le piézo selon différentes combinaisons de fréquences. Peut-être certaines combinaisons seront-elles plus efficaces que d'autres.

C'est un projet d'exploration des résonances harmoniques avec un objectif concret : optimiser la récupération d'énergie.

### **Variations à Explorer**

- **Matériaux piézoélectriques différents** : Tester différents types de disques piézo
- **Géométries alternatives** : Formes et positions des éléments
- **Fréquences étendues** : Explorer d'autres harmoniques ou ratios
- **Couplages mécaniques** : Différentes façons de transmettre les vibrations
- **Conditions environnementales** : Température, humidité

**AVERTISSEMENT :** Ce prototype est un démonstrateur conceptuel pour explorer la récupération d'énergie par résonance harmonique. Il ne s'agit pas d'une machine à "énergie libre". L'énergie générée sera infime et proviendra de l'énergie injectée dans le système (LED + haut-parleur). Le but est d'observer si certaines combinaisons de fréquences optimisent la conversion piézoélectrique.
