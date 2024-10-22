using UnityEngine;

namespace Chapter12
{
    [ExecuteInEditMode]
    [RequireComponent (typeof(Camera))]
    public class PostEffectBase : MonoBehaviour
    {
        protected void Start()
        {
            CheckResource();
        }

        protected void CheckResource()
        {
            bool isSupported = CheckSupport();
            if (!isSupported)
            {
                NotSupported();
            }
        }

        protected void NotSupported()
        {
            this.enabled = false;
        }

        protected bool CheckSupport()
        {
            //if(SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
            //{
            //    Debug.LogWarning("This Platform does not support image effect or render texture");
            //    return false;
            //}
            return true;
        }

        protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
        {
            if (shader == null)
            {
                return null;
            }
            if (shader.isSupported && material && material.shader == shader)
                return material;

            if (!shader.isSupported)
            {
                return null;
            }
            else
            {
                material = new Material(shader);
                material.hideFlags = HideFlags.DontSave;
                if (material)
                {
                    return material;
                }
                else
                {
                    return null;
                }}
        }
    }
}
