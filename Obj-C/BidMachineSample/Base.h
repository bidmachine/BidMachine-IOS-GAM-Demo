//
//  Base.h
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "AppDelegate.h"
#import "BidMachineSample-Swift.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BSState) {
    BSStateIdle = 0,
    BSStateLoading,
    BSStateReady
};

@interface Base : UIViewController

- (IBAction)loadAd:(id)sender;
- (IBAction)showAd:(id)sender;

@end

@interface Base (Interface)

- (void)switchState:(BSState)state;

@end

@interface Base (Rounding)

- (NSNumberFormatter *)formatter;

@end

NS_ASSUME_NONNULL_END
