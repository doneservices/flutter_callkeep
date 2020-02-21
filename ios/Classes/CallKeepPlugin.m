#import "CallKeepPlugin.h"
#import <flutter_callkeep/flutter_callkeep-Swift.h>

@implementation CallKeepPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCallKeepPlugin registerWithRegistrar:registrar];
}
@end
