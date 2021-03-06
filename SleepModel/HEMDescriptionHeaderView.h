//
//  HEMDescriptionHeaderView.h
//  Sense
//
//  Created by Jimmy Lu on 8/31/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMDescriptionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel* titlLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
               description:(NSAttributedString*)description
           widthConstraint:(CGFloat)width;
+ (NSAttributedString*)attributedTitle:(NSString*)title;
+ (NSAttributedString*)attributedDescription:(NSString*)description;

@end
