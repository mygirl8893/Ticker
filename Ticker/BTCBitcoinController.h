//
//  BTCBitcoinController.h
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

#import "BTCBitcoinTick.h"

@class FMDatabaseQueue;

typedef void (^BTCBitcoinControllerTickerBlock)(NSArray *);

@interface BTCBitcoinController : NSObject <SRWebSocketDelegate>

@property (nonatomic, retain) FMDatabaseQueue *databaseQueue;
@property (nonatomic, retain) SRWebSocket *webSocket;
@property (nonatomic, copy) BTCBitcoinControllerTickerBlock tickerBlock;

- (instancetype)initWithTickerBlock:(BTCBitcoinControllerTickerBlock)tickerBlock;
- (void)getTicksWithCompletionBlock:(BTCBitcoinControllerTickerBlock)completionBlock;

@end
