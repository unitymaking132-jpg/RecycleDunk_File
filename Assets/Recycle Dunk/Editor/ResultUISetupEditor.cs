using System.Collections.Generic;
using System.Linq;
using TwentyOz.VivenSDK.Scripts.Core.Lua;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

namespace RecycleDunk.Editor
{
    /// <summary>
    /// Result 패널의 VivenLuaBehaviour를 설정하고 ResultUIManager.lua의 Injection을 자동 구성하는 Editor 스크립트
    /// </summary>
    public class ResultUISetupEditor : EditorWindow
    {
        private VivenScript luaScript;
        private GameObject resultPanel;

        // Required injections for ResultUIManager.lua
        private static readonly string[] RequiredInjections = new string[]
        {
            "ScoreTextObject",
            "AccuracyTextObject",
            "MostWrongTextObject",
            "HintTextObject",
            "RetryButton"
        };

        [MenuItem("Recycle Dunk/Setup Result UI")]
        public static void ShowWindow()
        {
            GetWindow<ResultUISetupEditor>("Result UI Setup");
        }

        private void OnEnable()
        {
            // Auto-find the ResultUIManager.lua script (VivenScript type)
            string[] guids = AssetDatabase.FindAssets("ResultUIManager t:VivenScript");
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                luaScript = AssetDatabase.LoadAssetAtPath<VivenScript>(path);
                if (luaScript != null)
                    break;
            }

            // Auto-find Result panel
            resultPanel = GameObject.Find("Result");
        }

        private void OnGUI()
        {
            GUILayout.Label("Result UI 자동 설정", EditorStyles.boldLabel);
            GUILayout.Space(10);

            EditorGUILayout.HelpBox(
                "이 도구는 Result 패널에 VivenLuaBehaviour를 추가하고\n" +
                "ResultUIManager.lua의 Injection을 자동으로 설정합니다.\n\n" +
                "필요한 Injection:\n" +
                "• ScoreTextObject\n" +
                "• AccuracyTextObject\n" +
                "• MostWrongTextObject\n" +
                "• HintTextObject\n" +
                "• RetryButton",
                MessageType.Info);

            GUILayout.Space(10);

            // Lua Script field
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Lua Script:", GUILayout.Width(100));
            luaScript = (VivenScript)EditorGUILayout.ObjectField(luaScript, typeof(VivenScript), false);
            EditorGUILayout.EndHorizontal();

            // Result Panel field
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Result Panel:", GUILayout.Width(100));
            resultPanel = (GameObject)EditorGUILayout.ObjectField(resultPanel, typeof(GameObject), true);
            EditorGUILayout.EndHorizontal();

            GUILayout.Space(10);

            // Status check button
            if (GUILayout.Button("현재 상태 확인", GUILayout.Height(30)))
            {
                CheckCurrentStatus();
            }

            GUILayout.Space(5);

            // Setup button
            GUI.enabled = luaScript != null && resultPanel != null;
            if (GUILayout.Button("Result UI 설정 실행", GUILayout.Height(40)))
            {
                SetupResultUI();
            }
            GUI.enabled = true;

            GUILayout.Space(5);

            // Quick setup button (finds and creates everything automatically)
            if (GUILayout.Button("자동 설정 (전체 자동화)", GUILayout.Height(40)))
            {
                AutoSetupResultUI();
            }

            GUILayout.Space(10);

            EditorGUILayout.HelpBox(
                "설정 후 씬을 저장해야 변경사항이 적용됩니다. (Ctrl+S)",
                MessageType.Warning);
        }

