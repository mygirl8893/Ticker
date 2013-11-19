//
//  BTCGraphView.h
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTCGraphView : UIView

@property (nonatomic, retain) CAShapeLayer *graphLayer;
@property (nonatomic, retain) NSArray *values;

@end
