
#import "SENInsight.h"
#import "Model.h"

// insight constants
static NSString* const SENInsightDateCreatedKey = @"timestamp";
static NSString* const SENInsightTitleKey = @"title";
static NSString* const SENInsightMessageKey = @"message";
static NSString* const SENInsightCategory = @"category";
static NSString* const SENInsightId = @"identifier";
static NSString* const SENInsightText = @"text";
static NSString* const SENInsightImageUri = @"image_url";
static NSString* const SENInsightInfoPreviewKey = @"info_preview";
static NSString* const SENInsightMultiDensityImage = @"image";

static NSString* const SENInsightCategoryGeneric = @"GENERIC";

@implementation SENInsight

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        _title = [dict[SENInsightTitleKey] copy];
        _message = [dict[SENInsightMessageKey] copy];
        _category = [dict[SENInsightCategory] copy];
        _infoPreview = [dict[SENInsightInfoPreviewKey] copy];
        
        NSNumber* dateMillis = SENObjectOfClass(dict[SENInsightDateCreatedKey], [NSNumber class]);
        if (dateMillis) {
            _dateCreated = SENDateFromNumber(dateMillis);
        }
        
        NSDictionary* imageDict = SENObjectOfClass(dict[SENInsightMultiDensityImage], [NSDictionary class]);
        if (imageDict) {
            _remoteImage = [[SENRemoteImage alloc] initWithDictionary:imageDict];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _title = [aDecoder decodeObjectForKey:SENInsightTitleKey];
        _message = [aDecoder decodeObjectForKey:SENInsightMessageKey];
        _dateCreated = [aDecoder decodeObjectForKey:SENInsightDateCreatedKey];
        _category = [aDecoder decodeObjectForKey:SENInsightCategory];
        _infoPreview = [aDecoder decodeObjectForKey:SENInsightInfoPreviewKey];
        _remoteImage = [aDecoder decodeObjectForKey:SENInsightMultiDensityImage];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (self.title) [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
    if (self.message) [aCoder encodeObject:self.message forKey:SENInsightMessageKey];
    if (self.dateCreated) [aCoder encodeObject:self.dateCreated forKey:SENInsightDateCreatedKey];
    if (self.category) [aCoder encodeObject:self.category forKey:SENInsightCategory];
    if (self.infoPreview) [aCoder encodeObject:self.infoPreview forKey:SENInsightInfoPreviewKey];
    if (self.remoteImage) [aCoder encodeObject:self.remoteImage forKey:SENInsightMultiDensityImage];
}

- (BOOL)isGeneric {
    return [[self category] isEqualToString:SENInsightCategoryGeneric];
}

- (BOOL)isEqual:(SENInsight*)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[SENInsight class]]) {
        return NO;
    } else {
        return ([self.title isEqualToString:other.title] || (!self.title && !other.title))
            && ([self.message isEqualToString:other.message] || (!self.message && !other.message))
            && ([self.dateCreated isEqualToDate:other.dateCreated] || (!self.dateCreated && !other.dateCreated))
            && ([self.infoPreview isEqualToString:other.infoPreview] || (!self.infoPreview && !other.infoPreview))
            && ([self.category isEqualToString:other.category] || (!self.category && !other.category))
            && ([self.remoteImage isEqual:other.remoteImage] || (!self.remoteImage && !other.remoteImage));
    }
}

- (NSUInteger)hash
{
    return [self.title hash] + [self.message hash] + [self.dateCreated hash] + [self.category hash] + [self.infoPreview hash] + [self.remoteImage hash];
}

@end

#pragma mark - Insight Info

@interface SENInsightInfo()

@property (nonatomic, assign, readwrite) NSUInteger identifier;
@property (nonatomic, copy, readwrite)   NSString* category;
@property (nonatomic, copy, readwrite)   NSString* title;
@property (nonatomic, copy, readwrite)   NSString* info;
@property (nonatomic, copy, readwrite)   NSString* imageURI;

@end

@implementation SENInsightInfo

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        id identifierObj = dict[SENInsightId];
        _identifier = [identifierObj isKindOfClass:[NSNumber class]] ? [identifierObj integerValue] : NSNotFound;
        _category = [dict[SENInsightCategory] copy];
        _info = [dict[SENInsightText] copy];
        _imageURI = [dict[SENInsightImageUri] copy];
        _title = [dict[SENInsightTitleKey] copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _identifier = [[aDecoder decodeObjectForKey:SENInsightId] unsignedIntegerValue];
        _category = [aDecoder decodeObjectForKey:SENInsightCategory];
        _info = [aDecoder decodeObjectForKey:SENInsightText];
        _imageURI = [aDecoder decodeObjectForKey:SENInsightImageUri];
        _title = [aDecoder decodeObjectForKey:SENInsightTitleKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.identifier) forKey:SENInsightId];
    [aCoder encodeObject:self.category forKey:SENInsightCategory];
    [aCoder encodeObject:self.info forKey:SENInsightText];
    [aCoder encodeObject:self.imageURI forKey:SENInsightImageUri];
    [aCoder encodeObject:self.title forKey:SENInsightTitleKey];
}

- (BOOL)isEqual:(SENInsightInfo*)other
{
    if (other == self) {
        return YES;
    } else if (![other isKindOfClass:[SENInsightInfo class]]) {
        return NO;
    } else {
        return ((self.category && [self.category isEqualToString:other.category]) || (!self.category && !other.category))
            && ((self.info && [self.info isEqualToString:other.info]) || (!self.info && !other.info))
            && ((self.imageURI && [self.imageURI isEqualToString:other.imageURI]) || (!self.imageURI && !other.imageURI))
            && ((self.title && [self.title isEqualToString:other.title]) || (!self.title && !other.title))
            && ((self.category && [self.category isEqualToString:other.category]) || (!self.category && !other.category));
    }
}

- (NSUInteger)hash
{
    return self.identifier + [self.title hash] + [self.info hash];
}

@end
