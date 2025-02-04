using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour
{
    public Material material = null;
    private Texture2D m_generatedTexture;

    #region Material properties
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;
    public int textureWidth {
        get => m_textureWidth;
        set { 
            m_textureWidth = value;
            _UpdateMaterial(); 
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;
    public Color backgroundColor
    {
        get => m_backgroundColor;
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.white;
    public Color circleColor
    {
        get => m_circleColor;
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2f;
    public float blurFactor
    {
        get => m_blurFactor;
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }

    #endregion

    private void Start()
    {
        if(material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if(renderer != null)
            {
                Debug.LogWarning("Cannot find a renderer");
                return;
            }
            Debug.Log("find a renderer");
            material = renderer.sharedMaterial;
        }
        else
        {
            Debug.Log("already exists a toonShadingMaterial");
        }
        
        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if(material != null)
        {
            m_generatedTexture = _GeneratedProceduralTexture();
            material.SetTexture("_MainTex", m_generatedTexture);
        }
    }

    private Color _MixColor(Color color0, Color color1, float mixFactor)
    {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        return mixColor;
    }

    private Texture2D _GeneratedProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

        float circleInterval = textureWidth / 4.0f;
        float radius = textureWidth / 10.0f;
        float edgeBlur = 1.0f / blurFactor;
        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;
                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2((i + 1) * circleInterval, (j + 1) * circleInterval);
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0f), Mathf.SmoothStep(0f, 1f, dist * edgeBlur));
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                proceduralTexture.SetPixel(w, h, pixel);
            }
        }
        proceduralTexture.Apply();
        Debug.Log("Generate Texture Successfully");
        return proceduralTexture;
    }
}
