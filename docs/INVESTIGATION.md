# Untersuchung und technische Grenzen

## Belegte Befunde

Die lokale Linux-Steam-Installation meldete Valheim l-1.0.17, Netzwerkversion 40, Steam-Build 25730771 und Unity 6000.0.75f1. `valheim_Data/Managed/assembly_valheim.dll` und `MonoBleedingEdge` belegen den Unity-Mono-Zugang. Für diese Aufgabe werden weder IL2CPP-Analyse noch native Disassembler benötigt.

Valheim bietet laut [offizieller FAQ](https://www.valheimgame.com/faq/) keine offizielle Mod-Unterstützung. Für Laufzeitpatches empfiehlt die [Community-Entwicklungsanleitung](https://github.com/Valheim-Modding/Wiki/wiki/Setting-Up-Mod-Development-Environment) den Valheim-BepInEx-Pack mit HarmonyX. Zusätzliche Content-/Asset-Bibliotheken sind für diese reine Menüänderung nicht erforderlich.

Verwendete Werkzeuge: .NET SDK 8.0.425, ILSpyCmd 9.1.0.7988 und BepInExPack_Valheim 5.4.2351. [ILSpy](https://github.com/icsharpcode/ILSpy) wurde nur für die relevanten Klassen eingesetzt. Die lokalen dekompilierten Ansichten sind Rekonstruktionen aus der ausgelieferten Assembly, kein ursprünglicher Quellcode. Sie werden nicht veröffentlicht.

## Aus dekompilierten Methoden rekonstruierter Ablauf

1. `FejdStartup.Start` richtet das Hauptmenü ein und lädt die Profile. Ein Harmony-Postfix ergänzt zwei Knöpfe durch Kopien einer vorhandenen Unity-UI-Schaltfläche. Die kopierten Klickereignisse werden vollständig ersetzt.
2. `ProceedJoinRequest(ServerJoinData)` prüft Multiplayer-Berechtigungen und stellt den Server für die Charakterauswahl in `m_queuedJoinServer` bereit.
3. Erst nach bestätigter Queue wählt `SetSelectedProfile` die exakt konfigurierte Datei. Die Mod prüft vorher deren Vorhandensein, weil die Spielmethode sonst auf Profil 0 zurückfallen könnte.
4. `OnCharacterStart` übernimmt den vorhandenen Dateiursprung (Cloud/lokal) und ruft Valheims `JoinServer` auf.
5. Dedicated-Joins verwenden `ServerJoinDataDedicated(host, port)`. Valheim löst Adresse und Backend selbst auf.
6. Beim `ZNet.RPC_ClientHandshake` setzt die Mod ausschließlich für ihren ausstehenden Continue-Versuch das explizit konfigurierte Passwort in `FejdStartup.ServerPassword`. Valheim ruft daraufhin seinen normalen `OnPasswordEntered`-/Hashing-/Authentifizierungspfad auf. Leere Einstellung ergibt `null` und erhält den normalen Dialog.
7. Ein Harmony-Finalizer entfernt das von der Mod eingesetzte Passwort auch bei einer Ausnahme. Das Zeitlimit für einen ausstehenden Versuch beträgt 90 Sekunden. Andere Anmeldewege werden nicht überwacht.

Die Einstellungen werden als BepInEx-Konfiguration gespeichert. Ein IMGUI-Fenster verdeckt während der Bearbeitung die klickbare Menüliste, damit Menükurzbefehle beim Tippen nicht ausgelöst werden. Es erfasst ausschließlich seine eigenen Eingabefelder.

## Ähnliche bestehende Mods

[RememberServerPassword](https://github.com/iMagic16/RememberServerPassword) bestätigt einen ähnlichen Zugang über Hauptmenü, ServerJoinData und den Passwort-Handshake; diese Mod merkt sich dagegen eingegebene Passwörter nach erfolgreichen Joins. Continue Last Game und EasyLogin wurden bei der Suche ebenfalls gefunden. Die hier veröffentlichte Implementierung speichert ein ausdrücklich eingestelltes Ziel und verwendet ausschließlich ein selbst eingetragenes Passwort. Es wurde kein fremder Mod-Quellcode übernommen.

## Nachweise und verbleibende Grenzen

Der erste Build wurde im echten Linux-Spiel geladen. Das Einstellungsfenster zeigte Cloud- und Legacy-Figuren. Der Continue-Aufruf wählte die gewünschte Cloud-Figur und verband über den Steam-Backendpfad zu einem passwortgeschützten dedizierten Server. Netzwerkabgleich, Weltinformationen und erfolgreicher Spawn sind im lokalen Protokoll belegt. Der Nutzer bestätigte den Erfolg.

Anschließend wurde die Bereinigung so eingeschränkt, dass normale Anmeldungen keine fremden bzw. über Startparameter gesetzten Passwörter verlieren; außerdem wird sie bei Ausnahmen ausgeführt. Der endgültige Stand kompiliert ohne Warnungen oder Fehler. Diese Nachkorrektur wurde nicht erneut bis zum Spawn geprüft. Windows-Laufzeit, IPv6, verschiedene Skalierungen, Crossplay-Backends und Controller-Navigation sind noch nicht im Spiel bestätigt. Die Windows-DLL verwendet keine Linux-spezifischen APIs; daraus folgt eine erwartete, noch nicht gemessene Windows-Kompatibilität.

Der Teststart verwendete ausdrücklich Fenstermodus und 1280×720 sowie einen direkten Prozessstart. Die gesicherten Unity-Voreinstellungen blieben identisch. Eine vermisste Steam-Input-Konfiguration beim direkten Start ist eine plausible Erklärung für abweichende Steuerung, keine bewiesene Diagnose. Der vorgesehene Installationsweg startet deshalb über Steam ohne diese Testparameter.

Downloads, Spielbibliotheken, dekompilierte Ansichten, Logs, Screenshots, persönliche Konfigurationen und Charakter-Sicherungen bleiben ausschließlich lokal und sind von Git ausgeschlossen.
