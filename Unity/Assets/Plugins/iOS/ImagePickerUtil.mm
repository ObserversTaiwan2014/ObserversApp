
/*
	Check Unity Version
*/

#if (defined(UNITY_VERSION) == false)
	#import "AppController.h"
	#if defined(EVENT_PUMP_BASED_LOOP)
		#define UNITY_VERSION 0
	#else
		#define UNITY_VERSION 410		// Unity 4.1.0 or higher
	#endif
#endif

extern "C" uint ImagePicker_GetUnityVersion() {
	static uint UnityVersion_ = UNITY_VERSION;
#if UNITY_VERSION == 0
	if (UnityVersion_ == 0) {
		extern const char *UnityIPhoneRuntimeVersion;
		UnityVersion_ =
			((UnityIPhoneRuntimeVersion[0] - '0') * 100) +
			((UnityIPhoneRuntimeVersion[2] - '0') * 10) +
			((UnityIPhoneRuntimeVersion[4] - '0'));
	}
#endif
	return UnityVersion_;
}



/*
	Popover for iPad
*/

#if (UNITY_VERSION >= 410)
#import "DisplayManager.h"
#else
#import "iPhone_GlesSupport.h"
#endif
extern UIView* UnityGetGLView();

extern "C" bool ImagePicker_bPopoverAutoClose = false;
extern "C" bool ImagePicker_bPopoverCenter = true;
extern "C" CGRect ImagePicker_rectPopoverTarget = {0};

extern "C" bool ImagePicker_IsPopoverAutoClose() {
	return ImagePicker_bPopoverAutoClose;
}
extern "C" void ImagePicker_SetPopoverAutoClose(bool autoclose) {
	ImagePicker_bPopoverAutoClose = autoclose;
}

extern "C" void ImagePicker_SetPopoverToCenter() {
	ImagePicker_bPopoverCenter = true;
}

static float GetUnitySurfaceToUIViewScale() {
	float scale = 1.0f;
	float viewScale = UnityGetGLView().contentScaleFactor;
#if (UNITY_VERSION >= 410)
	const UnityRenderingSurface& unityRenderingSurface = [[DisplayManager Instance] mainDisplay]->surface;
	scale = ((float)unityRenderingSurface.systemW / viewScale) / (float)unityRenderingSurface.targetW;
#else
	if (ImagePicker_GetUnityVersion() >= 400) {
		struct UnityRenderingSurface__ {
			void *pVoid[4];
			GLuint pUint[7];
			unsigned systemW, systemH;
			unsigned targetW, targetH;
		} *pSurface = (UnityRenderingSurface__ *) &_surface;
		scale = ((float)pSurface->systemW / viewScale) / pSurface->targetW;
	} else {
		scale = 1.0f / viewScale;
	}
#endif
	return scale;
}
extern "C" void ImagePicker_SetPopoverTargetRect(float x, float y, float width, float height) {
	float scale = GetUnitySurfaceToUIViewScale();
	ImagePicker_rectPopoverTarget = CGRectMake(x*scale, y*scale, width*scale, height*scale);
	ImagePicker_bPopoverCenter = false;
}
