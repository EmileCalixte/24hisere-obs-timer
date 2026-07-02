# 24hisere-obs-timer

Script Lua pour OBS qui met à jour en temps réel deux sources texte : l'heure actuelle et le chrono de course.

## Script OBS (`24hisere-obs-timer.lua`)

Dans OBS : **Outils → Scripts → +** puis sélectionner `24hisere-obs-timer.lua`.

Paramètres :

| Paramètre            | Description                                               |
| -------------------- | --------------------------------------------------------- |
| Time Text Source     | Source texte OBS pour l'heure actuelle                    |
| Chrono Text Source   | Source texte OBS pour le chrono de course                 |
| Race Start           | Date/heure de départ de la course (`YYYY-MM-DD HH:MM:SS`) |
| Race End             | Date/heure de fin de la course (`YYYY-MM-DD HH:MM:SS`)    |
| Update Interval (ms) | Intervalle de rafraîchissement (défaut : 200 ms)          |

Le chrono affiche `00:00:00` avant le départ, la durée écoulée pendant la course, et se fige à la durée maximale après la fin.
