
#import <UIKit/UIKit.h>

@class HEMSleepScoreGraphView;
@interface HEMSleepSummaryCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated;
@end
