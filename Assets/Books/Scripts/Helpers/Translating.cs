using UnityEngine;
using System.Collections;

public class Translating : MonoBehaviour {

	public float speed = 10.0f;
	public Vector3 startPoint = Vector3.zero;
	public Vector3 endPoint = Vector3.zero;
	public Vector3 lookAt = Vector3.zero;
	public bool pingpong = true;

    private float Distance;

    private Vector3 curEndPoint = Vector3.zero;

	public bool isMouseControll;

	void Start () {

		transform.position = startPoint;
		curEndPoint = endPoint;

		//Distance = Vector3.Distance(transform.position, lookAt);
		Distance = 1;
    }

    public float rotationSpeed = 200.0f;
    private float minDistance = 0.1f;
    private float maxDistance = 500f;

    private void Update()
    {
        float mouseSW = Input.GetAxis("Mouse ScrollWheel");

        if (mouseSW != 0)
        {
            // 在鼠标滚轮滚动时，修改距离（可以用于缩放）
            float distanceChange = mouseSW * Time.deltaTime * 300;
            float newDistance = Mathf.Clamp(transform.position.z + distanceChange, minDistance, maxDistance); // 可以添加最小和最大距离的限制
            transform.position = new Vector3(transform.position.x, transform.position.y, newDistance);
        }

        if (isMouseControll)
        {
            float Xinput = Input.GetAxis("Mouse X");
            float Yinput = Input.GetAxis("Mouse Y");

            if(Input.GetKey(KeyCode.A))
            {
                Xinput = -1;
            }
            else if(Input.GetKey(KeyCode.D))
            {
                Xinput = 1;
            }

            if (Input.GetKey(KeyCode.W))
            {
                Yinput = -1;
            }
            else if (Input.GetKey(KeyCode.S))
            {
                Yinput = 1;
            }

            // 计算旋转角度
            float rotationX = Xinput * rotationSpeed * Time.deltaTime;
            float rotationY = Yinput * rotationSpeed * Time.deltaTime;

            // 使用Quaternion.Euler创建旋转
            Quaternion rotation = Quaternion.Euler(rotationY, rotationX, 0);

            // 将旋转应用到对象，围绕指定的旋转中心点
            transform.RotateAround(lookAt, Vector3.up, rotationX);
            transform.RotateAround(lookAt, transform.right, -rotationY);

            // 保持对象始终面向中心点
            transform.LookAt(lookAt);
        }
        else
        {
            transform.position = Vector3.Slerp(transform.position * Distance, curEndPoint * Distance, Time.deltaTime * speed);
            transform.LookAt(lookAt);
            if (pingpong)
            {
                if (Vector3.Distance(transform.position, curEndPoint) < 0.001f)
                {
                    curEndPoint = Vector3.Distance(curEndPoint, endPoint) < Vector3.Distance(curEndPoint, startPoint) ? startPoint : endPoint;
                }
            }
        }
	}
}
