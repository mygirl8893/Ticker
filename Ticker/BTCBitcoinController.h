//
//  BTCBitcoinController.h
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>

typedef void (^BTCBitcoinControllerTickerBlock)(NSString *formattedPrice, CGFloat price);

@interface BTCBitcoinController : NSObject <SRWebSocketDelegate>

@property (nonatomic, retain) SRWebSocket *webSocket;
@property (nonatomic, copy) BTCBitcoinControllerTickerBlock tickerBlock;

@end
