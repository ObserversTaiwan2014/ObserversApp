//
//  ImagePickerLib.mm
//  ImagePickerLib
//
//  Created by ONODA on 13/05/23.
//  Copyright (c) 2013 WhiteDev All rights reserved.
//

#import "ImagePickerLib.h"


extern UIViewController *UnityGetGLViewController(); // Root view controller of Unity screen.
extern UIView *UnityGetGLView();
extern "C" void UnitySendMessage(const char* obj, const char* method, const char* msg);

typedef struct {
	unsigned char r, g, b, a;
} Color32;

extern "C" bool ImagePicker_bPopoverAutoClose;
extern "C" bool ImagePicker_bPopoverCenter;
extern "C" CGRect ImagePicker_rectPopoverTarget;


//
static const char *strSourceType_PhotoLibrary = "PhotoLibrary";	// Default
static const char *strSourceType_Camera = "Camera";
static const char *strSourceType_SavedPhotosAlbum = "SavedPhotosAlbum";

static const char *strCallbackResultMessage_Loaded = "Result: Loaded";
static const char *strCallbackResultMessage_Canceled = "Result: Canceled";
static const char *strCallbackResultMessage_Saved = "Result: Saved";
static const char *strCallbackResultMessage_SaveFailed = "Result: SaveFailed";

static UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

//

static uint iOSVersion = 0;

static struct {
	char strGameObjectName[256];
	char strMethodName[256];
} callbackLoadedInfo = {0},
callbackSavedInfo = {0};

//
static void ImagePicker_callbackLoadFinished(bool loaded);
static void ImagePicker_callbackSaveFinished(bool saved);




@interface ImagePickerLib (Private)
+ (ImagePickerLib *) instance;

- (bool) usePopover;
- (bool) showImagePicker:(const char *)sourceTypeText;
- (bool) getLoadedTexrure:(Color32 *)pixelBuffer width:(int)width height:(int)height;

- (void) releaseImage;
- (void) releasePicker;
- (void) smartDismiss;

- (void) releaseSaveTmp;
- (void) saveToPhotoLibrary:(Color32 *)pixelBuffer width:(int)width height:(int)height asPng:(BOOL)asPng withTransparency:(BOOL)withTransparency;
- (void) saveFinished:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@implementation ImagePickerLib

static UIImagePickerController* imagePicker = nil;
static UIPopoverController *popoverPicker = nil;
static UIImage *loadedImage = nil;
static CGSize imageSize = CGSizeZero;

static Color32 *s_pixelData = NULL;
static UIImage *savingImage = nil;

static BOOL biPad = NO;

static ImagePickerLib *pInstance = nil;

+ (ImagePickerLib *) instance {
	iOSVersion = (uint)([[[UIDevice currentDevice] systemVersion] floatValue] * 100.0f);

	if (pInstance == nil) {
		pInstance = [[ImagePickerLib alloc] init];

		biPad = NO;
		{
			#define UI_USER_INTERFACE_IDIOM() \
			   ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
			   [[UIDevice currentDevice] userInterfaceIdiom] : \
			   UIUserInterfaceIdiomPhone)
   			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
				biPad = YES;
			}
		}
	}
	return pInstance;
}

- (void) releaseImage {
	if (loadedImage) {
		[loadedImage release];
		loadedImage = nil;
	}
	imageSize = CGSizeZero;
}
- (void) releasePicker {
	if (popoverPicker) {
		popoverPicker.delegate = nil;
		[popoverPicker release];
		popoverPicker = nil;
	}
	if (imagePicker) {
		imagePicker.delegate = nil;
		[imagePicker release];
		imagePicker = nil;
	}

}

- (void)dealloc {

	[self releaseImage];
	[self releasePicker];

	[super dealloc];

	pInstance = nil;
}

