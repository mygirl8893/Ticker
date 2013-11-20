//
//  BTCViewController.m
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "BTCViewController.h"
#import "BTCBitcoinController.h"
#import "BTCGraphView.h"

#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface BTCViewController ()

- (void)timeUpdateTimerTick:(NSTimer *)timer;

@end

@implementation BTCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.loadingView];
    [self.view addSubview:self.priceLabel];
    [self.view addSubview:self.graphView];
    [self.view addSubview:self.intervalLabel];
    
    __weak typeof(self) weakself = self;
    
    self.bitcoinController = [[BTCBitcoinController alloc] initWithTickerBlock:^(NSArray *ticks) {
        if (ticks.count > 0) {
            if (weakself.loadingView.alpha == 1.f) {
                [UIView animateWithDuration:0.3 animations:^{
                    weakself.loadingView.alpha = 0.f;
                    weakself.priceLabel.alpha = 1.f;
                    weakself.graphView.alpha = 1.f;
                    weakself.intervalLabel.alpha = 0.55f;
                }];
            }
            
            self.ticks = ticks;
            BTCBitcoinTick *lastTick = [ticks lastObject];
            
            weakself.priceLabel.text = lastTick.formattedPrice;
            weakself.graphView.values = [ticks valueForKeyPath:@"price"];
            
            if (!self.timeUpdateTimer) self.timeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(timeUpdateTimerTick:) userInfo:nil repeats:YES];
            [self timeUpdateTimerTick:self.timeUpdateTimer]; // Manually invoke the updater instantly.
        }
    }];
}

#pragma mark - Properties

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:50.f];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.adjustsFontSizeToFitWidth = YES;
        _priceLabel.alpha = 0.f;
    }
    
    return _priceLabel;
}

- (UILabel *)intervalLabel {
    if (!_intervalLabel) {
        _intervalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - (20 + 10), self.view.frame.size.width, 20)];
        _intervalLabel.backgroundColor = [UIColor clearColor];
        _intervalLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.f];
        _intervalLabel.textColor = [UIColor whiteColor];
        _intervalLabel.textAlignment = NSTextAlignmentCenter;
        _intervalLabel.alpha = 0.f;
    }
    
    return _intervalLabel;
}

- (BTCGraphView *)graphView {
    if (!_graphView) {
        _graphView = [[BTCGraphView alloc] initWithFrame:CGRectMake(0, self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height, self.view.frame.size.width, 100)];
        _graphView.backgroundColor = [UIColor clearColor];
        _graphView.alpha = 0.f;
    }
    
    return _graphView;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingView.frame = CGRectMake(self.view.frame.size.width / 2 - _loadingView.frame.size.width / 2, self.view.frame.size.height / 2 - _loadingView.frame.size.height / 2, _loadingView.frame.size.width, _loadingView.frame.size.height);
        _loadingView.hidesWhenStopped = NO;
        
        [_loadingView startAnimating];
    }
    
    return _loadingView;
}

- (TTTTimeIntervalFormatter *)timeIntervalFormatter {
    if (!_timeIntervalFormatter) {
        _timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    }
    
    return _timeIntervalFormatter;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Updates

- (void)timeUpdateTimerTick:(NSTimer *)timer {
    BTCBitcoinTick *lastTick = [self.ticks lastObject];
    
    self.intervalLabel.text = [self.timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:lastTick.date];
}

@end
