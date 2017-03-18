//
//  HEMSensorAboutCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSensorAboutCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

+ (NSDictionary*)aboutAttributes;
+ (NSDictionary*)boldAboutAttributes;
+ (CGFloat)heightWithTitle:(NSString*)title about:(NSAttributedString*)about maxWidth:(CGFloat)width;

@end