- (bool) getLoadedTexrure:(Color32 *)pixelBuffer width:(int)width height:(int)height {

	assert(pixelBuffer);
	if (pixelBuffer) {
		if (loadedImage) {
			/* NG
			width = MIN(MAX(width, 64), 2048);
			height = MIN(MAX(height, 64), 2048);
			*/

#if 1
			// Resize
			UIGraphicsBeginImageContext(CGSizeMake(width, height));
			CGRect drawRect = CGRectMake(0, 0, width, height);
			[loadedImage drawInRect:drawRect];
			UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
			//int newImageWidth = (int)newImage.size.width;
			int newImageHeight = (int)newImage.size.height;
			UIGraphicsEndImageContext();

			// Pixel Data
			CGDataProviderRef dataProvider = CGImageGetDataProvider(newImage.CGImage);
			NSData *data = (NSData *) CFBridgingRelease(CGDataProviderCopyData(dataProvider));
			if (data) {
				//assert([data length] == (width*height*4));
				assert([data length] >= (width*height*4));
#if 0
//				memcpy(pixelBuffer, [data bytes], bufferSize);
#else
				int newImagePitch = [data length] / newImageHeight / 4;
				const Color32 *pSrcBase = (const Color32 *)[data bytes];
				for (int y=0; y<height; ++y) {
					const Color32 *pSrc = &pSrcBase[newImagePitch*y];
					Color32 *pDst = &pixelBuffer[width*((height-1)-y)];
					for (int x=0; x<width; ++x) {
						pDst->r = pSrc->b;
						pDst->g = pSrc->g;
						pDst->b = pSrc->r;
						pDst->a = pSrc->a;
						++pSrc;
						++pDst;
					}
				}
#endif
			}
#else
//			CGImageRef image = [loadedImage CGImage];
//			if (image) {
//				//CGImageAlphaInfo info = CGImageGetAlphaInfo(image);
//				//bool hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
//			
//				//int imageWidth = CGImageGetWidth(image);
//				//int imageHeight = CGImageGetHeight(image);
//
//				CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//				CGContextRef context = CGBitmapContextCreate(pixelBuffer, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//				CGColorSpaceRelease(colorSpace);
//				//CGContextClearRect(context, CGRectMake(0, 0, width, height));
//				//CGContextTranslateCTM(context, 0, height-imageHeight);
//				CGContextTranslateCTM(context, 0, height);
//				CGContextScaleCTM(context, 1.0f, -1.0f);
//				CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
//				CGContextRelease(context);
//			}
#endif

			return true;
		}
	}
	return false;
}


// PhotoLibrary
- (bool) usePopover
{
	return (biPad && ((iOSVersion < 700) || (sourceType != UIImagePickerControllerSourceTypeCamera)));
}

- (bool) showImagePicker:(const char *)sourceTypeText
{
	[self smartDismiss];
	[self releaseImage];
	[self releasePicker];

	sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	if (strcmp(sourceTypeText, strSourceType_PhotoLibrary) == 0) {
		sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	} else if (strcmp(sourceTypeText, strSourceType_Camera) == 0) {
		sourceType = UIImagePickerControllerSourceTypeCamera;
	} else if (strcmp(sourceTypeText, strSourceType_SavedPhotosAlbum) == 0) {
		sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	}
	if ([UIImagePickerController isSourceTypeAvailable:sourceType] == false) {
		ImagePicker_callbackLoadFinished(/*loaded=*/false);
		return false;
	}

	imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType = sourceType;
	imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
	imagePicker.allowsEditing = NO;
	imagePicker.delegate = self;

	// Present ImagePicker
	if ([self usePopover] == false) {
		[UnityGetGLViewController() presentViewController:imagePicker animated:YES completion:^ {
			}
		];
	} else {
		popoverPicker = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		popoverPicker.delegate = self;

		UIView *parentView = UnityGetGLViewController().view;
		UIPopoverArrowDirection arrow = 0;
		CGRect rect = imagePicker.view.bounds;
		if (ImagePicker_bPopoverCenter) {
			rect.origin.x = (parentView.bounds.size.width - rect.size.width) * 0.5f;
			rect.origin.y = (parentView.bounds.size.height - rect.size.height) * 0.5f;
			arrow = 0;
		} else {
			rect = ImagePicker_rectPopoverTarget;
			arrow = UIPopoverArrowDirectionAny;
		}
		[popoverPicker presentPopoverFromRect:rect inView:parentView permittedArrowDirections:arrow animated:YES];
	}

	return true;
}

