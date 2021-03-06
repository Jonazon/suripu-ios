//
//  HEMFormPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMFormPresenter;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMFormSaveHandler)(NSString* _Nullable errorMessage);

@protocol HEMFormDelegate <NSObject>

- (void)showErrorTitle:(NSString*)title
               message:(NSString*)message
         fromPresenter:(HEMFormPresenter*)presenter;
- (void)dismissFrom:(HEMFormPresenter*)presenter;

@end

@interface HEMFormPresenter : HEMPresenter

@property (assign, nonatomic) NSUInteger numberOfFields;
@property (copy, nonatomic) NSString* title;
@property (weak, nonatomic) id<HEMFormDelegate> delegate;

- (void)bindWithCollectionView:(UICollectionView*)collectionView
              bottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithSaveItem:(UIBarButtonItem*)saveItem;

// for subclasses to override
- (nullable NSString*)existingTextForFieldInRow:(NSInteger)row;
- (nullable NSString*)placeHolderTextForFieldInRow:(NSInteger)row;
- (UIKeyboardType)keyboardTypeForFieldInRow:(NSInteger)row;
- (UITextAutocorrectionType)fieldAutocorrectTypeInRow:(NSInteger)row;
- (UITextAutocapitalizationType)fieldCapitalizationTypeInRow:(NSInteger)row;
- (BOOL)isFieldSecureInRow:(NSInteger)row;
- (BOOL)canEnableSave:(NSDictionary*)formContent;
- (void)saveContent:(NSDictionary*)content completion:(HEMFormSaveHandler)completion;

@end

NS_ASSUME_NONNULL_END
