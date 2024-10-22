using System.Collections;
using System.Collections.Generic;
using Chapter12;
using UnityEngine;

[ImageEffectAllowedInSceneView]
public class GlobalFog : PostEffectBase
{
    [SerializeField] Shader shader;
    private Material globalMaterial = null;
    public Material material
    {
        get
        {
            globalMaterial = CheckShaderAndCreateMaterial(shader, globalMaterial);
            return globalMaterial;
        }
    }

    private Camera myCamera;
    public Camera Camera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    private Transform myCameraTransform;
    public Transform cameraTransform
    {
        get
        {
            if (myCameraTransform == null)
            {
                myCameraTransform = Camera.transform;
            }

            return myCameraTransform;
        }
    }

    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;


    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            float FOV = Camera.fieldOfView;
            float near = Camera.nearClipPlane;
            float aspect = Camera.aspect;

            float halfHeight = Mathf.Tan(FOV * 0.5f * Mathf.Deg2Rad) * near;

            Vector3 toTop = cameraTransform.up * halfHeight;
            Vector3 toRight = cameraTransform.right * halfHeight * aspect;

            Vector3 toTopLeft = cameraTransform.forward * near - toRight + toTop;
            Vector3 toTopRight = cameraTransform.forward * near + toRight + toTop;
            Vector3 toBottomRight = cameraTransform.forward * near + toRight - toTop;
            Vector3 toBottomLeft = cameraTransform.forward * near - toRight - toTop;

            float scale = 1 / near;

            toTopLeft *= scale;
            toTopRight *= scale;
            toBottomRight *= scale;
            toBottomLeft *= scale;

            Matrix4x4 frustumCorners = Matrix4x4.identity;
            frustumCorners.SetRow(0, toBottomLeft);
            frustumCorners.SetRow(1, toBottomRight);
            frustumCorners.SetRow(2, toTopLeft);
            frustumCorners.SetRow(3, toTopRight);

            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetMatrix("_FrustumCornersRay", frustumCorners);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
