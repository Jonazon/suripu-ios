
#import <FDWaveformView/FDWaveformView.h>
#import <SpinKit/RTSpinKitView.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepEventButton.h"
#import "NSAttributedString+HEMUtils.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"

@interface HEMSleepEventCollectionViewCell ()<AVAudioPlayerDelegate, FDWaveformViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* contentViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIImageView* lineView;
@property (nonatomic, weak) IBOutlet UIView* contentContainerView;
@property (weak, nonatomic) IBOutlet UIButton* playSoundButton;
@property (weak, nonatomic) IBOutlet FDWaveformView* waveformView;
@property (weak, nonatomic) IBOutlet RTSpinKitView* spinnerView;

@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* playerUpdateTimer;
@property (nonatomic, strong) UIView* gradientContainerTopView;
@property (nonatomic, strong) UIView* gradientContainerBottomView;
@property (nonatomic, strong) CAGradientLayer* gradientTopLayer;
@property (nonatomic, strong) CAGradientLayer* gradientBottomLayer;
@property (nonatomic, getter=isExpanded) BOOL expanded;
@property (nonatomic, strong) NSOperationQueue* loadingQueue;
@end

@implementation HEMSleepEventCollectionViewCell

static CGFloat const HEMEventButtonSize = 40.f;
static CGFloat const HEMEventBlurHeight = 60.f;
static NSTimeInterval const HEMEventPlayerUpdateInterval = 0.15f;
static NSString* const HEMEventPlayerFileName = @"cache_audio%ld.mp3";

+ (NSAttributedString*)attributedMessageFromText:(NSString*)text
{
    return [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForEventMessageText]) trim];
}

- (void)addTimeLabelWithText:(NSString*)text atHeightRatio:(CGFloat)heightRatio
{
    static CGFloat const HEMEventTimeLabelOffsetRatio = 0.5;
    CGFloat ratio = (heightRatio * HEMEventTimeLabelOffsetRatio) + HEMEventTimeLabelOffsetRatio;
    [super addTimeLabelWithText:text atHeightRatio:ratio];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.loadingQueue = [NSOperationQueue new];
    self.loadingQueue.maxConcurrentOperationCount = 1;
    self.backgroundColor = [UIColor clearColor];
    self.contentViewHeightConstraint.constant = 0;
    self.lineView.image = [self dottedLineBorderImageWithColor:[HelloStyleKit tintColor]];
    [self configureVerifyButton];
    [self configureAudioPlayer];
    [self configureGradientViews];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.verifyDataButton.hidden = YES;
    self.audioPlayerView.hidden = YES;
    [self useExpandedLayout:NO targetSize:CGSizeZero animated:NO];
}