        /// <summary>
        /// 현재 Result 패널의 상태를 확인하고 로그 출력
        /// </summary>
        private void CheckCurrentStatus()
        {
            Debug.Log("=== Result UI Status Check ===");

            // Find Result panel
            GameObject result = resultPanel ?? GameObject.Find("Result");
            if (result == null)
            {
                Debug.LogError("Result 패널을 찾을 수 없습니다!");
                return;
            }
            Debug.Log($"Result Panel: {result.name} (instanceID: {result.GetInstanceID()})");

            // Check VivenLuaBehaviour
            var luaBehaviour = result.GetComponent<VivenLuaBehaviour>();
            if (luaBehaviour == null)
            {
                Debug.LogWarning("VivenLuaBehaviour 컴포넌트가 없습니다.");
            }
            else
            {
                Debug.Log($"VivenLuaBehaviour: OK (Lua Script: {(luaBehaviour.luaScript != null ? luaBehaviour.luaScript.name : "NULL")})");

                // Check injections
                if (luaBehaviour.injection?.gameObjectValues != null)
                {
                    Debug.Log("현재 Injection 목록:");
                    foreach (var gv in luaBehaviour.injection.gameObjectValues)
                    {
                        string status = gv.value != null ? gv.value.name : "NULL";
                        Debug.Log($"  • {gv.name} = {status}");
                    }
                }
            }

            // List children
            Debug.Log("Result 패널 자식 오브젝트:");
            for (int i = 0; i < result.transform.childCount; i++)
            {
                Transform child = result.transform.GetChild(i);
                string components = string.Join(", ", child.GetComponents<Component>().Select(c => c.GetType().Name));
                Debug.Log($"  [{i}] {child.name} - Components: {components}");
            }
        }

        /// <summary>
        /// Result UI 설정 실행 (수동 모드)
        /// </summary>
        private void SetupResultUI()
        {
            if (resultPanel == null)
            {
                Debug.LogError("Result 패널이 선택되지 않았습니다!");
                return;
            }

            if (luaScript == null)
            {
                Debug.LogError("Lua 스크립트가 선택되지 않았습니다!");
                return;
            }

            SetupResultUIInternal(resultPanel, luaScript);
        }

        /// <summary>
        /// 전체 자동화 설정
        /// </summary>
        private void AutoSetupResultUI()
        {
            Debug.Log("=== Auto Setup Result UI ===");

            // 1. Find Result panel
            GameObject result = GameObject.Find("Result");
            if (result == null)
            {
                Debug.LogError("Result 패널을 찾을 수 없습니다!");
                EditorUtility.DisplayDialog("Error", "Result 패널을 찾을 수 없습니다!", "OK");
                return;
            }

            // 2. Find Lua script (VivenScript type)
            VivenScript script = null;
            string[] guids = AssetDatabase.FindAssets("ResultUIManager t:VivenScript");
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                script = AssetDatabase.LoadAssetAtPath<VivenScript>(path);
                if (script != null)
                    break;
            }

            if (script == null)
            {
                Debug.LogError("ResultUIManager.lua 스크립트를 찾을 수 없습니다!");
                EditorUtility.DisplayDialog("Error", "ResultUIManager.lua 스크립트를 찾을 수 없습니다!", "OK");
                return;
            }

