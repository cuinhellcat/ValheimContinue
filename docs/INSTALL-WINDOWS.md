# Installation unter Windows

## Voraussetzungen

- Valheim für Windows (Steam), geprüfte API-Version: 1.0.17.
- [BepInExPack_Valheim](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/), für diesen Stand 5.4.2351.
- [ValheimContinue-1.0.0.zip](https://github.com/cuinhellcat/ValheimContinue/releases/latest).

Ein eigener Server-Mod ist nicht erforderlich. Ein Windows-Laufzeittest wurde noch nicht durchgeführt.

## 1. Spielordner finden und Ausgangszustand sichern

Valheim schließen. In Steam: **Bibliothek → Valheim → Eigenschaften → Installierte Dateien → Durchsuchen**. In diesem Ordner liegt `valheim.exe`.

Wenn bereits Mods installiert sind, vorhandene `BepInEx/config` und eine eventuell vorhandene ältere `ValheimContinue.dll` vor dem Austausch kopieren. Keine Spielstände verschieben und keine bestehenden Mods löschen.

## 2. Mod-Lader installieren

Wenn ein passender BepInEx-Lader bereits funktioniert, diesen Schritt überspringen.

Beim [Valheim-Pack](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) die manuelle ZIP-Datei herunterladen und zuerst in einen separaten Ordner entpacken. Aus dem Unterordner `BepInExPack_Valheim` dessen **Inhalt** in den Spielordner kopieren, einschließlich `BepInEx`, `winhttp.dll` und `doorstop_config.ini`. Es darf kein zusätzlicher verschachtelter `Valheim/BepInExPack_Valheim/`-Ordner entstehen.

Valheim über Steam einmal starten und danach beenden. `BepInEx/LogOutput.log` zeigt, ob der Loader gestartet ist. Unter Windows ist laut Pack-Anleitung normalerweise keine Änderung der Steam-Startoptionen nötig.

## 3. Continue installieren

Das Release-ZIP entpacken und den darin enthaltenen `BepInEx`-Ordner in den Spielordner kopieren. Danach muss diese Datei vorhanden sein:

```text
Valheim/
  valheim.exe
  BepInEx/
    plugins/
      ValheimContinue/
        ValheimContinue.dll
```

Bei Verwendung eines Mod-Managers die DLL stattdessen im `BepInEx/plugins/`-Ordner des verwendeten Profils ablegen und über dieses Profil starten. Die Mod nur einmal installieren.

## 4. Verbindung einstellen

Valheim über Steam starten. Im Hauptmenü **...** neben **continue** öffnen:

1. Vorhandene Figur aus der Liste auswählen. Lokale und Cloud-Figuren werden vom Spiel geladen.
2. Server-IP oder Hostname eingeben, zum Beispiel `192.0.2.10`.
3. Spielport eintragen, normalerweise `2456`.
4. Passwort selbst eingeben, falls gewünscht. Leer bedeutet normale Passwortabfrage.
5. **Speichern** drücken, dann **continue**.

Das Passwort wird lokal im Klartext gespeichert und nur bei einer Continue-Anmeldung eingesetzt. Die Mod-Konfiguration niemals an einen Fehlerbericht anhängen, ohne das Passwort zu entfernen.

## Kurzer Test

**continue** sollte ohne zusätzliche Charakterauswahl zum eingestellten Server verbinden. Bei hinterlegtem korrektem Passwort sollte die Welt laden. Zum Abschluss über das Spielmenü zurückkehren bzw. regulär beenden. Für Dateiaustausch oder Deinstallation muss das Spiel beendet bleiben.

## Wenn etwas nicht klappt

- Kein Knopf: In `BepInEx/LogOutput.log` nach `Loading [Valheim Continue 1.0.0]` und `Main menu continue and settings buttons created` suchen. Richtigen Profilordner und Loader prüfen.
- Figur fehlt: Cloud-Verfügbarkeit in Steam prüfen; Figur zunächst in Valheims normaler Charakterauswahl kontrollieren.
- Verbindung schlägt fehl: Im normalen Valheim-Menü dieselbe Adresse und denselben Spielport testen. Die Mod verwendet den gleichen Joinpfad.
- Falsches Passwort: **...** öffnen und korrigieren oder leeren. Serverauthentifizierung wird nicht umgangen.
- Nach einem Spielupdate defekt: Mod entfernen und im Repository einen Bericht mit Spiel- und BepInEx-Version sowie bereinigtem Fehlerauszug erstellen.

## Entfernen

Valheim beenden. `BepInEx/plugins/ValheimContinue/` löschen. Optional `BepInEx/config/hellcat.valheim.continue.cfg` löschen, um alle persönlichen Verbindungsdaten zu entfernen. Bei Rückkehr zu einer älteren Version die vorher gesicherte DLL und gegebenenfalls Konfiguration zurückkopieren. BepInEx nur entfernen, wenn es auch für andere Mods nicht mehr gebraucht wird.
