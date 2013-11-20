//
//  BTCBitcoinTick.h
//  Ticker
//
//  Created by Mert Dümenci on 20/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTCBitcoinTick : NSObject

@property (nonatomic, copy) NSString *formattedPrice;
@property (nonatomic) CGFloat price;
@property (nonatomic, retain) NSDate *date;

@end
