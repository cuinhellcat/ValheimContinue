using System;
using System.Collections.Generic;
using System.Linq;
using BepInEx;
using BepInEx.Configuration;
using HarmonyLib;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Hellcat.ValheimContinue
{
    [BepInPlugin(Id, "Valheim Continue", "1.0.0")]
    public sealed class Plugin : BaseUnityPlugin
    {
        public const string Id = "hellcat.valheim.continue";
        internal static Plugin Instance;
        ConfigEntry<string> character, host, password;
        ConfigEntry<int> port;
        Harmony harmony;
        FejdStartup startup;
        bool settingsOpen;
        string editCharacter, editHost, editPort, editPassword, message = "";
        bool pending, ownsPassword;
        float deadline;
        Button continueButton, settingsButton;
        bool originalMenuActive;

        void Awake()
        {
            Instance = this;
            character = Config.Bind("Connection", "Character", "", "Exact character filename without .fch; supports local and cloud saves.");
            host = Config.Bind("Connection", "Host", "", "Dedicated server IPv4, IPv6 or hostname.");
            port = Config.Bind("Connection", "Port", 2456, "Server game port (not query port).");
            password = Config.Bind("Connection", "Password", "", "Explicitly entered password, stored locally in plaintext. Empty means use the normal password dialog.");
            harmony = new Harmony(Id);
            harmony.PatchAll();
            Logger.LogInfo("Valheim Continue loaded. Passwords are never logged.");
        }

        void OnDestroy()
        {
            ClearPending();
            if (startup != null && settingsOpen) startup.m_menuList.SetActive(originalMenuActive);
            if (continueButton != null) Destroy(continueButton.gameObject);
            if (settingsButton != null) Destroy(settingsButton.gameObject);
            harmony?.UnpatchSelf();
            Instance = null;
        }

        static List<PlayerProfile> Profiles(FejdStartup menu) =>
            AccessTools.Field(typeof(FejdStartup), "m_profiles").GetValue(menu) as List<PlayerProfile>;

        internal void Attach(FejdStartup menu)
        {
            ClearPending();
            startup = menu;
            settingsOpen = false;
            var template = menu.m_menuList.GetComponentsInChildren<Button>(true)
                .FirstOrDefault(b => b.gameObject.activeSelf);
            if (template == null) { Logger.LogError("Main menu button template missing."); return; }
            continueButton = Clone(template, "HellcatContinue", "continue", () => Connect());
            settingsButton = Clone(template, "HellcatContinueSettings", "...", () => OpenSettings());
            var parent = (RectTransform)template.transform.parent;
            if (parent.GetComponent<LayoutGroup>() != null)
            {
                continueButton.transform.SetSiblingIndex(template.transform.GetSiblingIndex());
                settingsButton.transform.SetSiblingIndex(continueButton.transform.GetSiblingIndex() + 1);
                LayoutRebuilder.ForceRebuildLayoutImmediate(parent);
            }
            else
            {
                // Add a single row above existing entries; never move the original menu.
                var tr = (RectTransform)template.transform;
                var cr = (RectTransform)continueButton.transform;
                var sr = (RectTransform)settingsButton.transform;
                float top = template.transform.parent.GetComponentsInChildren<Button>(true)
                    .Where(b => b != continueButton && b != settingsButton && b.transform.parent == parent)
                    .Max(b => ((RectTransform)b.transform).anchoredPosition.y);
                cr.anchoredPosition = new Vector2(tr.anchoredPosition.x, top + Math.Max(tr.rect.height, 35) + 8);
                sr.anchoredPosition = cr.anchoredPosition + new Vector2(tr.rect.width / 2 + 38, 0);
                sr.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal, 64);
            }
            Logger.LogInfo("Main menu continue and settings buttons created.");
        }

        Button Clone(Button template, string name, string caption, UnityEngine.Events.UnityAction action)
        {
            var obj = Instantiate(template.gameObject, template.transform.parent);
            obj.name = name;
            var button = obj.GetComponent<Button>();
            // Replace the entire event, including persistent inspector callbacks on the template.
            button.onClick = new Button.ButtonClickedEvent();
            button.onClick.AddListener(action);
            var text = obj.GetComponentInChildren<TMP_Text>(true);
            if (text != null) text.text = caption;
            obj.SetActive(true);
            return button;
        }

        void OpenSettings()
        {
            editCharacter = character.Value;
            editHost = host.Value;
            editPort = port.Value.ToString();
            editPassword = password.Value;
            message = "";
            originalMenuActive = startup.m_menuList.activeSelf;
            startup.m_menuList.SetActive(false); // prevent menu shortcuts firing while typing
            settingsOpen = true;
        }

        void CloseSettings()
        {
            settingsOpen = false;
            editPassword = null;
            if (startup != null) startup.m_menuList.SetActive(originalMenuActive);
        }

        static string Validate(string profile, string address, string portText, List<PlayerProfile> profiles, out int number)
        {
            number = 0;
            if (string.IsNullOrWhiteSpace(profile)) return "Bitte eine Figur auswählen.";
            if (profiles == null || !profiles.Any(p => p.GetFilename() == profile)) return "Figur nicht gefunden. Bitte aus der Liste auswählen.";
            if (string.IsNullOrWhiteSpace(address) || address.Any(char.IsWhiteSpace) || address.Contains("/") || address.Contains("://"))
                return "Bitte eine Server-IP oder einen Hostnamen ohne Port eingeben.";
            if (!int.TryParse(portText, out number) || number < 1 || number > 65535) return "Der Port muss zwischen 1 und 65535 liegen.";
            return null;
        }

        void Connect()
        {
            if (pending || startup == null) return;
            message = Validate(character.Value, host.Value, port.Value.ToString(), Profiles(startup), out int selectedPort);
            if (message != null) { string error = message; OpenSettings(); message = error; return; }
            try
            {
                var data = new ServerJoinData(new ServerJoinDataDedicated(host.Value.Trim(), (ushort)selectedPort));
                // First use the normal privilege checks and queue the server for character selection.
                AccessTools.Method(typeof(FejdStartup), "ProceedJoinRequest").Invoke(startup, new object[] { data });
                var queued = (ServerJoinData)AccessTools.Field(typeof(FejdStartup), "m_queuedJoinServer").GetValue(startup);
                if (!queued.IsValid || !queued.Equals(data)) return;
                AccessTools.Method(typeof(FejdStartup), "SetSelectedProfile").Invoke(startup, new object[] { character.Value });
                pending = true;
                deadline = Time.realtimeSinceStartup + 90;
                startup.OnCharacterStart();
                Logger.LogInfo("Continue requested through the normal character and server join flow.");
            }
            catch (Exception)
            {
                ClearPending();
                OpenSettings();
                message = "Verbindung konnte nicht gestartet werden. Spielversion und Mod prüfen.";
                Logger.LogError("Continue failed; no connection details or passwords were logged.");
            }
        }

        internal bool SupplyPassword()
        {
            // Only this one explicitly requested continue attempt may receive the configured password.
            if (!pending) return false;
            if (Time.realtimeSinceStartup > deadline) { ClearPending(); return false; }
            AccessTools.PropertySetter(typeof(FejdStartup), "ServerPassword").Invoke(null,
                new object[] { string.IsNullOrEmpty(password.Value) ? null : password.Value });
            ownsPassword = true;
            pending = false;
            return true;
        }

        internal void ClearPending()
        {
            pending = false;
            if (ownsPassword)
                AccessTools.PropertySetter(typeof(FejdStartup), "ServerPassword").Invoke(null, new object[] { null });
            ownsPassword = false;
        }

        void Update()
        {
            if (pending && Time.realtimeSinceStartup > deadline) ClearPending();
            if (continueButton != null) continueButton.interactable = !pending;
            if (settingsOpen && (startup == null || !startup.m_mainMenu.activeInHierarchy)) CloseSettings();
            if (settingsOpen && Input.GetKeyDown(KeyCode.Escape)) CloseSettings();
        }

        void OnGUI()
        {
            if (!settingsOpen || startup == null) return;
            float scale = Math.Max(0.7f, Math.Min(Screen.width / 1000f, Screen.height / 750f));
            var previous = GUI.matrix;
            GUI.matrix = Matrix4x4.TRS(Vector3.zero, Quaternion.identity, new Vector3(scale, scale, 1));
            GUILayout.BeginArea(new Rect((Screen.width / scale - 570) / 2, (Screen.height / scale - 590) / 2, 570, 590), GUI.skin.box);
            GUILayout.Label("continue – Verbindung einstellen");
            GUILayout.Space(10);
            GUILayout.Label("Figur (lokal oder Steam Cloud): " + editCharacter);
            var profiles = Profiles(startup);
            if (profiles != null)
                foreach (var profile in profiles)
                    if (GUILayout.Button(profile.GetName() + " [" + profile.m_fileSource + "]")) editCharacter = profile.GetFilename();
            GUILayout.Label("Server-IP / Hostname");
            editHost = GUILayout.TextField(editHost, 255);
            GUILayout.Label("Port");
            editPort = GUILayout.TextField(editPort, 5);
            GUILayout.Label("Passwort (leer = normale Passwortabfrage)");
            editPassword = GUILayout.PasswordField(editPassword ?? "", '*', 128);
            GUILayout.Label("Das Passwort wird lokal im Klartext gespeichert.\nEs wird ausschließlich bei continue verwendet.");
            GUILayout.Space(10);
            if (!string.IsNullOrEmpty(message)) GUILayout.Label(message);
            if (GUILayout.Button("Speichern"))
            {
                message = Validate(editCharacter, editHost.Trim(), editPort, profiles, out int selectedPort);
                if (message == null)
                {
                    character.Value = editCharacter;
                    host.Value = editHost.Trim();
                    port.Value = selectedPort;
                    password.Value = editPassword;
                    Config.Save();
                    CloseSettings();
                }
            }
            if (GUILayout.Button("Abbrechen")) CloseSettings();
            GUILayout.EndArea();
            GUI.matrix = previous;
        }

        [HarmonyPatch(typeof(FejdStartup), "Start")]
        static class MenuPatch
        {
            static void Postfix(FejdStartup __instance) => Instance?.Attach(__instance);
        }

        [HarmonyPatch(typeof(ZNet), "RPC_ClientHandshake")]
        static class PasswordPatch
        {
            static void Prefix(out bool __state) => __state = Instance?.SupplyPassword() ?? false;
            static Exception Finalizer(Exception __exception, bool __state)
            {
                if (__state) Instance?.ClearPending();
                return __exception;
            }
        }
    }
}
