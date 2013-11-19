//
//  BTCViewController.h
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTCBitcoinController, BTCGraphView;

@interface BTCViewController : UIViewController

@property (nonatomic, retain) BTCBitcoinController *bitcoinController;
@property (nonatomic, retain) NSArray *prices;

@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, retain) BTCGraphView *graphView;
@property (nonatomic, retain) UIActivityIndicatorView *loadingView;

@end
