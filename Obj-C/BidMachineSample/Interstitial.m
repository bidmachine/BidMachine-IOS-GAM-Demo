//
//  Interstitial.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Interstitial.h"

#define UNIT_ID         "your unit ID here"

@interface Interstitial ()<BidMachineAdDelegate, GADAppEventDelegate>

@property (nonatomic, strong) BidMachineInterstitial *bidmachineInterstitial;
@property (nonatomic, strong) GAMInterstitialAd *googleInterstitial;

@end

@implementation Interstitial

- (void)loadAd:(id)sender {
    [self deleteLoadedAd];
    [self switchState:BSStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared interstitial:nil :^(BidMachineInterstitial *interstitial, NSError *error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
            return;
        }
        weakSelf.bidmachineInterstitial = interstitial;
        weakSelf.bidmachineInterstitial.controller = weakSelf;
        weakSelf.bidmachineInterstitial.delegate = weakSelf;
        [weakSelf.bidmachineInterstitial loadAd];
    }];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    
    if (self.bidmachineInterstitial && self.bidmachineInterstitial.canShow) {
        [self.bidmachineInterstitial presentAd];
        return;
    }
    
    // No BidMachine interstitial to show. Fallback to Google native ad or implement your own fallback logic.
}

- (void)deleteLoadedAd {
    self.bidmachineInterstitial = nil;
    self.googleInterstitial = nil;
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    GAMRequest *googleRequest = [GAMRequest request];
    googleRequest.customTargeting = @{
        @"bm_pf" : [self.formatter stringFromNumber:@(ad.auctionInfo.price)]
    };
    
    __weak typeof(self) weakSelf = self;
    [GAMInterstitialAd loadWithAdManagerAdUnitID:@UNIT_ID
                                         request:googleRequest
                               completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd,
                                                   NSError * _Nullable error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
        } else {
            weakSelf.googleInterstitial = interstitialAd;
            weakSelf.googleInterstitial.appEventDelegate = weakSelf;
        }
    }];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self switchState:BSStateIdle];
    self.bidmachineInterstitial = nil;
    
    // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    [self switchState: BSStateIdle];
    [self deleteLoadedAd];
    
    // BidMachine ad has expired. Restart the ad loading process.
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    
}

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

#pragma mark - GADAppEventDelegate

- (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
    BOOL bidMachineWon = [name isEqualToString:@"bidmachine-interstitial"];
    
    if (bidMachineWon) {
        [BidMachineSdk.shared notifyMediationWin:self.bidmachineInterstitial];
        [self switchState:BSStateReady];
    } else {
        [BidMachineSdk.shared notifyMediationLoss:@"" ecpm:0.0 ad:self.bidmachineInterstitial];
        self.bidmachineInterstitial = nil;

        // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
        [self switchState:BSStateIdle];
    }
}

@end
