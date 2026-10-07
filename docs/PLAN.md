# Roadmap und Stand

1. [x] Lokale Installation, Engine, Version und Mod-Schnittstellen untersuchen.
2. [x] BepInEx-/ILSpy-Dokumentation lesen und relevante Join-APIs prüfen.
3. [x] Durchstich: Hauptmenüknopf, konkrete Figur und normaler Server-Joinpfad.
4. [x] Einstellungen für Figur, Host, Port und manuell eingegebenes Passwort.
5. [x] Build ohne Warnungen; isolierte Linux-Installation und Charakter-Sicherung.
6. [x] Echter Linux-Spieltest einschließlich Anmeldung und Spawn; Nutzer bestätigt Erfolg.
7. [x] Dokumentation, Windows-Anleitung und Release-Paket ohne persönliche Daten erstellen.
8. [x] GitHub-Veröffentlichung mit Nutzerfreigabe: [Repository](https://github.com/cuinhellcat/ValheimContinue) und [Release 1.0.0](https://github.com/cuinhellcat/ValheimContinue/releases/tag/v1.0.0), 7. Oktober 2026.

## Nach dem ersten Release

- [x] Einfaches Windows-Paket mit automatischer Steam-Suche, BepInEx-Download, Sicherung und Wiederherstellung; Dateitests unter PowerShell bestanden.
- [ ] Echter Windows-Test des neuen Installers (Registry-Suche, Doppelklick und Dateiauswahl).

- [ ] Windows-Laufzeittest und Test der Passwortbereinigung nach der letzten kleinen Nachkorrektur.
- [ ] Bessere Controller-Navigation und Prüfung verschiedener Bildschirmgrößen.
- [ ] Optional zuletzt erfolgreich verwendetes Ziel merken (Passwort weiterhin nur explizit eingegeben).
- [ ] Optional Crossplay-Beitrittscodes als zusätzliche Eingabeart.

Lokale Werkzeuge, Build-Ausgaben, Logs, Originaldatei-Prüfsummen, persönliche Konfigurationen und passende Figur-Sicherung bleiben im Projekt, aber außerhalb von Git. Originale Spielbibliotheken wurden nicht verändert. Wiederherstellung: Mod entfernen; bei Bedarf eine vorhandene persönliche Sicherung bei beendetem Spiel zurückspielen.
