//
//   Generated by https://github.com/blacktop/ipsw (Version: 3.1.549, BuildCommit: 3da8ece356e0f31d6b3a8e7f419e446ace69898f)
//
//    - LC_BUILD_VERSION:  Platform: macOS, MinOS: 15, SDK: 15, Tool: ld (1115.7.3)
//    - LC_BUILD_VERSION:  Platform: macCatalyst, MinOS: 18, SDK: 18, Tool: ld (1115.7.3)
//    - LC_SOURCE_VERSION: 1149.6.2.0.0
//
#ifndef CAPropertyInfo_Protocol_h
#define CAPropertyInfo_Protocol_h
@import Foundation;

@protocol CAPropertyInfo

@required

/* class methods */
+ (id)properties;
+ (id)attributesForKey:(id)key;

/* required instance methods */
- (id)attributesForKeyPath:(id)path;

@optional

@end

#endif /* CAPropertyInfo_Protocol_h */
