#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(VideoComponentViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(source, NSString)
RCT_EXPORT_VIEW_PROPERTY(onCloseVideo, RCTDirectEventBlock)
@end