- (void)configureVerifyButton
{
    self.verifyDataButton.hidden = YES;
    NSDictionary* attributes = @{NSUnderlineStyleAttributeName:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle),
                                 NSForegroundColorAttributeName:[HelloStyleKit tintColor]};
    NSString* localizedTitle = NSLocalizedString(@"sleep-event.verify.title", nil);
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:localizedTitle
                                                                attributes:attributes];
    [self.verifyDataButton setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)configureAudioPlayer
{
    self.playSoundButton.enabled = NO;
    self.waveformView.progressColor = [HelloStyleKit tintColor];
    self.waveformView.wavesColor = [HelloStyleKit lightSleepColor];
    self.waveformView.delegate = self;
    self.spinnerView.color = self.waveformView.progressColor;
    self.spinnerView.spinnerSize = CGRectGetHeight(self.playSoundButton.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
    [self.spinnerView startAnimating];
}

- (void)configureGradientViews
{
    self.contentContainerView.layer.shadowOffset = CGSizeZero;
    self.contentContainerView.layer.shadowRadius = 1.5f;
    self.contentContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gradientContainerTopView = [UIView new];
    self.gradientContainerTopView.alpha = 0;
    self.gradientContainerBottomView = [UIView new];
    self.gradientContainerBottomView.alpha = 0;
    [self insertSubview:self.gradientContainerTopView atIndex:0];
    [self insertSubview:self.gradientContainerBottomView atIndex:0];
    NSArray* topColors = @[(id)[[HelloStyleKit tintColor] colorWithAlphaComponent:0].CGColor,
                           (id)[[HelloStyleKit tintColor] colorWithAlphaComponent:0.1f].CGColor];

    CAGradientLayer* topLayer = [CAGradientLayer layer];
    topLayer.colors = topColors;
    topLayer.frame = self.gradientContainerTopView.bounds;
    topLayer.locations = @[ @0, @1 ];
    topLayer.startPoint = CGPointZero;
    topLayer.endPoint = CGPointMake(0, 1);
    self.gradientTopLayer = topLayer;
    [self.gradientContainerTopView.layer insertSublayer:topLayer atIndex:0];
    CAGradientLayer* bottomLayer = [CAGradientLayer layer];
    bottomLayer.colors = [[topColors reverseObjectEnumerator] allObjects];
    bottomLayer.frame = self.gradientContainerTopView.bounds;
    bottomLayer.locations = @[ @0, @1 ];
    bottomLayer.startPoint = CGPointZero;
    bottomLayer.endPoint = CGPointMake(0, 1);
    self.gradientBottomLayer = bottomLayer;
    [self.gradientContainerBottomView.layer insertSublayer:bottomLayer atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = HEMEventButtonSize/2;
    CGFloat width = CGRectGetWidth(self.bounds);
    self.gradientContainerTopView.frame = CGRectMake(0, -HEMEventBlurHeight + inset, width, HEMEventBlurHeight);
    self.gradientContainerBottomView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - inset, width, HEMEventBlurHeight);
    self.gradientTopLayer.frame = self.gradientContainerTopView.bounds;
    [self.gradientTopLayer setNeedsLayout];
    self.gradientBottomLayer.frame = self.gradientContainerBottomView.bounds;
    [self.gradientBottomLayer setNeedsLayout];
}

- (void)setNeedsLayout
{
    [self setNeedsDisplay];
    [super setNeedsLayout];
}

- (void)useExpandedLayout:(BOOL)isExpanded targetSize:(CGSize)size animated:(BOOL)animated
{
    self.expanded = isExpanded;
    self.clipsToBounds = isExpanded ? NO : [self numberOfTimeLabels] == 0;
    [self setNeedsDisplay];
    void (^endAnimations)() = NULL;
    void (^startAnimations)() = NULL;
    if (isExpanded) {
        self.contentViewHeightConstraint.constant = MAX(size.height - HEMEventButtonSize/2, 0);
        startAnimations = ^{
            self.lineView.alpha = 0;
            self.contentContainerView.alpha = 1;
            self.eventTimeLabel.alpha = 0;
            self.gradientContainerTopView.alpha = 1;
            self.gradientContainerBottomView.alpha = 1;
            self.contentContainerView.layer.shadowOpacity = 0.1f;
            [self.eventTypeButton hideOutline];
        };
        endAnimations = ^{
            [self.contentContainerView layoutIfNeeded];
            self.eventTitleLabel.alpha = 1;
            self.eventMessageLabel.alpha = 1;
        };
    } else {
        self.contentViewHeightConstraint.constant = 0;
        endAnimations = ^{
            self.lineView.alpha = 1;
            self.eventTimeLabel.alpha = 1;
            [self.eventTypeButton showOutline];
        };
        startAnimations = ^{
            [self.contentContainerView layoutIfNeeded];
            self.eventTitleLabel.alpha = 0;
            self.eventMessageLabel.alpha = 0;
            self.contentContainerView.alpha = 0;
            self.gradientContainerTopView.alpha = 0;
            self.gradientContainerBottomView.alpha = 0;
            self.contentContainerView.layer.shadowOpacity = 0;
        };
    }
    if (animated) {
        [self.contentContainerView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2f animations:startAnimations completion:^(BOOL finished) {
             [UIView animateWithDuration:0.2f animations:endAnimations];
         }];
    } else {
        startAnimations();
        endAnimations();
    }
}

- (void)drawRect:(CGRect)rect
{
    if ([self isExpanded])
        return;
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = HEMSleepLineWidth;
    CGFloat height = 0;
    CGFloat x = CGRectGetMidX(rect)  - width;
    CGFloat halfButton = ceilf(HEMEventButtonSize/2);
    CGContextSetFillColorWithColor(ctx, self.lineColor.CGColor);
    if ([self isLastSegment] && ![self isFirstSegment]) {
        height = halfButton;
    } else if ([self isFirstSegment] && ![self isLastSegment]) {
        height = CGRectGetHeight(rect) - halfButton;
    } else {
        height = CGRectGetHeight(rect);
    }
    CGRect contentRect = CGRectMake(x, CGRectGetMidY(rect), width, height);
    CGContextFillRect(ctx, contentRect);
}


- (void)setLoading:(BOOL)isLoading
{
    if (isLoading)
        [self.spinnerView startAnimating];
    else
        [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = !isLoading;
}

#pragma mark - Audio

- (void)showAudioPlayer:(BOOL)isVisible
{
    self.audioPlayerView.hidden = !isVisible;
    self.playSoundButton.enabled = NO;
    if (isVisible)
        [self.spinnerView startAnimating];
    else
        [self.spinnerView stopAnimating];
}

- (void)setAudioURL:(NSURL *)audioURL
{
    [self stopAudio];
    [self.loadingQueue cancelAllOperations];
    if ([audioURL isEqual:self.waveformView.audioURL]) {
        self.playSoundButton.enabled = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.loadingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSData* urlData = [NSData dataWithContentsOfURL:audioURL];
        if (!urlData) {
            [strongSelf cancelLoading];
            return;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cache = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
        NSString* fileName = [NSString stringWithFormat:HEMEventPlayerFileName, (long)[audioURL hash]];
        NSURL* localFile = [cache URLByAppendingPathComponent:fileName];
        BOOL success = [urlData writeToURL:localFile atomically:YES];
        if (!success) {
            [strongSelf cancelLoading];
            return;
        }
        [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
            strongSelf.waveformView.audioURL = localFile;
            strongSelf.waveformView.completion = ^(NSURL* processedURL, BOOL success) {
                if (success)
                    [strongSelf handleLoadingSuccess];
            };
        }]];
    }]];
}

