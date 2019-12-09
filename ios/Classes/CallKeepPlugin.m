#import "CallKeepPlugin.h"
#import <callkeep/callkeep-Swift.h>

@implementation CallKeepPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCallKeepPlugin registerWithRegistrar:registrar];
}
@end
