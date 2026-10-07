# Valheim Continue

Ein Klick auf **continue** im Hauptmenü wählt deine Figur aus und verbindet dich mit deinem fest eingestellten Server. Über **...** daneben stellst du Figur, Server-IP/Hostname, Port und optional das Passwort ein.

Die Mod läuft ausschließlich auf dem Client. Der Server braucht sie nicht. Sie verwendet Valheims normale Charakterauswahl, Berechtigungsprüfung und Anmeldung. Es gibt keine Tastaturüberwachung und keine Umgehung der Serverauthentifizierung.

## Du möchtest die Mod installieren?

**[Hier geht es zur Windows-Anleitung – Schritt für Schritt](docs/INSTALL-WINDOWS.md)**

Du brauchst kein GitHub-Konto und keine Programmierkenntnisse. GitHub ist hier einfach die Webseite, auf der die Mod und diese Anleitung liegen. Die Dateienliste oben auf dieser Seite kannst du überspringen.

Die Anleitung zeigt dir:

1. Welche **zwei ZIP-Dateien** du herunterladen musst. ZIP-Dateien sind verpackte Ordner, die Windows für dich auspackt.
2. Wie du mit Steam deinen Valheim-Ordner findest.
3. Welche Ordner du dorthin kopierst.
4. Wo du im Spiel deine Figur und deine eigenen Serverdaten einträgst.

**[Continue-ZIP direkt herunterladen](https://github.com/cuinhellcat/ValheimContinue/releases/download/v1.0.0/ValheimContinue-1.0.0.zip)**

Dieser Link lädt die fertige Mod herunter. Zusätzlich brauchst du das kleine Hilfsprogramm BepInEx; der passende Download steht in der Windows-Anleitung. Die Mod wurde unter Linux erfolgreich getestet. Ein Test auf einem Windows-Rechner steht noch aus.

Die Mod verändert weder Fenstergröße noch Vollbildoption oder Steuerung. Starte Valheim nach der Installation wie gewohnt über Steam.

## Einstellungen

| Feld | Bedeutung |
| --- | --- |
| Figur | Vorhandene Figur, einschließlich Steam-Cloud-Figuren |
| Server | IP-Adresse oder Hostname eines dedizierten Servers, ohne Port |
| Port | Spielport, normalerweise `2456` |
| Passwort | Optional; leer lässt die normale Passwortabfrage erscheinen |

Die öffentliche Version enthält **keine** voreingestellte Figur, Serveradresse oder Passwort. Die letzte gespeicherte Konfiguration bleibt beim nächsten Start erhalten; andere Verbindungen überschreiben sie nicht automatisch.

Das explizit eingetragene Passwort liegt lokal im Klartext in `BepInEx/config/hellcat.valheim.continue.cfg`. Diese Datei nicht veröffentlichen oder weitergeben. Ein falsches Passwort führt zur normalen Fehlermeldung von Valheim. IPv4, IPv6 und Hostnamen werden an Valheims normalen Dedicated-Server-Join übergeben. Die direkte Eingabe eines Crossplay-Beitrittscodes ist in dieser Version nicht enthalten.

## Deinstallation / Wiederherstellung

Valheim beenden und ausschließlich `BepInEx/plugins/ValheimContinue/` entfernen. Bei einer flachen DLL-Installation stattdessen `BepInEx/plugins/ValheimContinue.dll` entfernen. Optional auch die oben genannte Mod-Konfigurationsdatei löschen. Den gemeinsam verwendeten BepInEx-Lader und andere Mods behalten. Spielstände werden von der Mod nicht bearbeitet; beim tatsächlichen Spielen speichert Valheim wie gewohnt.

## Linux

BepInExPack_Valheim und die DLL installieren. Laut [Pack-Anleitung](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) das Startskript ausführbar machen und in Steam setzen:

```text
./start_game_bepinex.sh %command%
```

Alternativ den Loader außerhalb des Spielordners unter `runtime/` neben dem mitgelieferten `launch-modded.sh` ablegen und die DLL nach `runtime/BepInEx/plugins/` kopieren. Das Skript als absoluten Pfad in Steams Startoptionen verwenden:

```text
"/pfad/zum/Projekt/launch-modded.sh" %command%
```

`VALHEIM_DIR` kann einen anderen Spielordner angeben. Das Skript enthält keine Testoptionen für Auflösung oder Vollbild. Für Controller-Unterstützung über Steam starten.

## Geprüfter Stand

- Kompiliert gegen die lokal installierten Valheim-1.0.17-Assemblies, Unity 6000.0.75f1 und BepInExPack_Valheim 5.4.2351.
- Linux: Mod geladen, Menü und Einstellungen angezeigt, Cloud-Figur ausgewählt und Anmeldung am passwortgeschützten dedizierten Steam-Server bis zum Spawn bestätigt; vom Nutzer erfolgreich getestet.
- Windows: Anleitung und plattformunabhängige DLL vorbereitet. Ein tatsächlicher Windows-Spieltest steht noch aus.
- Nach dem erfolgreichen Spieltest wurde die Passwortbereinigung auf eigene Continue-Anmeldungen begrenzt und auch bei Ausnahmen abgesichert; diese kleine Nachkorrektur ist kompiliert, aber noch nicht erneut im Spiel getestet.
- Andere Valheim-Versionen, Controller-Navigation durch die neuen Knöpfe und weitere Mods wurden nicht umfassend getestet. Nach Spielupdates können interne API-Namen Änderungen erfordern.

## Selbst kompilieren

Benötigt: .NET SDK 8, eigene Valheim-Installation und BepInExPack_Valheim. Den Pack unter `tools/bepinex/` entpacken; die Referenzen liegen dann unter `tools/bepinex/BepInExPack_Valheim/BepInEx/core/`.

```text
dotnet build src/Continue.csproj -c Release -p:GameDir="C:/Program Files (x86)/Steam/steamapps/common/Valheim"
```

Bei abweichendem Laderordner zusätzlich `-p:LoaderDir="/pfad/zu/BepInEx/core"` angeben. Unter Linux genügt bei einer Standardinstallation `scripts/build.sh`. Die DLL liegt unter `src/bin/Release/netstandard2.1/`. Zum Kompilieren werden die verwalteten Systembibliotheken des Spiels verwendet; Spielbibliotheken werden nicht in Releases mitgeliefert.

[Technische Untersuchung](docs/INVESTIGATION.md) · [Roadmap](docs/PLAN.md)

## Lizenz

MIT. Eigenständige Mod, nicht mit Iron Gate oder Coffee Stain verbunden. Valheim und die externen Mod-Werkzeuge behalten ihre jeweiligen Rechte und Lizenzen.