- (void)cancelLoading
{
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [weakSelf handleLoadingFailure];
    }]];
}

- (IBAction)toggleAudio
{
    if ([self.player isPlaying])
        [self stopAudio];
    else
        [self playAudio];
}

- (void)playAudio
{
    NSURL* url = self.waveformView.audioURL;
    if (!url)
        return;
    if ([self.player isPlaying])
        [self.player stop];
    [self.playerUpdateTimer invalidate];
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    if (error) {
        [self stopAudio];
    } else {
        [self.waveformView setProgressRatio:0];
        [self.player play];
        [self.playSoundButton setImage:[UIImage imageNamed:@"stopSound"] forState:UIControlStateNormal];
        self.playerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:HEMEventPlayerUpdateInterval
                                                                  target:self
                                                                selector:@selector(updateAudioProgress)
                                                                userInfo:nil
                                                                 repeats:YES];
    }
}

- (void)stopAudio
{
    [self.playerUpdateTimer invalidate];
    [self.waveformView setProgressRatio:1];
    [self.playSoundButton setImage:[UIImage imageNamed:@"playSound"] forState:UIControlStateNormal];
    [self.player stop];
    self.player = nil;
}

- (void)updateAudioProgress
{
    [self.waveformView setProgressRatio:self.player.currentTime/self.player.duration];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self stopAudio];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self stopAudio];
}

#pragma mark FDWaveformView

- (void)waveformViewWillLoad:(FDWaveformView *)waveformView
{
    [self performSelectorOnMainThread:@selector(handleLoadingStart) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [self performSelectorOnMainThread:@selector(handleLoadingSuccess) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidFail:(FDWaveformView *)waveformView error:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleLoadingFailure) withObject:nil waitUntilDone:NO];
}

- (void)handleLoadingStart
{
    if ([self.spinnerView isAnimating])
        return;
    [self.spinnerView startAnimating];
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingFailure
{
    [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingSuccess
{
    if ([self.spinnerView isAnimating])
        [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = YES;
}


@end
