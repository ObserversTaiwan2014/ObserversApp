using UnityEngine;
using System.Collections;
using ElicitIce;
#if UNITY_ANDROID

public class OAImagePicker : ImagePicker {
	// public ElicitIce.ImagePickerExample2 android;
	public UITexture nguiTex;

	public override void ImagePickerCallback(string result) {
        base.ImagePickerCallback(result);
        nguiTex.mainTexture = data.loadImage;
        Debug.Log(result);
    }
	ImagePickerData data = null;
	void OnClick(){
		data.bestFit = true;
        data.showCamera = true;
        data.useDefault = false;
        data.fileSubDir = "xxd";
        data.maxWidth = 512;
        data.maxHeight = 512;
		StartImagePicker(data);
	}
	void Awake(){
		data = new ImagePickerData();
            {
                data.loadImage = null;
                data.fileName = null;
                data.gameObject = gameObject.name;
                data.callback = ImagePickerCallback;
            }
	}
}
#else 
// public class OAImagePicker : MonoBehaviour {}

#endif