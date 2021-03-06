//
//  HEMVoiceExampleGroupCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMVoiceExampleGroupCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel* examplesLabel;

+ (CGFloat)heightWithCategoryName:(NSString*)categoryName
                         examples:(NSAttributedString*)examples
                        cellWidth:(CGFloat)cellWidth;
+ (NSDictionary*)examplesAttributes;
- (void)applyStyle;

@end
