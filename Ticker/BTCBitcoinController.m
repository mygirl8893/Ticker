//
//  BTCBitcoinController.m
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "BTCBitcoinController.h"

static NSString *BTCBitcoinControllerWSEndpoint = @"https://websocket.mtgox.com/mtgox";

@implementation BTCBitcoinController

- (id)init {
    self = [super init];
    
    if (self) {
        self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:BTCBitcoinControllerWSEndpoint]];
        self.webSocket.delegate = self;
        
        [self.webSocket open];
    }
    
    return self;
}

- (void)dealloc {
    [self.webSocket close];
}

#pragma mark - Web Socket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSDictionary *message = @{@"op": @"mtgox.subscribe",
                              @"channel": @"ticker.BTCUSD"};
    
    [webSocket send:[NSJSONSerialization dataWithJSONObject:message options:0 error:nil]];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSError *error;
    NSDictionary *receivedMessage = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if ([receivedMessage[@"channel_name"] isEqualToString:@"ticker.BTCUSD"] && self.tickerBlock) {
        NSDictionary *last = [receivedMessage valueForKeyPath:@"ticker.last"];
        
        NSString *formattedPrice = last[@"display_short"];
        CGFloat price = [last[@"value"] floatValue];
        
        self.tickerBlock(formattedPrice, price);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Error in WebSocket connection : %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed WebSocket connection : %@", reason);
}

@end
