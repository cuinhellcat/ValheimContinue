# Valheim Continue unter Windows installieren

Diese Anleitung beginnt beim Herunterladen. Du brauchst **kein GitHub-Konto**, kein zusätzliches Entpackprogramm und keine Programmierkenntnisse. Du brauchst einen Windows-PC, Steam und ein installiertes Valheim.

Mit der Mod bekommst du im Hauptmenü den Knopf **continue**. Einmal einstellen, danach mit einem Klick deine Figur auswählen und zum Server verbinden.

**Stand:** Die Mod wurde mit Valheim 1.0.17 unter Linux erfolgreich getestet. Der Test auf einem Windows-Rechner steht noch aus.

## 1. Die beiden Dateien herunterladen

Du brauchst zwei Downloads: die Continue-Mod und BepInEx. BepInEx ist ein Hilfsprogramm, mit dem Valheim Mods laden kann. Beides ist kostenlos.

Klicke nacheinander auf diese zwei Links:

- **[Download 1: Continue-Mod herunterladen](https://github.com/cuinhellcat/ValheimContinue/releases/download/v1.0.0/ValheimContinue-1.0.0.zip)**
- **[Download 2: BepInEx für Valheim herunterladen](https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2351/)**

Die Links starten den Download direkt. Wenn dein Browser fragt, wähle **Speichern**. Normalerweise liegen beide Dateien danach im Ordner **Downloads** auf deinem PC. Öffne ihn im Windows-Datei-Explorer; den erreichst du mit **Windows-Taste + E**. Links findest du normalerweise **Downloads**.

Die Continue-Datei heißt `ValheimContinue-1.0.0.zip`. Die zweite Datei hat `BepInExPack_Valheim` im Namen. Wenn Windows Dateiendungen ausblendet, siehst du das `.zip` eventuell nicht.

**Falls du stattdessen auf einer GitHub-Seite mit der Überschrift „Valheim Continue 1.0.0“ landest:** Scrolle nach unten bis **Assets**. Das bedeutet hier „Dateien zum Herunterladen“. Falls die Liste zugeklappt ist, klicke auf **Assets**. Klicke dann auf **ValheimContinue-1.0.0.zip**. Die Einträge **Source code** enthalten den Programmcode und werden für die Installation nicht benötigt. Noch einfacher ist der direkte Download-Link oben in dieser Anleitung.

## 2. Valheim schließen und den Spielordner öffnen

Beende Valheim vollständig, falls es gerade läuft. Steam darf geöffnet bleiben.

1. Öffne **Steam** und klicke auf **Bibliothek**.
2. Suche links in der Spieleliste **Valheim**.
3. Klicke mit der rechten Maustaste auf **Valheim** und dann auf **Eigenschaften**.
4. Klicke links auf **Installierte Dateien**.
5. Klicke auf **Durchsuchen**.

Jetzt öffnet sich ein Windows-Ordner mit den Dateien des Spiels. Hier sollte `valheim.exe` liegen. Wenn Windows die Endungen ausblendet, heißt die Datei nur **valheim** und hat den Typ **Anwendung**.

**Lass dieses Fenster offen.** Wenn im Folgenden „Spielordner“ steht, ist genau dieser Ordner gemeint.

**Falls du bereits andere Mods nutzt:** Kopiere vor Änderungen den vorhandenen `BepInEx`-Ordner als Sicherung an einen anderen Ort, zum Beispiel auf den Desktop. Wenn du deine Mods mit einem Mod-Manager startest, lies zuerst den Abschnitt „Ich benutze bereits einen Mod-Manager“ weiter unten. Die folgenden Schritte beschreiben die Installation direkt im Spielordner.

## 3. BepInEx auspacken und kopieren

Wenn BepInEx in diesem Spielordner bereits installiert ist und deine anderen Mods funktionieren, überspringe diesen Schritt.

1. Gehe im Datei-Explorer in **Downloads**.
2. Klicke mit der rechten Maustaste auf die heruntergeladene Datei mit **BepInExPack_Valheim** im Namen.
3. Wähle **Alle extrahieren...** und danach **Extrahieren**. Das bedeutet „die verpackten Dateien auspacken“. Windows öffnet normalerweise anschließend den ausgepackten Ordner.
4. Öffne darin den Ordner **BepInExPack_Valheim** per Doppelklick.
5. Darin findest du unter anderem den Ordner **BepInEx** und die Dateien **winhttp.dll** und **doorstop_config.ini**. Drücke **Strg + A**, um den gesamten Inhalt auszuwählen, dann **Strg + C**, um ihn zu kopieren.
6. Wechsle zum noch offenen **Spielordner** aus Schritt 2 und drücke **Strg + V**, um die Dateien dort einzufügen.

Zur Kontrolle: **BepInEx**, **winhttp.dll** und **doorstop_config.ini** müssen jetzt direkt im selben Ordner wie **valheim.exe** liegen. Wenn du im Spielordner nur einen neuen Ordner namens **BepInExPack_Valheim** siehst, hast du eine Ebene zu viel kopiert: Öffne diesen Ordner und kopiere seinen Inhalt in den Spielordner.

Dieser Ablauf entspricht der [Installationsanleitung des BepInEx-Pakets](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/). Unter Windows brauchst du dafür normalerweise keine zusätzlichen Startoptionen in Steam.

## 4. Die Continue-Mod auspacken und kopieren

1. Gehe wieder in **Downloads**.
2. Klicke mit der rechten Maustaste auf **ValheimContinue-1.0.0.zip**.
3. Wähle **Alle extrahieren...**, danach **Extrahieren**.
4. Im ausgepackten Ordner findest du einen Ordner namens **BepInEx** und einige Textdateien. Klicke einmal auf **BepInEx**, dann drücke **Strg + C**.
5. Wechsle zum **Spielordner** und drücke **Strg + V**.
6. Falls Windows fragt, ob die beiden Ordner **BepInEx** zusammengeführt werden sollen, bestätige das. Bei der ersten Installation müssen keine vorhandenen Mod-Dateien ersetzt werden. Eine Nachfrage nach dem Ersetzen von **ValheimContinue.dll** bedeutet, dass bereits eine Version dieser Mod dort liegt; sichere sie vor dem Austausch.

**Kontrolle:** Öffne im Spielordner nacheinander die Ordner **BepInEx → plugins → ValheimContinue**. Dort muss die Datei **ValheimContinue.dll** liegen. Diese Datei brauchst du nicht anzuklicken oder zu öffnen; Valheim lädt sie beim nächsten Start.

## 5. Im Spiel deine Verbindung einstellen

1. Starte Valheim ganz normal mit dem grünen **Spielen**-Knopf in Steam.
2. Im Hauptmenü sollten jetzt **continue** und rechts daneben **...** erscheinen.
3. Klicke auf **...**.
4. Klicke auf deine gewünschte Figur in der Liste.
5. Trage unter **Server-IP / Hostname** die Adresse deines Servers ein. Die bekommst du von der Person, die den Server betreibt. Trage hier nur die Adresse ein, ohne den Port dahinter.
6. Unter **Port** steht bereits **2456**. Lass das so, wenn dein Server keinen anderen Port verwendet. Der Port ist eine zusätzliche Nummer, die zum Server gehört; falls nötig, bekommst du sie ebenfalls vom Serverbetreiber.
7. Falls dein Server ein Passwort hat, trage es unter **Passwort** ein. Du kannst das Feld auch leer lassen; dann fragt Valheim beim Verbinden wie gewohnt danach.
8. Klicke auf **Speichern**.
9. Klicke auf **continue**.

Jetzt sollte die Mod deine Figur auswählen und dich zum Server verbinden. Nach einer erfolgreichen Anmeldung lädt die Spielwelt. Deine Einstellungen bleiben für den nächsten Start gespeichert.

**Dein Passwort bleibt auf deinem PC.** Es wird dort in einer unverschlüsselten Einstellungsdatei gespeichert. Gib diese Datei nicht weiter: Du findest sie im Spielordner unter **BepInEx → config → hellcat.valheim.continue.cfg**. Weder dein Passwort noch deine Serverdaten müssen auf GitHub eingetragen werden.

Wenn die Welt geladen ist, kannst du normal weiterspielen und Valheim offen lassen. Wenn du nur kurz testen wolltest, beende Valheim anschließend über das Spielmenü. Bevor du später Mod-Dateien austauschst oder entfernst, muss Valheim geschlossen sein.

## Wenn etwas nicht klappt

### Die Knöpfe erscheinen nicht

Beende Valheim. Prüfe die beiden Ordnerkontrollen aus Schritt 3 und 4. Häufig wurde der ganze ausgepackte Ordner kopiert, statt seines Inhalts. Starte Valheim anschließend erneut über Steam.

Falls es weiterhin nicht funktioniert, öffne im Spielordner **BepInEx** und dann die Datei **LogOutput.log**. Windows kann sie mit dem Editor öffnen. Suche mit **Strg + F** nach **Valheim Continue**. Dieser Eintrag hilft bei der Fehlersuche. Falls die Datei nicht vorhanden ist, wurde BepInEx möglicherweise noch nicht geladen.

### Meine Figur fehlt

Prüfe zuerst, ob sie in Valheims gewöhnlicher Figurenauswahl sichtbar ist. Bei einer Cloud-Figur muss Steam Zugriff auf deren gespeicherte Daten haben.

### Der Server verbindet nicht oder das Passwort ist falsch

Klicke auf **...** und prüfe Adresse, Port und Passwort. Versuche dieselbe Verbindung auch über Valheims normales Menü. Wenn sie dort ebenfalls scheitert, ist möglicherweise der Server nicht erreichbar oder eine Angabe falsch.

### Ich möchte um Hilfe bitten

Teile mit, was genau nicht funktioniert, welche Valheim-Version du hast und ob du noch andere Mods verwendest. Ein Screenshot der Fehlermeldung kann helfen. Dein Passwort und die oben genannte Einstellungsdatei brauchst du dafür nicht weiterzugeben.

## Ich benutze bereits einen Mod-Manager

Wenn du Valheim normalerweise über ein Programm wie r2modman oder Gale mit Mods startest, liegen die Mods häufig in einem eigenen Ordner dieses Programms. Kopiere die Continue-Datei **ValheimContinue.dll** in dessen **BepInEx → plugins**-Ordner und starte anschließend wieder über denselben Mod-Manager. Installiere BepInEx dort nicht noch einmal, wenn es bereits funktioniert.

Die genaue Schaltfläche zum Öffnen dieses Ordners hängt von deinem Mod-Manager ab. Die Anleitung oben gilt für die Installation direkt im Steam-Spielordner.

## Die Mod wieder entfernen

1. Beende Valheim.
2. Öffne den Spielordner wie in Schritt 2 beschrieben.
3. Öffne **BepInEx → plugins**.
4. Lösche darin ausschließlich den Ordner **ValheimContinue**. Falls du die einzelne DLL direkt unter **plugins** abgelegt hast, lösche dort stattdessen **ValheimContinue.dll**.
5. Wenn du auch die gespeicherten Serverdaten und das Passwort entfernen möchtest, öffne **BepInEx → config** und lösche **hellcat.valheim.continue.cfg**.

Beim nächsten Start ist der zusätzliche Knopf weg. Deine Figuren und Spielstände bleiben erhalten. Den restlichen BepInEx-Ordner kannst du behalten, insbesondere wenn du noch andere Mods nutzt.

[Zurück zur Startseite der Mod](../README.md)
