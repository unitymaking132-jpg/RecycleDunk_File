using System.Collections.Generic;
using System.Linq;
using TwentyOz.VivenSDK.Scripts.Core.Lua;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace RecycleDunk.Editor
{
    /// <summary>
    /// 에디터 로드 시 자동으로 모든 VivenLuaBehaviour의 null 인젝션 배열을 초기화
    /// TwozLuaChecker의 NullReferenceException 방지
    /// </summary>
    [InitializeOnLoad]
    public static class InjectionArrayInitializer
    {
        static InjectionArrayInitializer()
        {
            // 에디터가 로드될 때 한 번 실행
            EditorApplication.delayCall += InitializeAllNullInjectionArrays;

            // 씬이 열릴 때마다 실행
            EditorSceneManager.sceneOpened += OnSceneOpened;

            // 플레이 모드 진입 전에 실행
            EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
        }

        private static void OnSceneOpened(Scene scene, OpenSceneMode mode)
        {
            EditorApplication.delayCall += InitializeAllNullInjectionArrays;
        }

        private static void OnPlayModeStateChanged(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.ExitingEditMode)
            {
                InitializeAllNullInjectionArrays();
            }
        }

        public static void InitializeAllNullInjectionArrays()
        {
            // 씬의 모든 오브젝트 (비활성화 포함)
            var allBehaviours = Resources.FindObjectsOfTypeAll<VivenLuaBehaviour>();
            int fixedCount = 0;

            foreach (var behaviour in allBehaviours)
            {
                // 에셋이 아닌 씬 오브젝트만 처리
                if (EditorUtility.IsPersistent(behaviour))
                    continue;

                if (InitializeInjectionArrays(behaviour))
                {
                    EditorUtility.SetDirty(behaviour);
                    fixedCount++;
                }
            }

            if (fixedCount > 0)
            {
                Debug.Log($"[InjectionArrayInitializer] {fixedCount}개의 VivenLuaBehaviour에서 null 인젝션 배열을 초기화했습니다.");
            }
        }

        /// <summary>
        /// 단일 VivenLuaBehaviour의 injection 배열 초기화
        /// </summary>
        public static bool InitializeInjectionArrays(VivenLuaBehaviour behaviour)
        {
            if (behaviour == null) return false;

            if (behaviour.injection == null)
            {
                behaviour.injection = new Injection();
            }

            var injection = behaviour.injection;
            bool modified = false;

            if (injection.objectValues == null) { injection.objectValues = new ObjectValue[0]; modified = true; }
            if (injection.gameObjectValues == null) { injection.gameObjectValues = new GameObjectValue[0]; modified = true; }
            if (injection.vector3Values == null) { injection.vector3Values = new Vector3Value[0]; modified = true; }
            if (injection.floatValue == null) { injection.floatValue = new FloatValue[0]; modified = true; }
            if (injection.intValue == null) { injection.intValue = new IntValue[0]; modified = true; }
            if (injection.boolValue == null) { injection.boolValue = new BoolValue[0]; modified = true; }
            if (injection.stringValue == null) { injection.stringValue = new StringValue[0]; modified = true; }
            if (injection.colorValue == null) { injection.colorValue = new ColorValue[0]; modified = true; }
            if (injection.vivenScriptValue == null) { injection.vivenScriptValue = new VivenScriptValue[0]; modified = true; }

            return modified;
        }
    }

    /// <summary>
    /// 빌드 전처리기 - Viven 빌드 전에 모든 injection 배열 초기화
    /// </summary>
    public class InjectionArrayBuildPreprocessor : IPreprocessBuildWithReport
    {
        public int callbackOrder => -100; // 다른 전처리기보다 먼저 실행

        public void OnPreprocessBuild(BuildReport report)
        {
            Debug.Log("[InjectionArrayBuildPreprocessor] 빌드 전 injection 배열 초기화 시작...");

            // 씬의 모든 오브젝트 초기화
            InjectionArrayInitializer.InitializeAllNullInjectionArrays();

            // 프리팹의 VivenLuaBehaviour도 초기화
            InitializeAllPrefabInjections();

            Debug.Log("[InjectionArrayBuildPreprocessor] 빌드 전 injection 배열 초기화 완료");
        }

        private void InitializeAllPrefabInjections()
        {
            string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
            int fixedCount = 0;

            foreach (string guid in prefabGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);

                if (prefab == null) continue;

                var behaviours = prefab.GetComponentsInChildren<VivenLuaBehaviour>(true);
                foreach (var behaviour in behaviours)
                {
                    if (InjectionArrayInitializer.InitializeInjectionArrays(behaviour))
                    {
                        EditorUtility.SetDirty(behaviour);
                        fixedCount++;
                    }
                }
            }

            if (fixedCount > 0)
            {
                Debug.Log($"[InjectionArrayBuildPreprocessor] {fixedCount}개의 프리팹 VivenLuaBehaviour에서 null 인젝션 배열을 초기화했습니다.");
                AssetDatabase.SaveAssets();
            }
        }
    }

    /// <summary>
    /// TrashBin 오브젝트들의 VivenLuaBehaviour 인젝션을 수정하는 Editor 스크립트
    /// </summary>
    public class TrashBinInjectionFixer : EditorWindow
    {
        private static readonly string[] TrashBinNames = new string[]
        {
            "PaperBin",
            "PlasticBin",
            "GlassBin",
            "MetalBin",
            "GeneralGarbageBin"
        };

        [MenuItem("Recycle Dunk/Fix TrashBin Injections")]
        public static void ShowWindow()
        {
            GetWindow<TrashBinInjectionFixer>("TrashBin Injection Fixer");
        }

        [MenuItem("Recycle Dunk/Fix All Injection Arrays")]
        public static void FixAllInjectionArraysMenu()
        {
            FixAllInjectionArraysInProject();
        }

        [MenuItem("Recycle Dunk/Fix Result UI RetryButton")]
        public static void FixResultUIRetryButton()
        {
            FixResultUIRetryButtonInjection();
        }

        [MenuItem("Recycle Dunk/Setup GameOver UI")]
        public static void SetupGameOverUI()
        {
            SetupGameOverUIInternal();
        }

        private void OnGUI()
        {
            GUILayout.Label("TrashBin Injection Fixer", EditorStyles.boldLabel);
            GUILayout.Space(10);

            EditorGUILayout.HelpBox(
                "이 도구는 모든 TrashBin 오브젝트에 ScoreManagerObject와 AudioManagerObject 인젝션을 추가합니다.\n" +
                "또한 GlassBin의 BinCategory 오타(Galss → Glass)를 수정합니다.",
                MessageType.Info);

            GUILayout.Space(10);

            if (GUILayout.Button("Check Current Status (현재 상태 확인)", GUILayout.Height(30)))
            {
                CheckCurrentStatus();
            }

            GUILayout.Space(5);

            if (GUILayout.Button("Fix All TrashBin Injections (모든 인젝션 수정)", GUILayout.Height(40)))
            {
                FixAllTrashBinInjections();
            }

            GUILayout.Space(20);
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

            GUILayout.Label("NullReferenceException 방지", EditorStyles.boldLabel);

            EditorGUILayout.HelpBox(
                "TwozLuaChecker에서 NullReferenceException이 발생하는 경우,\n" +
                "아래 버튼을 클릭하여 모든 VivenLuaBehaviour의 null 인젝션 배열을 초기화하세요.",
                MessageType.Info);

            GUILayout.Space(5);

            if (GUILayout.Button("Fix All Injection Arrays (모든 null 배열 초기화)", GUILayout.Height(40)))
            {
                FixAllInjectionArraysInProject();
            }

            GUILayout.Space(10);

            EditorGUILayout.HelpBox(
                "수정 후 씬을 저장해야 변경사항이 적용됩니다. (Ctrl+S)",
                MessageType.Warning);
        }

        /// <summary>
        /// 프로젝트 전체의 모든 VivenLuaBehaviour에서 null injection 배열을 초기화
        /// </summary>
        public static void FixAllInjectionArraysInProject()
        {
            int sceneFixedCount = 0;
            int prefabFixedCount = 0;

            // 1. 현재 씬의 모든 오브젝트 (비활성화 포함)
            var allBehaviours = Resources.FindObjectsOfTypeAll<VivenLuaBehaviour>();
            foreach (var behaviour in allBehaviours)
            {
                if (EditorUtility.IsPersistent(behaviour))
                    continue;

                if (InjectionArrayInitializer.InitializeInjectionArrays(behaviour))
                {
                    EditorUtility.SetDirty(behaviour);
                    sceneFixedCount++;
                }
            }

            // 2. 모든 프리팹
            string[] prefabGuids = AssetDatabase.FindAssets("t:Prefab");
            foreach (string guid in prefabGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);

                if (prefab == null) continue;

                var behaviours = prefab.GetComponentsInChildren<VivenLuaBehaviour>(true);
                foreach (var behaviour in behaviours)
                {
                    if (InjectionArrayInitializer.InitializeInjectionArrays(behaviour))
                    {
                        EditorUtility.SetDirty(behaviour);
                        prefabFixedCount++;
                    }
                }
            }

            if (prefabFixedCount > 0)
            {
                AssetDatabase.SaveAssets();
            }

            int totalFixed = sceneFixedCount + prefabFixedCount;
            string message = $"씬: {sceneFixedCount}개, 프리팹: {prefabFixedCount}개의 VivenLuaBehaviour를 수정했습니다.";
            Debug.Log($"[FixAllInjectionArrays] {message}");

            EditorUtility.DisplayDialog(
                "Injection Arrays 초기화 완료",
                totalFixed > 0 ? message + "\n\n씬을 저장하세요 (Ctrl+S)" : "수정이 필요한 항목이 없습니다.",
                "OK");
        }

        private static void CheckCurrentStatus()
        {
            Debug.Log("=== TrashBin Injection Status Check ===");

            GameObject scoreManager = GameObject.Find("ScoreManager");
            GameObject audioManager = GameObject.Find("AudioManager");

            Debug.Log($"ScoreManager found: {scoreManager != null}");
            Debug.Log($"AudioManager found: {audioManager != null}");

            foreach (string binName in TrashBinNames)
            {
                GameObject bin = GameObject.Find(binName);
                if (bin == null)
                {
                    Debug.LogWarning($"{binName}: NOT FOUND");
                    continue;
                }

                var luaBehaviour = bin.GetComponent<VivenLuaBehaviour>();
                if (luaBehaviour == null)
                {
                    Debug.LogWarning($"{binName}: No VivenLuaBehaviour component");
                    continue;
                }

                var injection = luaBehaviour.injection;
                if (injection == null)
                {
                    Debug.LogWarning($"{binName}: No injection");
                    continue;
                }

                // Check gameObjectValues
                bool hasScoreManager = false;
                bool hasAudioManager = false;
                bool hasVFXManager = false;

                if (injection.gameObjectValues != null)
                {
                    foreach (var gv in injection.gameObjectValues)
                    {
                        if (gv.name == "ScoreManagerObject") hasScoreManager = gv.value != null;
                        if (gv.name == "AudioManagerObject") hasAudioManager = gv.value != null;
                        if (gv.name == "VFXManagerObject") hasVFXManager = gv.value != null;
                    }
                }

                // Check BinCategory
                string binCategory = "N/A";
                if (injection.stringValue != null)
                {
                    var categoryValue = injection.stringValue.FirstOrDefault(sv => sv.name == "BinCategory");
                    if (categoryValue != null)
                    {
                        binCategory = categoryValue.value;
                    }
                }

                string status = $"{binName}: " +
                    $"ScoreManager={hasScoreManager}, " +
                    $"AudioManager={hasAudioManager}, " +
                    $"VFXManager={hasVFXManager}, " +
                    $"BinCategory=\"{binCategory}\"";

                if (!hasScoreManager || !hasAudioManager || (binName == "GlassBin" && binCategory == "Galss"))
                {
                    Debug.LogError(status + " [NEEDS FIX]");
                }
                else
                {
                    Debug.Log(status + " [OK]");
                }
            }
        }

        private static void FixAllTrashBinInjections()
        {
            // Find managers
            GameObject scoreManager = GameObject.Find("ScoreManager");
            GameObject audioManager = GameObject.Find("AudioManager");

            if (scoreManager == null)
            {
                Debug.LogError("ScoreManager not found in scene!");
                return;
            }

            if (audioManager == null)
            {
                Debug.LogError("AudioManager not found in scene!");
                return;
            }

            int fixedCount = 0;

            foreach (string binName in TrashBinNames)
            {
                GameObject bin = GameObject.Find(binName);
                if (bin == null)
                {
                    Debug.LogWarning($"{binName}: NOT FOUND - skipping");
                    continue;
                }

                var luaBehaviour = bin.GetComponent<VivenLuaBehaviour>();
                if (luaBehaviour == null)
                {
                    Debug.LogWarning($"{binName}: No VivenLuaBehaviour - skipping");
                    continue;
                }

                bool modified = false;

                // Ensure injection exists
                if (luaBehaviour.injection == null)
                {
                    luaBehaviour.injection = new Injection();
                    modified = true;
                }

                var injection = luaBehaviour.injection;

                // TwozLuaChecker가 null 배열을 순회하면 NullReferenceException 발생
                // 모든 배열이 null이 아니도록 초기화
                modified |= EnsureAllInjectionArraysInitialized(injection);

                // Fix gameObjectValues
                modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "ScoreManagerObject", scoreManager);
                modified |= EnsureGameObjectInjection(ref injection.gameObjectValues, "AudioManagerObject", audioManager);

                // Fix GlassBin BinCategory typo
                if (binName == "GlassBin" && injection.stringValue != null)
                {
                    foreach (var sv in injection.stringValue)
                    {
                        if (sv.name == "BinCategory" && sv.value == "Galss")
                        {
                            sv.value = "Glass";
                            Debug.Log($"{binName}: Fixed BinCategory typo 'Galss' → 'Glass'");
                            modified = true;
                        }
                    }
                }

                if (modified)
                {
                    EditorUtility.SetDirty(luaBehaviour);
                    fixedCount++;
                    Debug.Log($"{binName}: Injection fixed successfully!");
                }
                else
                {
                    Debug.Log($"{binName}: No changes needed");
                }
            }

            if (fixedCount > 0)
            {
                Debug.Log($"=== Fixed {fixedCount} TrashBin(s). Remember to save the scene! ===");
                EditorUtility.DisplayDialog(
                    "TrashBin Injection Fix Complete",
                    $"{fixedCount}개의 TrashBin이 수정되었습니다.\n씬을 저장하세요 (Ctrl+S)",
                    "OK");
            }
            else
            {
                Debug.Log("=== No TrashBins needed fixing ===");
                EditorUtility.DisplayDialog(
                    "TrashBin Injection Check",
                    "모든 TrashBin이 이미 올바르게 설정되어 있습니다.",
                    "OK");
            }
        }

        /// <summary>
        /// 인젝션 배열에 특정 이름의 GameObject가 있는지 확인하고 없으면 추가
        /// </summary>
        private static bool EnsureGameObjectInjection(ref GameObjectValue[] gameObjectValues, string name, GameObject value)
        {
            // Check if already exists
            if (gameObjectValues != null)
            {
                for (int i = 0; i < gameObjectValues.Length; i++)
                {
                    if (gameObjectValues[i].name == name)
                    {
                        // Already exists, check if value is set
                        if (gameObjectValues[i].value == null)
                        {
                            gameObjectValues[i].value = value;
                            Debug.Log($"  → Set {name} value to {value.name}");
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

        /// <summary>
        /// Result UI의 RetryButton 인젝션 수정
        /// </summary>
        public static void FixResultUIRetryButtonInjection()
        {
            // Find Result panel
            GameObject resultPanel = GameObject.Find("Result");
            if (resultPanel == null)
            {
                Debug.LogError("Result panel not found in scene!");
                EditorUtility.DisplayDialog("Error", "Result 패널을 찾을 수 없습니다.", "OK");
                return;
            }

            var luaBehaviour = resultPanel.GetComponent<VivenLuaBehaviour>();
            if (luaBehaviour == null)
            {
                Debug.LogError("Result panel has no VivenLuaBehaviour!");
                EditorUtility.DisplayDialog("Error", "Result 패널에 VivenLuaBehaviour가 없습니다.", "OK");
                return;
            }

            // Find RetryButton
            GameObject retryButton = FindChildRecursive(resultPanel.transform, "RetryButton");
            if (retryButton == null)
            {
                Debug.LogError("RetryButton not found under Result panel!");
                EditorUtility.DisplayDialog("Error", "Result 패널 아래에 RetryButton이 없습니다.", "OK");
                return;
            }

            var injection = luaBehaviour.injection;
            if (injection == null)
            {
                injection = new Injection();
                luaBehaviour.injection = injection;
            }

            // Ensure arrays are initialized
            EnsureAllInjectionArraysInitialized(injection);

            // Fix RetryButton injection
            bool modified = EnsureGameObjectInjection(ref injection.gameObjectValues, "RetryButton", retryButton);

            if (modified)
            {
                EditorUtility.SetDirty(luaBehaviour);
                Debug.Log("Result UI RetryButton injection fixed successfully!");
                EditorUtility.DisplayDialog(
                    "RetryButton 인젝션 수정 완료",
                    "RetryButton 인젝션이 수정되었습니다.\n씬을 저장하세요 (Ctrl+S)",
                    "OK");
            }
            else
            {
                Debug.Log("Result UI RetryButton injection is already correct.");
                EditorUtility.DisplayDialog(
                    "RetryButton 인젝션 확인",
                    "RetryButton 인젝션이 이미 올바르게 설정되어 있습니다.",
                    "OK");
            }
        }

        /// <summary>
        /// 자식 오브젝트 중 이름으로 검색 (재귀)
        /// </summary>
        private static GameObject FindChildRecursive(Transform parent, string name)
        {
            foreach (Transform child in parent)
            {
                if (child.name == name)
                    return child.gameObject;

                var found = FindChildRecursive(child, name);
                if (found != null)
                    return found;
            }
            return null;
        }

        /// <summary>
        /// GameOver UI 설정 (VivenLuaBehaviour 추가 + GameOverUI.lua 연결 + RetryButton 인젝션)
        /// </summary>
        public static void SetupGameOverUIInternal()
        {
            // Find GameOver panel
            GameObject gameOverPanel = GameObject.Find("GameOver");
            if (gameOverPanel == null)
            {
                Debug.LogError("GameOver panel not found in scene!");
                EditorUtility.DisplayDialog("Error", "GameOver 패널을 찾을 수 없습니다.", "OK");
                return;
            }

            // Find GameOverUI.lua script
            VivenScript gameOverScript = null;
            string[] guids = AssetDatabase.FindAssets("GameOverUI t:VivenScript");
            foreach (string guid in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(guid);
                gameOverScript = AssetDatabase.LoadAssetAtPath<VivenScript>(path);
                if (gameOverScript != null)
                    break;
            }

            if (gameOverScript == null)
            {
                Debug.LogError("GameOverUI.lua script not found!");
                EditorUtility.DisplayDialog("Error", "GameOverUI.lua 스크립트를 찾을 수 없습니다.", "OK");
                return;
            }

            // Find RetryButton under GameOver panel
            GameObject retryButton = FindChildRecursive(gameOverPanel.transform, "RetryButton");
            if (retryButton == null)
            {
                Debug.LogError("RetryButton not found under GameOver panel!");
                EditorUtility.DisplayDialog("Error", "GameOver 패널 아래에 RetryButton이 없습니다.", "OK");
                return;
            }

            bool modified = false;

            // Add or get VivenLuaBehaviour component
            var luaBehaviour = gameOverPanel.GetComponent<VivenLuaBehaviour>();
            if (luaBehaviour == null)
            {
                luaBehaviour = gameOverPanel.AddComponent<VivenLuaBehaviour>();
                Debug.Log("GameOver: VivenLuaBehaviour 컴포넌트를 추가했습니다.");
                modified = true;
            }

            // Set Lua script
            if (luaBehaviour.luaScript != gameOverScript)
            {
                luaBehaviour.luaScript = gameOverScript;
                Debug.Log($"GameOver: Lua 스크립트를 설정했습니다: {gameOverScript.name}");
                modified = true;
            }

            // Ensure injection exists
            if (luaBehaviour.injection == null)
            {
                luaBehaviour.injection = new Injection();
                modified = true;
            }

            // Initialize injection arrays
            modified |= EnsureAllInjectionArraysInitialized(luaBehaviour.injection);

            // Set RetryButton injection
            modified |= EnsureGameObjectInjection(ref luaBehaviour.injection.gameObjectValues, "RetryButton", retryButton);

            if (modified)
            {
                EditorUtility.SetDirty(luaBehaviour);
                EditorUtility.SetDirty(gameOverPanel);
                Debug.Log("=== GameOver UI 설정 완료 ===");
                EditorUtility.DisplayDialog(
                    "GameOver UI 설정 완료",
                    "GameOver UI가 성공적으로 설정되었습니다.\n" +
                    "- VivenLuaBehaviour 추가됨\n" +
                    "- GameOverUI.lua 연결됨\n" +
                    "- RetryButton 인젝션 설정됨\n\n" +
                    "씬을 저장하세요 (Ctrl+S)",
                    "OK");
            }
            else
            {
                Debug.Log("=== GameOver UI 변경사항 없음 ===");
                EditorUtility.DisplayDialog(
                    "GameOver UI 확인",
                    "GameOver UI가 이미 올바르게 설정되어 있습니다.",
                    "OK");
            }
        }

        /// <summary>
        /// TwozLuaChecker가 null 배열을 순회할 때 NullReferenceException이 발생하지 않도록
        /// 모든 인젝션 배열을 빈 배열로 초기화
        /// </summary>
        private static bool EnsureAllInjectionArraysInitialized(Injection injection)
        {
            bool modified = false;

            if (injection.objectValues == null)
            {
                injection.objectValues = new ObjectValue[0];
                modified = true;
            }

            if (injection.gameObjectValues == null)
            {
                injection.gameObjectValues = new GameObjectValue[0];
                modified = true;
            }

            if (injection.vector3Values == null)
            {
                injection.vector3Values = new Vector3Value[0];
                modified = true;
            }

            if (injection.floatValue == null)
            {
                injection.floatValue = new FloatValue[0];
                modified = true;
            }

            if (injection.intValue == null)
            {
                injection.intValue = new IntValue[0];
                modified = true;
            }

            if (injection.boolValue == null)
            {
                injection.boolValue = new BoolValue[0];
                modified = true;
            }

            if (injection.stringValue == null)
            {
                injection.stringValue = new StringValue[0];
                modified = true;
            }

            if (injection.colorValue == null)
            {
                injection.colorValue = new ColorValue[0];
                modified = true;
            }

            if (injection.vivenScriptValue == null)
            {
                injection.vivenScriptValue = new VivenScriptValue[0];
                modified = true;
            }

            if (modified)
            {
                Debug.Log("  → Initialized null injection arrays to empty arrays");
            }

            return modified;
        }
    }
}
