Unity iOS native plugin

iOS Load Texture From PhotoLibrary/Camera


---------------------------------------------------------------------------
Description: 
This plugin is run on iOS native code. You can use UIImagePicker for load a texture on Unity.

Features:
- Load Texture from PhotoLibrary on Device
- Take a photo by Camera
- Save Image to PhotoLibrary (JPG/PNG/PNG with transparency)
- Support for Unity 3.5.7/4.0/4.1/4.2/4.3


Demo Video:
http://youtu.be/HeL85WW0Y80


How to use (C# Script):

ShowCamera:
	LoadTextureFromImagePicker.ShowCamera(gameObject.name, "OnFinishedImagePicker");

Load Image from PhotoLibrary:
	LoadTextureFromImagePicker.ShowPhotoLibrary(gameObject.name, "OnFinishedImagePicker");

Callback function on finished, and get Image:
	private void OnFinishedImagePicker (string message) {
		Texture2D texture = LoadTextureFromImagePicker.GetLoadedTexture(message, 512, 512);
		if (texture) {
			Texture lastTexture = targetMaterial.mainTexture;
			targetMaterial.mainTexture = texture;
			Destroy(lastTexture);
		}
	}


Popover position setting for iPad:
	Center of screen
		LoadTextureFromImagePicker.SetPopoverToCenter();

	Set target Rect
		LoadTextureFromImagePicker.SetPopoverTargetRect(buttonPos.x, buttonPos.y, buttonWidth, buttonHeight);


Save Image to PhotoLibrary:
	LoadTextureFromImagePicker.SaveAsJpgToPhotoLibrary(image, gameObject.name, "OnFinishedSaveImage");
	LoadTextureFromImagePicker.SaveAsPngToPhotoLibrary(image, gameObject.name, "OnFinishedSaveImage");
	LoadTextureFromImagePicker.SaveAsPngWithTransparencyToPhotoLibrary(image, gameObject.name, "OnFinishedSaveImage");


If you have any question, send email to support: whitedev.support@gmail.com


---------------------------------------------------------------------------
Version Changes:
1.5.4:
	- Fixed problem that get size of image.
1.5.3:
	- Fixed rotation issue when using camera view.
1.5.2:
	- Fixed errors when the non-iOS platform.
1.5.1:
	- Fixed Landscape Camera problem on iPad & iOS7
	- Add New Sample Scene (Simple)

	**** To support Unity3 in this version is the last. ****
1.4:
	- Fixed Landscape Camera problem on iPad & iOS7
1.3:
	- Add create mipmap option
	- Include iOS source code
1.2:
	- Add "Save to PhotoLibrary" Function (JPG/PNG/PNG with transparency)
	- Fix memory leak
1.1:
	- Support for Unity 4.2
1.0.4:
	- Support for load image with original size
	- Support for no close menu on select image (only iPad)
	- Fixed conflict my plugins.
1.0.3:
	- Support for Unity 3.5.7/4.0/4.1 or Higher
1.0.2:
	- Fix Popover Positioning
1.0:
	- Initial version.
