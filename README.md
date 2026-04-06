# 24hisere-obs-timer

Écrit en temps réel l'heure actuelle et le chrono de course dans des fichiers texte.

## Installation

```sh
pnpm install
```

## Configuration

Copier `.env.example` en `.env` et renseigner les variables :

| Variable             | Description                                  |
| -------------------- | -------------------------------------------- |
| `RACE_START_DATE`    | Date/heure de départ de la course (ISO 8601) |
| `RACE_END_DATE`      | Date/heure de fin de la course (ISO 8601)    |
| `TIME_OUTPUT_FILE`   | Fichier de sortie pour l'heure actuelle      |
| `CHRONO_OUTPUT_FILE` | Fichier de sortie pour le chrono de course   |

## Utilisation

```sh
pnpm start
```

Le chrono affiche `00:00:00` avant le départ, la durée écoulée pendant la course, et se fige à la durée maximale après la fin.

## Script OBS (`obs-timer.lua`)

L'utilisation de ce script est une alternative à la fonction "Lire depuis un fichier" des sources Texte d'OBS, qui lit le contenu des fichiers à un intervalle trop faible (environ 1 fois par seconde), ce qui cause des problèmes visuels (sauts de secondes).

Dans OBS : **Outils → Scripts → +** puis sélectionner `obs-timer.lua`.

Paramètres :

| Paramètre            | Description                            |
| -------------------- | -------------------------------------- |
| Time File Path       | Chemin absolu vers `output/time.txt`   |
| Chrono File Path     | Chemin absolu vers `output/chrono.txt` |
| Update Interval (ms) | Intervalle de rafraîchissement         |
| Time Text Source     | Source texte OBS pour l'heure          |
| Chrono Text Source   | Source texte OBS pour le chrono        |
