using System;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEngine;

public class ShaderEditor
{
    [OnOpenAssetAttribute(1)]
    public static bool step1(int instanceID, int line)
    {
        string path = AssetDatabase.GetAssetPath(EditorUtility.InstanceIDToObject(instanceID));
        string name = Application.dataPath + "/" + path.Replace("Assets/", "");
        if (name.EndsWith(".shader"))    //文件扩展名类型
        {
            System.Diagnostics.Process process = new System.Diagnostics.Process();
            System.Diagnostics.ProcessStartInfo startInfo = new System.Diagnostics.ProcessStartInfo();
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            startInfo.FileName = "E:/Microsoft VS Code/Code.exe";   //VSCODE程序
            startInfo.Arguments = name;
            process.StartInfo = startInfo;
            process.Start(); 
            return true;
        }

        return false; 
    }
}
