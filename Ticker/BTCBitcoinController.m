//
//  BTCBitcoinController.m
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "BTCBitcoinController.h"

#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMResultSet.h>
#import <FMDB/FMDatabase.h>

static NSInteger cacheSize = 30;
static NSString *BTCBitcoinControllerWSEndpoint = @"https://websocket.mtgox.com/mtgox";

@interface BTCBitcoinController (private)

- (void)connect;

- (void)persistTick:(BTCBitcoinTick *)tick;
- (void)setupDatabase;

+ (NSString *)databasePath;

@end

@implementation BTCBitcoinController

- (id)initWithTickerBlock:(BTCBitcoinControllerTickerBlock)tickerBlock {
    self = [super init];
    
    if (self) {
        self.tickerBlock = tickerBlock;
        self.databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[self.class databasePath]];
        
        [self setupDatabase];
        [self getTicksWithCompletionBlock:self.tickerBlock];
        [self connect];
    }
    
    return self;
}

- (void)dealloc {
    [self.webSocket close];
}

- (void)connect {
    NSLog(@"Connecting WebSocket...");
    
    if (self.webSocket) [self.webSocket close];
    
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:BTCBitcoinControllerWSEndpoint]];
    self.webSocket.delegate = self;
    
    [self.webSocket open];
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
        
        BTCBitcoinTick *tick = [[BTCBitcoinTick alloc] init];
        tick.formattedPrice = last[@"display_short"];
        tick.price = [last[@"value"] floatValue];
        tick.date = [NSDate date];
        
        [self persistTick:tick];
        [self getTicksWithCompletionBlock:^(NSArray *ticks) {
            self.tickerBlock(ticks);
        }];

    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Error in WebSocket connection : %@", error);
    
    [self connect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Closed WebSocket connection : %@", reason);
    
    [self connect];
}

#pragma mark - Database

- (void)getTicksWithCompletionBlock:(BTCBitcoinControllerTickerBlock)completionBlock {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray *cachedTicks = [NSMutableArray array];
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM (SELECT * FROM ticks ORDER BY id DESC LIMIT ?) sub ORDER BY id ASC;", @(cacheSize)];
        
        while ([resultSet next]) {
            BTCBitcoinTick *cachedTick = [[BTCBitcoinTick alloc] init];
            cachedTick.formattedPrice = [resultSet stringForColumn:@"formattedPrice"];
            cachedTick.price = (CGFloat)[resultSet doubleForColumn:@"price"];
            cachedTick.date = [resultSet dateForColumn:@"date"];
            
            [cachedTicks addObject:cachedTick];
        }
        
        completionBlock(cachedTicks);
    }];
}

- (void)persistTick:(BTCBitcoinTick *)tick {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO ticks (formattedPrice, price, date) VALUES (?, ?, ?);", tick.formattedPrice, @(tick.price), tick.date];
    }];
}

- (void)setupDatabase {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE if not exists ticks (id INTEGER PRIMARY KEY AUTOINCREMENT, formattedPrice TEXT, price DOUBLE, date DATE);"];
    }];
}

+ (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    
    return [basePath stringByAppendingPathComponent:@"ticker.db"];
}

@end
