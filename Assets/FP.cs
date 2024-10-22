using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using static UnityEngine.GraphicsBuffer;

public class FP : MonoBehaviour
{
    private Transform cameraTrans;

    [SerializeField] private float minPitch = -80f; // ����Inspector�е���
    [SerializeField] private float maxPitch = 80f;   // ����Inspector�е���
    private float rotationX = 0f;
    public float sensitivity = 5f;

    private void Awake()
    {
        cameraTrans = GetComponent<Transform>();
        Application.targetFrameRate = 60;
    }

    float xMouse;
    float yMouse;

    void Update()
    {
        xMouse = Input.GetAxis("Mouse X") * sensitivity;
        yMouse = Input.GetAxis("Mouse Y") * sensitivity;

        rotationX -= yMouse;
        rotationX = Mathf.Clamp(rotationX, -80f, 80f);

        cameraTrans.localRotation = Quaternion.Euler(rotationX, cameraTrans.localEulerAngles.y, 0);

        cameraTrans.Rotate(Vector3.up * xMouse);

        print(cameraTrans.localRotation);
    }
}
