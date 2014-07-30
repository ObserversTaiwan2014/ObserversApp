using UnityEngine;
using System.Collections;

public class OAVcCamera : MonoBehaviour {
	public UITexture nguiWebCam;
	public WebCamTexture webcamTexture;
	public void onTakePicture(){
		webcamTexture.GetPixels32(data);
	}
	Color32[] data;

	void Start(){
		var tex=new WebCamTexture(640,1010);
		Debug.Log(WebCamTexture.devices[0]);
		tex.Play();
		nguiWebCam.mainTexture=tex;
		webcamTexture=tex;
		data=new Color32[webcamTexture.width * webcamTexture.height];
	}
}
