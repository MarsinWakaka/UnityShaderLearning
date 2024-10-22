using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class ShowFPS : MonoBehaviour
{
    public Text fpsText; // 引用显示FPS的UI Text组件
    public Font defaultFont;
    public int fps = 60;

    void Start()
    {
        Application.targetFrameRate = fps;

        // 获取UI Text组件的引用
        fpsText = GetComponent<Text>();
        if (fpsText == null)
        {
            GameObject canvas = GameObject.Find("Canvas");
            if (canvas != null)
            {
                GameObject fpsBox = new GameObject("fpsBox");
                fpsBox.transform.SetParent(canvas.transform, false); // 设置为不缩放
                RectTransform rectTransform = fpsBox.AddComponent<RectTransform>();
                rectTransform.anchorMin = new Vector2(0f, 1f); // 左上角锚点
                rectTransform.anchorMax = new Vector2(0f, 1f); // 左上角锚点
                rectTransform.pivot = new Vector2(0f, 1f); // 左上角为中心点
                rectTransform.anchoredPosition = Vector2.zero; // 设置在左上角
                fpsBox.AddComponent<Text>();
                fpsText = fpsBox.GetComponent<Text>();

                if(fpsText.font ==  null)
                    if(defaultFont != null)
                        fpsText.font = defaultFont;

                fpsText.fontSize = 60;
                fpsText.horizontalOverflow = HorizontalWrapMode.Overflow;
                fpsText.color = Color.white;
                StartCoroutine(FPS());
            }
            else
            {
                Debug.LogWarning("未找到Canvas");
            }
        }
    }

    private int frameCount = 0;
    private float deltaTime = 0.0f;
    private float updateRate = 0.5f; // 帧率更新频率，例如每0.5秒更新一次

    IEnumerator FPS()
    {
        while (true)
        {
            frameCount++;
            deltaTime += Time.deltaTime;

            if (deltaTime > updateRate)
            {
                float fps = frameCount / deltaTime;
                fpsText.text = "FPS: " + Mathf.RoundToInt(fps).ToString();

                frameCount = 0;
                deltaTime -= updateRate;
            }

            yield return null;
        }
    }

}
