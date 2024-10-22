using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class ShowFPS : MonoBehaviour
{
    public Text fpsText; // ������ʾFPS��UI Text���
    public Font defaultFont;
    public int fps = 60;

    void Start()
    {
        Application.targetFrameRate = fps;

        // ��ȡUI Text���������
        fpsText = GetComponent<Text>();
        if (fpsText == null)
        {
            GameObject canvas = GameObject.Find("Canvas");
            if (canvas != null)
            {
                GameObject fpsBox = new GameObject("fpsBox");
                fpsBox.transform.SetParent(canvas.transform, false); // ����Ϊ������
                RectTransform rectTransform = fpsBox.AddComponent<RectTransform>();
                rectTransform.anchorMin = new Vector2(0f, 1f); // ���Ͻ�ê��
                rectTransform.anchorMax = new Vector2(0f, 1f); // ���Ͻ�ê��
                rectTransform.pivot = new Vector2(0f, 1f); // ���Ͻ�Ϊ���ĵ�
                rectTransform.anchoredPosition = Vector2.zero; // ���������Ͻ�
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
                Debug.LogWarning("δ�ҵ�Canvas");
            }
        }
    }

    private int frameCount = 0;
    private float deltaTime = 0.0f;
    private float updateRate = 0.5f; // ֡�ʸ���Ƶ�ʣ�����ÿ0.5�����һ��

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
