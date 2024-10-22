using System.Collections;
using System.Collections.Generic;
using Chapter12;
using UnityEngine;

[ImageEffectAllowedInSceneView]
public class MotionBlur_baseOnVelocity : PostEffectBase
{
    [SerializeField] Shader shader;
    private Material motionBlurMaterial = null;
    public Material material {
        get {
            motionBlurMaterial = CheckShaderAndCreateMaterial(shader, motionBlurMaterial);
            return motionBlurMaterial; 
        }
    }

    private Camera myCamera;
    public Camera Camera
    {
        get {
            if(myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera; 
        } 
    }


    [Range(0.0f, 1.0f)]
    [SerializeField] float BlurSize;

    private Matrix4x4 previousViewProjectionMatrix;
    private Matrix4x4 currentViewProjectionMatrix;

    private void OnEnable()
    {
        Camera.depthTextureMode |= DepthTextureMode.Depth;
        //VP矩阵
        previousViewProjectionMatrix = Camera.projectionMatrix * Camera.worldToCameraMatrix;
    }

    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material != null)
        {
            material.SetFloat("_BlurSize", BlurSize);

            //设置先前的VP矩阵
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            //更新当前VP矩阵
            currentViewProjectionMatrix = Camera.projectionMatrix * Camera.worldToCameraMatrix;
            //设置当前VP矩阵的逆矩阵
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionMatrix.inverse);
            //更新先前矩阵
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
