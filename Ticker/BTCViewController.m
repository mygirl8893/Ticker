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

@interface BTCViewController ()

@end

@implementation BTCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.loadingView];
    [self.view addSubview:self.priceLabel];
    [self.view addSubview:self.graphView];
    
    __weak typeof(self) weakself = self;
    
    self.bitcoinController = [[BTCBitcoinController alloc] init];
    self.bitcoinController.tickerBlock = ^(NSString *formattedPrice, CGFloat price) {
        if (weakself.loadingView.alpha == 1.f) {
            [UIView animateWithDuration:0.3 animations:^{
                weakself.loadingView.alpha = 0.f;
                weakself.priceLabel.alpha = 1.f;
                weakself.graphView.alpha = 1.f;
            }];
        }
        
        weakself.priceLabel.text = formattedPrice;
        
        [[weakself mutableArrayValueForKeyPath:@"prices"] addObject:@(price)];
        weakself.graphView.values = weakself.prices;
    };
}

#pragma mark - Properties

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 250)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:50.f];
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.adjustsFontSizeToFitWidth = YES;
        _priceLabel.alpha = 1.f;
    }
    
    return _priceLabel;
}

- (BTCGraphView *)graphView {
    if (!_graphView) {
        _graphView = [[BTCGraphView alloc] initWithFrame:CGRectMake(0, self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height, self.view.frame.size.width, 250)];
        _graphView.backgroundColor = [UIColor clearColor];
        _graphView.alpha = 1.f;
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

- (NSArray *)prices {
    if (!_prices) {
        _prices = [NSMutableArray array];
    }
    
    return _prices;
}

@end
