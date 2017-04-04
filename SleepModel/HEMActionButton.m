
#import "HEMActionButton.h"

#import "Sense-Swift.h"

static CGFloat const kHEMActionTitleTopOffset = 3.0f;
static CGFloat const kHEMActionCornerRadius = 3.0f;

@interface HEMActionButton()

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, copy)   NSString* originalTitle;
@property (nonatomic, assign, getter=isShowingActivity) BOOL showingActivity;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@property (nonatomic, weak)   NSLayoutConstraint* widthConstraint;

@end

@implementation HEMActionButton

- (id)init {
    self = [self init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    [[self layer] setCornerRadius:kHEMActionCornerRadius];
    
    [self setClipsToBounds:YES];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(kHEMActionTitleTopOffset, 0.0f, 0.0f, 0.0f)];
    [self applyStyle];
}

- (void)addActivityView {
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] setHidesWhenStopped:YES];
    }
    // re-center it
    [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
    [self addSubview:[self activityView]];
}

- (void)prepareForActivity {
    if (CGRectIsEmpty([self originalFrame])) {
        [self setOriginalFrame:[self frame]];
    }
    
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
        [[self activityView] hidesWhenStopped];
        
        static NSString* activityKey = @"sense.activity.color";
        [[self activityView] setColor:[SenseStyle colorWithAClass:[self class] propertyName:activityKey]];
        [self addSubview:[self activityView]];
    }
    
    [self setShowingActivity:YES];
    [self setOriginalTitle:[self titleForState:UIControlStateNormal]]; // always take latest
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateDisabled];
    [self setEnabled:NO];
}

- (void)showActivity {
    if ([self isShowingActivity]) return;
    
    [self prepareForActivity];
    
    // take the height as the diameter
    CGFloat size = CGRectGetHeight([self bounds]);
    CGFloat radius = size / 2.0f;
    CGPoint center = [self center];
    center.x = CGRectGetMidX([self frame]);
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect bounds = [self bounds];
                         bounds.size.width = size;
                         [self setBounds:bounds];
                         [self setCenter:center];
                         [[self layer] setCornerRadius:radius];
                     }
                     completion:^(BOOL finished) {
                         [self addActivityView];
                         [[self activityView] startAnimating];
                     }];
}

- (void)showActivityWithWidthConstraint:(NSLayoutConstraint*)constraint {
    if ([self isShowingActivity]) return;
    
    [self prepareForActivity];
    [self setWidthConstraint:constraint];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [constraint setConstant:CGRectGetHeight([self bounds])];
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self addActivityView];
                         [[self activityView] startAnimating];
                     }];
}

- (void)stopActivity {
    if (![self isShowingActivity]) return;
    
    [[self activityView] stopAnimating];
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if ([self widthConstraint] != nil) {
                             CGFloat width = CGRectGetWidth([self originalFrame]);
                             [[self widthConstraint] setConstant:width];
                             [self layoutIfNeeded];
                         } else {
                             [self setFrame:[self originalFrame]];
                         }
                     }
                     completion:^(BOOL finished) {
                         [self setShowingActivity:NO];
                         [[self activityView] stopAnimating];
                         [self setTitle:[self originalTitle] forState:UIControlStateNormal];
                         [self setTitle:[self originalTitle] forState:UIControlStateDisabled];
                         [self setEnabled:YES];
                     }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (backgroundColor) {
        [self setBackgroundImage:[self imageWithColor:backgroundColor] forState:state];
    } else {
        [self setBackgroundImage:nil forState:state];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
