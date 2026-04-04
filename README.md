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
