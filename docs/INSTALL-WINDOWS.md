# Windows: die einfache Installation

Du brauchst kein GitHub-Konto. Der Installer sucht Valheim und erledigt das Herunterladen und Kopieren für dich.

**[Hier klicken: Windows-Installationspaket herunterladen](https://github.com/cuinhellcat/ValheimContinue/releases/download/v1.0.0/ValheimContinue-Windows-Einfach-1.0.0.zip)**

## 1. Herunterladen und auspacken

Klicke auf den Link oben. Die Datei landet normalerweise im Ordner **Downloads**.

Klicke dort mit der rechten Maustaste auf **ValheimContinue-Windows-Einfach-1.0.0.zip**, dann auf **Alle extrahieren...** und **Extrahieren**. Öffne den ausgepackten Ordner. Du musst das Paket vollständig auspacken; direkt im ZIP funktioniert die Installation nicht.

## 2. Auf „Installieren“ doppelklicken

Beende Valheim, falls es gerade läuft. Steam darf offen bleiben.

Doppelklicke im ausgepackten Ordner auf **Installieren.cmd**. Falls Windows die Dateiendungen ausblendet, heisst die Datei nur **Installieren**.

Ein Fenster öffnet sich. Das Programm sucht deinen Valheim-Ordner und installiert die Mod. Wenn das Hilfsprogramm BepInEx noch fehlt, wird es automatisch heruntergeladen; dafür brauchst du Internet. Warte, bis **Fertig!** erscheint. Danach kannst du das Fenster mit der Eingabetaste schliessen.

Falls Valheim nicht automatisch gefunden wird, öffnet sich ein Auswahlfenster. Wähle darin **valheim.exe**. Du findest den Ordner über **Steam → Bibliothek → Rechtsklick auf Valheim → Eigenschaften → Installierte Dateien → Durchsuchen**.

## 3. Im Spiel einstellen

Starte Valheim wie gewohnt über Steam. Klicke im Hauptmenü auf **...** neben **continue**.

Wähle deine Figur, trage die Serveradresse und gegebenenfalls das Passwort ein und klicke auf **Speichern**. Der voreingestellte Port **2456** passt für die meisten Server; die Daten bekommst du von deinem Serverbetreiber.

Ab jetzt genügt ein Klick auf **continue**. Dein Passwort wird lokal in der Mod-Einstellungsdatei gespeichert. Gib diese Datei nicht weiter.

## Wenn etwas schiefgeht

Das Installationsfenster nennt den Grund, zum Beispiel ein noch laufendes Spiel, fehlende Schreibrechte oder eine bereits abweichend installierte Mod. Gib diese Meldung weiter, wenn du Hilfe brauchst. Bei fehlenden Schreibrechten kannst du **Installieren.cmd** mit der rechten Maustaste anklicken und **Als Administrator ausführen** wählen.

Wenn du deine Mods bereits mit einem Mod-Manager startest oder einen anderen Mod-Lader verwendest, nutze die [manuelle Anleitung](INSTALL-WINDOWS-MANUAL.md). Der einfache Installer ist für den normalen Steam-Spielordner gedacht und ersetzt keine fremden Mod-Lader.

## Wieder rückgängig machen

Beende Valheim und doppelklicke im ausgepackten Paket auf **Rueckgaengig.cmd**. Es entfernt die zuletzt mit diesem Paket installierte Continue-Mod oder stellt die vorherige Version wieder her. Andere Mods, BepInEx und deine Verbindungseinstellungen bleiben erhalten. Spaeter veränderte Dateien werden nicht automatisch ersetzt.

## Was bereits geprüft wurde

Die Mod selbst hat unter Linux erfolgreich eine Cloud-Figur ausgewählt und einen passwortgeschützten Server betreten. Der neue Installer wurde mit automatisierten Dateitests unter PowerShell auf Linux geprüft: Installation, weitere Steam-Bibliotheken, Sicherung, Wiederherstellung, wiederholtes Installieren und Fehlerfaelle. **Ein echter Windows-Test des Installers und der Mod steht noch aus.**

Der Installer verwendet das bereits in Windows enthaltene PowerShell; du musst keine Befehle eintippen oder Programme selbst kompilieren. Er ist nicht digital signiert. Falls Windows ihn blockiert, kannst du die manuelle Anleitung verwenden.

[Zurück zur Startseite](../README.md)
