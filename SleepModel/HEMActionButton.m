
#import "HEMActionButton.h"

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

static CGFloat const kHEMActionTitleTopOffset = 3.0f;

@interface HEMActionButton()

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, copy)   NSString* originalTitle;
@property (nonatomic, assign, getter=isShowingActivity) BOOL showingActivity;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@property (nonatomic, weak)   NSLayoutConstraint* widthConstraint;
@property (nonatomic, strong) NSMutableDictionary* backgroundColors;

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
    self.layer.cornerRadius = 3;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateDisabled];
    [self.titleLabel setFont:[UIFont primaryButtonFont]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(kHEMActionTitleTopOffset, 0.0f, 0.0f, 0.0f)];
    
    [self setBackgroundColors:[NSMutableDictionary new]];
    [self setBackgroundColor:[UIColor tintColor] forState:UIControlStateNormal];
    [self setBackgroundColor:[UIColor blue7] forState:UIControlStateHighlighted];
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

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted && [self isEnabled]) {
        UIColor* bgColor = [self backgroundColors][@(UIControlStateHighlighted)];
        [self setBackgroundColor:bgColor];
    } else {
        [self updateNormalBackgroundColor];
    }
    [super setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected {
    UIColor* selectedColor = [self backgroundColors][@(UIControlStateSelected)];
    if (selectedColor) {
        [self setBackgroundColor:selectedColor];
    }
    [super setSelected:selected];
}

- (void)updateNormalBackgroundColor {
    UIColor* normalColor = [self backgroundColors][@(UIControlStateNormal)];
    if (normalColor) {
        [self setBackgroundColor:normalColor];
    } else {
        [self setBackgroundColor:[UIColor tintColor]];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    UIColor* disabledColor = [self backgroundColors][@(UIControlStateDisabled)];
    if (disabledColor) {
        [self setBackgroundColor:disabledColor];
    } else {
        [self updateNormalBackgroundColor];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (backgroundColor) {
        [self backgroundColors][@(state)] = backgroundColor;
        if (state == UIControlStateNormal) {
            [self setBackgroundColor:backgroundColor];
        }
    } else {
        [[self backgroundColors] removeObjectForKey:@(state)];
    }
}

@end
