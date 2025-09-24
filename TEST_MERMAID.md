# Test Mermaid

Ce fichier teste l'intégration de Mermaid.js dans le système FRD.

## Diagramme de flux simple

```mermaid
graph TD
    A[Début] --> B{Décision}
    B -->|Oui| C[Action 1]
    B -->|Non| D[Action 2]
    C --> E[Fin]
    D --> E
```

## Diagramme de séquence

```mermaid
sequenceDiagram
    participant A as Alice
    participant B as Bob
    A->>B: Bonjour Bob!
    B->>A: Bonjour Alice!
    A->>B: Comment ça va?
    B->>A: Très bien, merci!
```

## Diagramme de Gantt

```mermaid
gantt
    title Projet Phi2X
    dateFormat  YYYY-MM-DD
    section Recherche
    Théorie        :done,    des1, 2024-01-01,2024-01-15
    Validation     :active,  des2, 2024-01-16, 30d
    section Développement
    Prototype      :         des3, after des2, 20d
    Tests          :         des4, after des3, 10d
```

## Diagramme de classes

```mermaid
classDiagram
    class Phi2X {
        +Float phi
        +Float octave
        +calculateInterference()
        +generateConstants()
    }
    class UniversalConstant {
        +String name
        +Float value
        +Float precision
        +validate()
    }
    Phi2X --> UniversalConstant : generates
```

## Test avec erreur (syntaxe invalide)

```mermaid
graph TD
    A[Début
    B --> C
```

Fin du test Mermaid.
