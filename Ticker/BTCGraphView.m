//
//  BTCGraphView.m
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "BTCGraphView.h"

@interface BTCGraphView (private)

- (UIBezierPath *)pathWithValues:(NSArray *)values;

@end

@implementation BTCGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.graphLayer.frame = self.bounds;
        [self.layer addSublayer:self.graphLayer];
    }
    return self;
}

#pragma mark - Properties

- (CAShapeLayer *)graphLayer {
    if (!_graphLayer) {
        _graphLayer = [CAShapeLayer layer];
        _graphLayer.strokeColor = [UIColor whiteColor].CGColor;
        _graphLayer.backgroundColor = [UIColor clearColor].CGColor;
        _graphLayer.fillColor = [UIColor clearColor].CGColor;
    }
    
    return _graphLayer;
}

- (void)setValues:(NSArray *)values {
    if (_values != values) {
        _values = values;
        
        UIBezierPath *graphPath = [self pathWithValues:values];
        
        CABasicAnimation *graphAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        graphAnimation.fromValue = (id)self.graphLayer.path;
        graphAnimation.toValue = (id)graphPath.CGPath;
        graphAnimation.duration = 1.f;
        
        [self.graphLayer addAnimation:graphAnimation forKey:@"graphAnimation"];
        self.graphLayer.path = graphPath.CGPath;
    }
}

#pragma mark - Private

- (UIBezierPath *)pathWithValues:(NSArray *)values {
    NSNumber *maxValue = [values valueForKeyPath:@"@max.floatValue"];
    
    CGFloat scale = self.bounds.size.height;
    CGFloat xThreshold = self.bounds.size.width / (values.count - 1);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.f;
    
    for (NSInteger i = 0; i < values.count; i++) {
        NSNumber *value = values[i];
        CGFloat normalizedValue = value.floatValue * scale / maxValue.floatValue;
        
        CGFloat x = values.count == 1 ? self.bounds.size.width : xThreshold * i;
        CGPoint graphPoint = CGPointMake(x, self.bounds.size.height - normalizedValue);

        if (values.count == 1) {
            [path moveToPoint:CGPointMake(0, graphPoint.y)];
            [path addLineToPoint:graphPoint];
        } else {
            if (i == 0) {
                [path moveToPoint:graphPoint];
            } else {
                [path addLineToPoint:graphPoint];
            }
        }
    }
    
    return path;
}

@end