            SetupResultUIInternal(result, script);
        }

        /// <summary>
        /// Result UI 설정 내부 구현
        /// </summary>
        private void SetupResultUIInternal(GameObject result, VivenScript script)
        {
            bool modified = false;

            // 1. Add or get VivenLuaBehaviour component
            var luaBehaviour = result.GetComponent<VivenLuaBehaviour>();
            if (luaBehaviour == null)
            {
                luaBehaviour = result.AddComponent<VivenLuaBehaviour>();
                Debug.Log("VivenLuaBehaviour 컴포넌트를 추가했습니다.");
                modified = true;
            }

            // 2. Set Lua script
            if (luaBehaviour.luaScript != script)
            {
                luaBehaviour.luaScript = script;
                Debug.Log($"Lua 스크립트를 설정했습니다: {script.name}");
                modified = true;
            }

            // 3. Ensure injection exists
            if (luaBehaviour.injection == null)
            {
                luaBehaviour.injection = new Injection();
                modified = true;
            }

            // 4. Setup text elements - rename existing or find by index
            Transform[] children = new Transform[result.transform.childCount];
            for (int i = 0; i < result.transform.childCount; i++)
            {
                children[i] = result.transform.GetChild(i);
            }

            // Find or create text elements
            GameObject scoreTextObj = FindOrCreateTextElement(result, children, "ScoreText", 0);
            GameObject accuracyTextObj = FindOrCreateTextElement(result, children, "AccuracyText", 1);
            GameObject mostWrongTextObj = FindOrCreateTextElement(result, children, "MostWrongText", 2);
            GameObject hintTextObj = FindOrCreateTextElement(result, children, "HintText", 3);

            // 5. Find or create RetryButton
            GameObject retryButton = FindOrCreateRetryButton(result);

            // 6. Setup injections
            var injection = luaBehaviour.injection;

            modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "ScoreTextObject", scoreTextObj);
            modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "AccuracyTextObject", accuracyTextObj);
            modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "MostWrongTextObject", mostWrongTextObj);
            modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "HintTextObject", hintTextObj);
            modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "RetryButton", retryButton);

            if (modified)
            {
                EditorUtility.SetDirty(luaBehaviour);
                EditorUtility.SetDirty(result);

                Debug.Log("=== Result UI 설정 완료 ===");
                Debug.Log("Injection 목록:");
                foreach (var gv in injection.gameObjectValues)
                {
                    Debug.Log($"  • {gv.name} = {(gv.value != null ? gv.value.name : "NULL")}");
                }

                EditorUtility.DisplayDialog(
                    "설정 완료",
                    "Result UI가 성공적으로 설정되었습니다.\n씬을 저장하세요 (Ctrl+S)",
                    "OK");
            }
            else
            {
                Debug.Log("=== 변경사항 없음 ===");
                EditorUtility.DisplayDialog(
                    "설정 확인",
                    "Result UI가 이미 올바르게 설정되어 있습니다.",
                    "OK");
            }
        }

        /// <summary>
        /// 텍스트 요소 찾기 또는 생성
        /// </summary>
        private GameObject FindOrCreateTextElement(GameObject parent, Transform[] children, string name, int preferredIndex)
        {
            // First, try to find by name
            var existing = parent.transform.Find(name);
            if (existing != null)
            {
                return existing.gameObject;
            }

            // Try to find TMP_Text component with similar name patterns
            foreach (var child in children)
            {
                if (child.name.Contains(name.Replace("Text", "")))
                {
                    child.name = name;
                    EditorUtility.SetDirty(child.gameObject);
                    Debug.Log($"텍스트 요소 이름 변경: {child.name} → {name}");
                    return child.gameObject;
                }
            }

            // Use preferred index if available
            if (preferredIndex < children.Length)
            {
                var child = children[preferredIndex];
                if (child.GetComponent<TextMeshProUGUI>() != null || child.GetComponent<TMP_Text>() != null)
                {
                    child.name = name;
                    EditorUtility.SetDirty(child.gameObject);
                    Debug.Log($"텍스트 요소 이름 변경 (인덱스 {preferredIndex}): → {name}");
                    return child.gameObject;
                }
            }

            // Find any TMP element without matching name yet
            string[] usedNames = { "ScoreText", "AccuracyText", "MostWrongText", "HintText" };
            foreach (var child in children)
            {
                if (child.GetComponent<TextMeshProUGUI>() != null || child.GetComponent<TMP_Text>() != null)
                {
                    bool isUsed = usedNames.Any(n => child.name == n);
                    if (!isUsed && child.name.StartsWith("Text"))
                    {
                        child.name = name;
                        EditorUtility.SetDirty(child.gameObject);
                        Debug.Log($"텍스트 요소 이름 변경: {child.name} → {name}");
                        return child.gameObject;
                    }
                }
            }

            Debug.LogWarning($"{name}을 찾을 수 없습니다. 수동으로 생성해주세요.");
            return null;
        }

        /// <summary>
        /// RetryButton 찾기 또는 생성
        /// </summary>
        private GameObject FindOrCreateRetryButton(GameObject resultPanel)
        {
            // First check in Result panel
            var existingButton = resultPanel.transform.Find("RetryButton");
            if (existingButton != null)
            {
                return existingButton.gameObject;
            }

            // Find any Button component in children
            foreach (Transform child in resultPanel.transform)
            {
                if (child.GetComponent<Button>() != null)
                {
                    child.name = "RetryButton";
                    EditorUtility.SetDirty(child.gameObject);
                    Debug.Log($"버튼 이름 변경: → RetryButton");
                    return child.gameObject;
                }
            }

            // Try to find Button in scene named "Button" or "Retry"
            var sceneButtons = Object.FindObjectsOfType<Button>();
            foreach (var btn in sceneButtons)
            {
                if (btn.name.Contains("Retry") || btn.transform.parent == resultPanel.transform)
                {
                    btn.name = "RetryButton";
                    // Move to Result panel if not already there
                    if (btn.transform.parent != resultPanel.transform)
                    {
                        btn.transform.SetParent(resultPanel.transform, true);
                        Debug.Log("RetryButton을 Result 패널로 이동했습니다.");
                    }
                    EditorUtility.SetDirty(btn.gameObject);
                    return btn.gameObject;
                }
            }

            // Create new button
            Debug.Log("RetryButton을 새로 생성합니다.");
            GameObject buttonObj = new GameObject("RetryButton");
            buttonObj.transform.SetParent(resultPanel.transform, false);

            // Add required components
            RectTransform rect = buttonObj.AddComponent<RectTransform>();
            rect.anchoredPosition = new Vector2(0, -200);
            rect.sizeDelta = new Vector2(200, 60);

            buttonObj.AddComponent<CanvasRenderer>();
            Image image = buttonObj.AddComponent<Image>();
            image.color = new Color(0.2f, 0.6f, 0.2f, 1f);
            buttonObj.AddComponent<Button>();

            // Add text child
            GameObject textObj = new GameObject("Text (TMP)");
            textObj.transform.SetParent(buttonObj.transform, false);

            RectTransform textRect = textObj.AddComponent<RectTransform>();
            textRect.anchorMin = Vector2.zero;
            textRect.anchorMax = Vector2.one;
            textRect.offsetMin = Vector2.zero;
            textRect.offsetMax = Vector2.zero;

            TextMeshProUGUI text = textObj.AddComponent<TextMeshProUGUI>();
            text.text = "RETRY";
            text.alignment = TextAlignmentOptions.Center;
            text.fontSize = 24;

            EditorUtility.SetDirty(buttonObj);
            return buttonObj;
        }

        /// <summary>
        /// 인젝션 배열에 특정 이름의 GameObject가 있는지 확인하고 없으면 추가
        /// </summary>
        private static bool EnsureGameObjectInjection(ref GameObjectValue[] gameObjectValues, string name, GameObject value)
        {
            if (value == null)
            {
                Debug.LogWarning($"{name}에 대한 GameObject가 null입니다!");
                return false;
            }

            // Check if already exists
            if (gameObjectValues != null)
            {
                for (int i = 0; i < gameObjectValues.Length; i++)
                {
                    if (gameObjectValues[i].name == name)
                    {
                        // Already exists, check if value is set
                        if (gameObjectValues[i].value != value)
                        {
                            gameObjectValues[i].value = value;
                            Debug.Log($"  → Updated {name} = {value.name}");
                            return true;
                        }
                        return false; // Already set correctly
                    }
                }
            }

            // Not found, add new entry
            var newEntry = new GameObjectValue
            {
                name = name,
                value = value
            };

            if (gameObjectValues == null)
            {
                gameObjectValues = new GameObjectValue[] { newEntry };
            }
            else
            {
                var list = new List<GameObjectValue>(gameObjectValues);
                list.Add(newEntry);
                gameObjectValues = list.ToArray();
            }

            Debug.Log($"  → Added {name} = {value.name}");
            return true;
        }
    }
}
