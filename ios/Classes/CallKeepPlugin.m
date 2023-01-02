#import "CallKeepPlugin.h"
#if __has_include(<flutter_callkeep/flutter_callkeep-Swift.h>)
#import <flutter_callkeep/flutter_callkeep-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_callkeep-Swift.h"
#endif

@implementation CallKeepPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCallKeepPlugin registerWithRegistrar:registrar];
}
@end