- (void) smartDismiss {
	if ((popoverPicker == nil) || ([self usePopover] == false)) {
		[UnityGetGLViewController() dismissViewControllerAnimated:YES completion:^ {
			}
		];
	} else {
		if (popoverPicker) {
			[popoverPicker dismissPopoverAnimated:YES];
		}
		[self releasePicker];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self releaseImage];
	loadedImage = [info objectForKey:UIImagePickerControllerEditedImage];
	if (loadedImage == nil) {
		loadedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	}
	if (loadedImage) {
		[loadedImage retain];

		// GetSize
		CGImageRef imageRef = loadedImage.CGImage;
		imageSize.width = CGImageGetWidth(imageRef);
		imageSize.height = CGImageGetHeight(imageRef);
	} else {
		imageSize = CGSizeZero;
	}
	ImagePicker_callbackLoadFinished(/*loaded=*/true);
	if ((biPad == false) || (ImagePicker_bPopoverAutoClose || (sourceType == UIImagePickerControllerSourceTypeCamera))) {
		[self smartDismiss];
		ImagePicker_callbackLoadFinished(/*loaded=*/false);
	}
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[self smartDismiss];
	ImagePicker_callbackLoadFinished(/*loaded=*/false);
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	[self smartDismiss];
	ImagePicker_callbackLoadFinished(/*loaded=*/false);
}


// Save to PhotoLibrary
- (void) releaseSaveTmp {
	if (s_pixelData) {
		delete[] s_pixelData;
		s_pixelData = NULL;
	}
	if (savingImage) {
		[savingImage release];
		savingImage = nil;
	}
}

- (void) saveToPhotoLibrary:(Color32 *)pixelBuffer width:(int)width height:(int)height asPng:(BOOL)asPng withTransparency:(BOOL)withTransparency {
	[self releaseSaveTmp];

	while (pixelBuffer && (width > 0) && (height > 0)) {
		// Copy
		s_pixelData = new Color32[width*height];
		if (s_pixelData == false) break;	// Failed
		const Color32 *pSrc = (const Color32 *)pixelBuffer;
		for (int y=0; y<height; ++y) {
			Color32 *pDst = &s_pixelData[width*((height-1)-y)];
			memcpy(pDst, pSrc, width*sizeof(Color32));
			pSrc += width;
		}
	
		// Create UIImage
		CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, s_pixelData, width*height*4, NULL);
		CGImageRef imageRef = CGImageCreate(
			width, height, 8, 32, width*4,
			CGColorSpaceCreateDeviceRGB(),
			(withTransparency) ? (kCGBitmapByteOrderDefault|kCGImageAlphaLast) : kCGBitmapByteOrderDefault,
			dataProviderRef,
			NULL, FALSE, kCGRenderingIntentDefault);

		if (asPng) {
			// as PNG
			savingImage = [UIImage imageWithCGImage:imageRef];
			NSData *pngData = UIImagePNGRepresentation(savingImage);
			savingImage = [[UIImage imageWithData:pngData] retain];
		} else {
			// as JPG
			savingImage = [[UIImage imageWithCGImage:imageRef] retain];
		}

		CGDataProviderRelease(dataProviderRef);
		CGImageRelease(imageRef);

		UIImageWriteToSavedPhotosAlbum(savingImage, self, @selector(saveFinished:didFinishSavingWithError:contextInfo:), NULL);

		return;
		break;
	}

	// Failed
	ImagePicker_callbackSaveFinished(/*saved=*/false);
	[self releaseSaveTmp];
}

