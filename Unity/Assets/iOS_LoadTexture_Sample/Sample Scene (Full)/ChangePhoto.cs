using UnityEngine;
using System.Collections;

public class ChangePhoto : MonoBehaviour {
	
	public Material targetMaterial = null;
	public bool bUseOriginalImageSize = false;
	public bool iPadPopover_CloseWhenSelectImage = false;

	private int textureWidth = 512;
	private int textureHeight = 512;
	private bool saveAsPng = false;

	private string lastMessage = "";

	void Start () {
		if (targetMaterial == null) {
			targetMaterial = GameObject.Find("Cube").renderer.material;
		}
		if (targetMaterial) {
			textureWidth = targetMaterial.mainTexture.width;
			textureHeight = targetMaterial.mainTexture.height;
		}
	}

	void Update () {
	}

	void OnGUI () {
		// Swithes
		GUI.Label(new Rect(0,Screen.height*0.5f, 100,30), "Options:");
		bUseOriginalImageSize = GUI.Toggle(new Rect(0, Screen.height*0.5f+30, 400, 30), bUseOriginalImageSize, "UseOriginalImageSize");
		iPadPopover_CloseWhenSelectImage = GUI.Toggle(new Rect(0, Screen.height*0.5f+60, 400, 30), iPadPopover_CloseWhenSelectImage, "iPadPopover_CloseWhenSelectImage");

		// Buttons
		float buttonWidth = Screen.width/3;
		float buttonHeight = Screen.height/5;
		float buttonMargine = buttonWidth/3;
		Rect buttonRect = new Rect(0, Screen.height-buttonHeight, buttonWidth, buttonHeight);
		buttonRect.x = buttonMargine;
		if (targetMaterial == null) {
			GUI.Box(buttonRect, "(Set Target Material)");
		} else if (GUI.Button(buttonRect, "Camera\n(iOS ONLY)")) {
			#if UNITY_IPHONE
				if (Application.platform == RuntimePlatform.IPhonePlayer) {
					LoadTextureFromImagePicker.SetPopoverToCenter();
					LoadTextureFromImagePicker.ShowCamera(gameObject.name, "OnFinishedImagePicker");
				}
			#endif
		}
		buttonRect.x = buttonMargine + buttonWidth + buttonMargine;
		if (targetMaterial == null) {
			GUI.Box(buttonRect, "(Set Target Material)");
		} else if (GUI.Button(buttonRect, "Load Image\nfrom PhotoLibrary\n(iOS ONLY)")) {
			#if UNITY_IPHONE
				if (Application.platform == RuntimePlatform.IPhonePlayer) {
					LoadTextureFromImagePicker.SetPopoverAutoClose(iPadPopover_CloseWhenSelectImage);
					LoadTextureFromImagePicker.SetPopoverTargetRect(buttonRect.x, buttonRect.y, buttonWidth, buttonHeight);
					LoadTextureFromImagePicker.ShowPhotoLibrary(gameObject.name, "OnFinishedImagePicker");
				}
			#endif
		}
		//
		// for Save Image
		buttonRect.width = Screen.width/4;
		buttonRect.height = Screen.height/6;
		buttonMargine = 0;
		buttonRect.y = 0;
		buttonRect.x = buttonMargine + (buttonRect.width + buttonMargine) * 1;
		if (GUI.Button(buttonRect, "Save JPG\nto PhotoLibrary\n(iOS ONLY)")) {
			#if UNITY_IPHONE
				if (Application.platform == RuntimePlatform.IPhonePlayer) {
					saveAsPng = false;
					StartCoroutine("CaptureScreen");
				}
			#endif
		}
		buttonRect.x = buttonMargine + (buttonRect.width + buttonMargine) * 2;
		if (GUI.Button(buttonRect, "Save PNG\nto PhotoLibrary\n(iOS ONLY)")) {
			#if UNITY_IPHONE
				if (Application.platform == RuntimePlatform.IPhonePlayer) {
					saveAsPng = true;
					StartCoroutine("CaptureScreen");
				}
			#endif
		}

		// Disp Texture Size
		if (targetMaterial) {
			Texture targetTexture = targetMaterial.mainTexture;
			GUI.Label(new Rect(0,0, 400,100), "Current Texture Size:\n"+"width="+targetTexture.width+", height="+targetTexture.height);
		}

		// Disp Last Message
		GUI.Label(new Rect(0,80, 200,60), "Last Result:\n"+lastMessage);
	}

	#if UNITY_IPHONE
	// For Load
	private void OnFinishedImagePicker (string message) {
		lastMessage = message;
		if (targetMaterial && LoadTextureFromImagePicker.IsLoaded()) {
			int width, height;
			if (bUseOriginalImageSize) {
				width = LoadTextureFromImagePicker.GetLoadedTextureWidth();
				height = LoadTextureFromImagePicker.GetLoadedTextureHeight();
			} else {
				width = textureWidth;
				height = textureHeight;
			}
			bool mipmap = true;
			Texture2D texture = LoadTextureFromImagePicker.GetLoadedTexture(message, width, height, mipmap);
			if (texture) {
				// Load Texture
				Texture lastTexture = targetMaterial.mainTexture;
				targetMaterial.mainTexture = texture;
				Destroy(lastTexture);
			}
			LoadTextureFromImagePicker.ReleaseLoadedImage();
		} else {
			// Closed
			LoadTextureFromImagePicker.Release();
		}
	}

	// For Save
	private IEnumerator CaptureScreen() {
		yield return new WaitForEndOfFrame();

		// Save to PhotoLibrary
		Texture2D screenShot = ScreenCapture.Capture();
		if (saveAsPng) {
			bool withTransparency = false;
			if (withTransparency) {
				// PNG with transparency
				LoadTextureFromImagePicker.SaveAsPngWithTransparencyToPhotoLibrary(screenShot, gameObject.name, "OnFinishedSaveImage");
			} else {
				// PNG
				LoadTextureFromImagePicker.SaveAsPngToPhotoLibrary(screenShot, gameObject.name, "OnFinishedSaveImage");
			}
		} else {
			// JPG
			LoadTextureFromImagePicker.SaveAsJpgToPhotoLibrary(screenShot, gameObject.name, "OnFinishedSaveImage");
		}
	}

	private void OnFinishedSaveImage (string message) {
		lastMessage = message;
		if (message.Equals(LoadTextureFromImagePicker.strCallbackResultMessage_Saved)) {
			// Save Succeed
		} else {
			// Failed
		}
	}
	#endif
}
