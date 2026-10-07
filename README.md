# Valheim Continue

Ein Klick auf **continue** im Hauptmenü wählt deine Figur aus und verbindet dich mit deinem fest eingestellten Server. Über **...** daneben stellst du Figur, Server-IP/Hostname, Port und optional das Passwort ein.

Die Mod läuft ausschließlich auf dem Client. Der Server braucht sie nicht. Sie verwendet Valheims normale Charakterauswahl, Berechtigungsprüfung und Anmeldung. Es gibt keine Tastaturüberwachung und keine Umgehung der Serverauthentifizierung.

**[Fertige Mod herunterladen](https://github.com/cuinhellcat/ValheimContinue/releases/latest)** · **[Windows-Anleitung](docs/INSTALL-WINDOWS.md)**

## Windows: kurze Installation

1. Valheim beenden. Falls vorhanden, die bestehende Mod-Konfiguration sichern.
2. [BepInExPack_Valheim](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) installieren. Empfohlener Stand für Valheim 1.0.17: **5.4.2351**. Bei manueller Installation den **Inhalt** von `BepInExPack_Valheim` neben `valheim.exe` kopieren. Einen bereits passenden Mod-Lader nicht überschreiben.
3. `ValheimContinue-1.0.0.zip` vom GitHub-Release herunterladen. Die darin enthaltene `BepInEx`-Struktur in den Valheim-Ordner kopieren; die DLL landet unter `BepInEx/plugins/ValheimContinue/ValheimContinue.dll`.
4. Valheim wie gewohnt über Steam starten. Im Hauptmenü **...** anklicken, Figur auswählen und Server/Port eintragen. Optional ein Passwort eingeben und **Speichern** drücken.
5. **continue** drücken.

Es werden keine Fenstergröße, Vollbildoption, Steuerung oder Steam-Input-Einstellungen durch die Mod verändert. Bei Nutzung eines Mod-Managers das Spiel über dessen normalen Steam-Startweg starten.

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