- (void) saveFinished:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[self releaseSaveTmp];
	if (error == nil) {
		// 成功
		ImagePicker_callbackSaveFinished(/*saved=*/true);
	} else {
		// 失敗
		ImagePicker_callbackSaveFinished(/*saved=*/false);
	}
}

@end



//#pragma mark - Auto Rotation
// Auto Rotation
//@implementation UIImagePickerController (AutoRotation)
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//	return [UnityGetGLViewController() shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//}
//- (NSUInteger) supportedInterfaceOrientations {
//	return [UnityGetGLViewController() supportedInterfaceOrientations];
//}
//- (BOOL) shouldAutorotate {
//	return [UnityGetGLViewController() shouldAutorotate];
//}
//- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
//	return [UnityGetGLViewController() preferredInterfaceOrientationForPresentation];
//}
//@end



// Interface
extern "C" bool ImagePicker_showPicker(const char *sourceType, const char *callbackGameObjectName, const char *callbackMethodName) {
	strncpy(callbackLoadedInfo.strGameObjectName, callbackGameObjectName, sizeof(callbackLoadedInfo.strGameObjectName));
	strncpy(callbackLoadedInfo.strMethodName, callbackMethodName, sizeof(callbackLoadedInfo.strMethodName));
	return [[ImagePickerLib instance] showImagePicker:sourceType];
}

extern "C" bool ImagePicker_isLoaded() {
	return (loadedImage);
}
extern "C" int ImagePicker_getLoadedTexrureWidth() {
	if (ImagePicker_isLoaded()) {
		return imageSize.width;
	}
	return 0;
}
extern "C" int ImagePicker_getLoadedTexrureHeight() {
	if (ImagePicker_isLoaded()) {
		return imageSize.height;
	}
	return 0;
}
extern "C" bool ImagePicker_getLoadedTexrure(Color32 *pixelBuffer, int width, int height) {
	return [[ImagePickerLib instance] getLoadedTexrure:pixelBuffer width:width height:height];
}

extern "C" void ImagePicker_release() {
	[[ImagePickerLib instance] release];
}
extern "C" void ImagePicker_releaseLoadedImage() {
	[[ImagePickerLib instance] releaseImage];
}


extern "C" void Lib_SaveToPhotoLibrary(Color32 *pixelBuffer, int width, int height, const char *callbackGameObjectName, const char *callbackMethodName, bool asPng, bool withTransparency) {
	strncpy(callbackSavedInfo.strGameObjectName, callbackGameObjectName, sizeof(callbackSavedInfo.strGameObjectName));
	strncpy(callbackSavedInfo.strMethodName, callbackMethodName, sizeof(callbackSavedInfo.strMethodName));
	[[ImagePickerLib instance] saveToPhotoLibrary:pixelBuffer width:width height:height asPng:asPng withTransparency:withTransparency];
}


static char *strCopy(const char *str) {
	assert(str);
	char *copyStr = (char *)malloc(strlen(str)+1);
	assert(copyStr);
	strcpy(copyStr, str);
	return copyStr;
}
static void ImagePicker_callbackLoadFinished(bool loaded) {
	const char *msg = (loaded) ? strCallbackResultMessage_Loaded : strCallbackResultMessage_Canceled;
	UnitySendMessage(strCopy(callbackLoadedInfo.strGameObjectName), strCopy(callbackLoadedInfo.strMethodName), strCopy(msg));
}
static void ImagePicker_callbackSaveFinished(bool saved) {
	const char *msg = (saved) ? strCallbackResultMessage_Saved : strCallbackResultMessage_SaveFailed;
	UnitySendMessage(strCopy(callbackSavedInfo.strGameObjectName), strCopy(callbackSavedInfo.strMethodName), strCopy(msg));
}
