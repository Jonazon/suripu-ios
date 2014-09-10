// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class SENSenseMessage;
@class SENSenseMessageBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef enum {
  ErrorTypeTimeOut = 0,
  ErrorTypeNetworkError = 1,
  ErrorTypeDeviceAlreadyPaired = 2,
  ErrorTypeInternalDataError = 3,
  ErrorTypeDeviceDatabaseFull = 4,
  ErrorTypeDeviceNoMemory = 5,
} ErrorType;

BOOL ErrorTypeIsValidValue(ErrorType value);

typedef enum {
  SENSenseMessageTypeSetTime = 0,
  SENSenseMessageTypeGetTime = 1,
  SENSenseMessageTypeSetWifiEndpoint = 2,
  SENSenseMessageTypeGetWifiEndpoint = 3,
  SENSenseMessageTypeSetAlarms = 4,
  SENSenseMessageTypeGetAlarms = 5,
  SENSenseMessageTypeSwitchToPairingMode = 6,
  SENSenseMessageTypeSwitchToNormalMode = 7,
  SENSenseMessageTypeStartWifiscan = 8,
  SENSenseMessageTypeStopWifiscan = 9,
  SENSenseMessageTypeGetDeviceId = 10,
  SENSenseMessageTypeEreasePairedPhone = 11,
  SENSenseMessageTypePairPill = 12,
  SENSenseMessageTypeError = 13,
  SENSenseMessageTypePairSense = 14,
} SENSenseMessageType;

BOOL SENSenseMessageTypeIsValidValue(SENSenseMessageType value);


@interface SensenseMessageRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SENSenseMessage : PBGeneratedMessage {
@private
  BOOL hasVersion_:1;
  BOOL hasDeviceId_:1;
  BOOL hasAccountId_:1;
  BOOL hasWifiName_:1;
  BOOL hasWifiSsid_:1;
  BOOL hasWifiPassword_:1;
  BOOL hasType_:1;
  BOOL hasError_:1;
  long version;
  NSString* deviceId;
  NSString* accountId;
  NSString* wifiName;
  NSString* wifiSsid;
  NSString* wifiPassword;
  SENSenseMessageType type;
  ErrorType error;
}
- (BOOL) hasVersion;
- (BOOL) hasType;
- (BOOL) hasDeviceId;
- (BOOL) hasAccountId;
- (BOOL) hasError;
- (BOOL) hasWifiName;
- (BOOL) hasWifiSsid;
- (BOOL) hasWifiPassword;
@property (readonly) long version;
@property (readonly) SENSenseMessageType type;
@property (readonly, strong) NSString* deviceId;
@property (readonly, strong) NSString* accountId;
@property (readonly) ErrorType error;
@property (readonly, strong) NSString* wifiName;
@property (readonly, strong) NSString* wifiSsid;
@property (readonly, strong) NSString* wifiPassword;

+ (SENSenseMessage*) defaultInstance;
- (SENSenseMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SENSenseMessageBuilder*) builder;
+ (SENSenseMessageBuilder*) builder;
+ (SENSenseMessageBuilder*) builderWithPrototype:(SENSenseMessage*) prototype;
- (SENSenseMessageBuilder*) toBuilder;

+ (SENSenseMessage*) parseFromData:(NSData*) data;
+ (SENSenseMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input;
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SENSenseMessageBuilder : PBGeneratedMessageBuilder {
@private
  SENSenseMessage* result;
}

- (SENSenseMessage*) defaultInstance;

- (SENSenseMessageBuilder*) clear;
- (SENSenseMessageBuilder*) clone;

- (SENSenseMessage*) build;
- (SENSenseMessage*) buildPartial;

- (SENSenseMessageBuilder*) mergeFrom:(SENSenseMessage*) other;
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasVersion;
- (long) version;
- (SENSenseMessageBuilder*) setVersion:(long) value;
- (SENSenseMessageBuilder*) clearVersion;

- (BOOL) hasType;
- (SENSenseMessageType) type;
- (SENSenseMessageBuilder*) setType:(SENSenseMessageType) value;
- (SENSenseMessageBuilder*) clearType;

- (BOOL) hasDeviceId;
- (NSString*) deviceId;
- (SENSenseMessageBuilder*) setDeviceId:(NSString*) value;
- (SENSenseMessageBuilder*) clearDeviceId;

- (BOOL) hasAccountId;
- (NSString*) accountId;
- (SENSenseMessageBuilder*) setAccountId:(NSString*) value;
- (SENSenseMessageBuilder*) clearAccountId;

- (BOOL) hasError;
- (ErrorType) error;
- (SENSenseMessageBuilder*) setError:(ErrorType) value;
- (SENSenseMessageBuilder*) clearError;

- (BOOL) hasWifiName;
- (NSString*) wifiName;
- (SENSenseMessageBuilder*) setWifiName:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiName;

- (BOOL) hasWifiSsid;
- (NSString*) wifiSsid;
- (SENSenseMessageBuilder*) setWifiSsid:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiSsid;

- (BOOL) hasWifiPassword;
- (NSString*) wifiPassword;
- (SENSenseMessageBuilder*) setWifiPassword:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiPassword;
@end


// @@protoc_insertion_point(global_scope)