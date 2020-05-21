using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

public class T4MShaderUtil
{
    public static Shader Find(string path)
    {
        if (IsURP())
        {
            path = path.Replace("T4MShaders/", "T4MShaders_URP/");
        }

        return Shader.Find(path);
    }


    public static bool IsURP()
    {
        return Shader.globalRenderPipeline == "UniversalPipeline";
    }
}
