"""Package the unchanged mod with a small Windows installer; no game files bundled."""
from pathlib import Path
import hashlib
import re
import zipfile

root = Path(__file__).resolve().parent.parent
dist = root / "dist"
dll = dist / "ValheimContinue.dll"
script = (root / "installer/Install.ps1").read_text()
expected = re.search(r"Assert-FileHash \$plugin '([a-f0-9]{64})'", script).group(1)
assert hashlib.sha256(dll.read_bytes()).hexdigest() == expected, "Update the installer DLL hash first"

archive = dist / "ValheimContinue-Windows-Einfach-1.0.0.zip"
with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as output:
    for name in ["Installieren.cmd", "Rueckgaengig.cmd"]:
        data = (root / "installer" / name).read_text().replace("\n", "\r\n").encode("ascii")
        output.writestr(name, data)
    for name in ["Install.ps1", "Installer.Core.ps1"]:
        data = (root / "installer" / name).read_text().replace("\n", "\r\n").encode("utf-8-sig")
        output.writestr("installer/" + name, data)
    output.write(dll, "installer/ValheimContinue.dll")
    output.write(root / "docs/INSTALL-WINDOWS.md", "Anleitung.txt")
    output.write(root / "LICENSE", "LICENSE.txt")

archives = [dist / "ValheimContinue-1.0.0.zip", archive]
(dist / "SHA256SUMS.txt").write_text("".join(
    hashlib.sha256(file.read_bytes()).hexdigest() + "  " + file.name + "\n"
    for file in archives
))
print("Packaged:", archive.name)
