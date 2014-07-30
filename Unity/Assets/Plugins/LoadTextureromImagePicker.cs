using UnityEngine;
using System.Runtime.InteropServices;
using System.Collections;

#if UNITY_IPHONE
public class LoadTextureFromImagePicker {

	private const string strSourceType_PhotoLibrary = "PhotoLibrary";	// Default
	private const string strSourceType_Camera = "Camera";
	private const string strSourceType_SavedPhotosAlbum = "SavedPhotosAlbum";


	// Interface
	public static bool ShowPhotoLibrary (string callbackGameObjectName, string callbackMethodName) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return ImagePicker_showPicker(strSourceType_PhotoLibrary, callbackGameObjectName, callbackMethodName);
		}
		return false;
	}

	public static bool ShowCamera (string callbackGameObjectName, string callbackMethodName) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return ImagePicker_showPicker(strSourceType_Camera, callbackGameObjectName, callbackMethodName);
		}
		return false;
	}

	public static void Release () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ImagePicker_release();
		}
	}
	public static void ReleaseLoadedImage () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ImagePicker_releaseLoadedImage();
		}
	}


	public static bool IsLoaded () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return ImagePicker_isLoaded();
		}
		return false;
	}
	public static int GetLoadedTextureWidth () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return ImagePicker_getLoadedTexrureWidth();
		}
		return 0;
	}
	public static int GetLoadedTextureHeight () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			return ImagePicker_getLoadedTexrureHeight();
		}
		return 0;
	}

	public static Texture2D GetLoadedTexture (string message, int width, int height) {
		return _GetLoadedTexture(message, width, height, /*mipmap=*/true, /*linear=*/false);
	}
	public static Texture2D GetLoadedTexture (string message, int width, int height, bool mipmap) {
		return _GetLoadedTexture(message, width, height, mipmap, /*linear=*/false);
	}
	public static Texture2D GetLoadedTexture (string message, int width, int height, bool mipmap, bool linear) {
		return _GetLoadedTexture(message, width, height, mipmap, linear);
	}


	// Save to PhotoLibrary
	public static void SaveAsJpgToPhotoLibrary (Texture image, string callbackGameObjectName, string callbackMethodName) {
		if (image != null) {
			Texture2D tex = (Texture2D)image;
			Lib_SaveToPhotoLibrary(tex.GetPixels32(), tex.width, tex.height, callbackGameObjectName, callbackMethodName, /*asPng=*/false, /*withTransparency=*/false);
		}
	}
	public static void SaveAsPngToPhotoLibrary (Texture image, string callbackGameObjectName, string callbackMethodName) {
		if (image != null) {
			Texture2D tex = (Texture2D)image;
			Lib_SaveToPhotoLibrary(tex.GetPixels32(), tex.width, tex.height, callbackGameObjectName, callbackMethodName, /*asPng=*/true, /*withTransparency=*/false);
		}
	}
	public static void SaveAsPngWithTransparencyToPhotoLibrary (Texture image, string callbackGameObjectName, string callbackMethodName) {
		if (image != null) {
			Texture2D tex = (Texture2D)image;
			Lib_SaveToPhotoLibrary(tex.GetPixels32(), tex.width, tex.height, callbackGameObjectName, callbackMethodName, /*asPng=*/true, /*withTransparency=*/true);
		}
	}
	

	// (Popover Auto Close for iPad)
	public static void SetPopoverAutoClose (bool autoclose) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ImagePicker_SetPopoverAutoClose(autoclose);
		}
	}

	// (Position of Popover for iPad)
	public static void SetPopoverToCenter () {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ImagePicker_SetPopoverToCenter();
		}
	}
	public static void SetPopoverTargetRect (float x, float y, float width, float height) {
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			ImagePicker_SetPopoverTargetRect(x, y, width, height);
		}
	}



	
	// Implementation
	[DllImport ("__Internal")] private static extern bool ImagePicker_showPicker(string sourceType, string callbackGameObjectName, string callbackMethodName);
	[DllImport ("__Internal")] private static extern bool ImagePicker_isLoaded();
	[DllImport ("__Internal")] private static extern int ImagePicker_getLoadedTexrureWidth();
	[DllImport ("__Internal")] private static extern int ImagePicker_getLoadedTexrureHeight();
	[DllImport ("__Internal")] private static extern bool ImagePicker_getLoadedTexrure(Color32[] pixelBuffer, int width, int height);
	[DllImport ("__Internal")] private static extern void ImagePicker_releaseLoadedImage();
	[DllImport ("__Internal")] private static extern void ImagePicker_release();
	//
	[DllImport ("__Internal")] private static extern bool ImagePicker_IsPopoverAutoClose();
	[DllImport ("__Internal")] private static extern void ImagePicker_SetPopoverAutoClose(bool autoclose);
	[DllImport ("__Internal")] private static extern void ImagePicker_SetPopoverToCenter();
	[DllImport ("__Internal")] private static extern void ImagePicker_SetPopoverTargetRect(float x, float y, float width, float height);
	//
	[DllImport ("__Internal")] private static extern void Lib_SaveToPhotoLibrary(Color32[] pixelBuffer, int width, int height, string callbackGameObjectName, string callbackMethodName, bool asPng, bool withTransparency);

	public const string strCallbackResultMessage_Loaded = "Result: Loaded";
	//public  const string strCallbackResultMessage_Canceled = "Result: Canceled";
	public const string strCallbackResultMessage_Saved = "Result: Saved";
	//public  const string strCallbackResultMessage_SaveFailed = "Result: SaveFailed";

	public static Texture2D _GetLoadedTexture(string message, int width, int height, bool mipmap, bool linear) {
		Texture2D texture = null;
		if (Application.platform == RuntimePlatform.IPhonePlayer) {
			if (message.Equals(strCallbackResultMessage_Loaded)) {
				if (width <= 0) width = 16;
				if (height <= 0) height = 16;
				int pixelCount = (width * height);
				Color32[] pixelData = new Color32[pixelCount];
				if (ImagePicker_getLoadedTexrure(pixelData, width, height)) {
					texture = new Texture2D(width, height, TextureFormat.ARGB32, mipmap, linear);
					texture.SetPixels32(pixelData);
					texture.Apply(mipmap);
				}
				pixelData = null;
			}
		}
		return texture;
	}
}
#endif
