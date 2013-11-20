//
//  BTCGraphView.m
//  Ticker
//
//  Created by Mert Dümenci on 19/11/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "BTCGraphView.h"

@interface BTCGraphView (private)

- (void)sizeToFitDescriptiveLabels;
- (UIBezierPath *)pathWithValues:(NSArray *)values;

@end

@implementation BTCGraphView {
    UILabel *_maxLabel;
    UILabel *_minLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.graphLayer.frame = self.bounds;
        [self.layer addSublayer:self.graphLayer];
        
        _maxLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, 20)];
        _minLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.size.height - 20, 50, 20)];
        
        _maxLabel.backgroundColor = _minLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        _maxLabel.textColor = _minLabel.textColor = [UIColor blackColor];
        _maxLabel.font = _minLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.f];
        _maxLabel.layer.cornerRadius = _minLabel.layer.cornerRadius = 3.f;
        _maxLabel.textAlignment = _minLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:_minLabel];
        [self addSubview:_maxLabel];
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
        
        _minLabel.text = [[values valueForKeyPath:@"@min.integerValue"] stringValue];
        _maxLabel.text = [[values valueForKeyPath:@"@max.integerValue"] stringValue];
        
        [self sizeToFitDescriptiveLabels];
    
        UIBezierPath *graphPath = [self pathWithValues:values];
        
        CATransition *graphFade = [CATransition animation];
        [graphFade setDuration:0.3];
        [graphFade setType:kCATransitionFade];
        [graphFade setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self.graphLayer addAnimation:graphFade forKey:kCATransitionFade];
        self.graphLayer.path = graphPath.CGPath;
    }
}

#pragma mark - Private

- (void)sizeToFitDescriptiveLabels {
    [_minLabel sizeToFit];
    [_maxLabel sizeToFit];
    
    _minLabel.frame = CGRectMake(_minLabel.frame.origin.x, _minLabel.frame.origin.y, _minLabel.frame.size.width + 5, _minLabel.frame.size.height);
    _maxLabel.frame = CGRectMake(_maxLabel.frame.origin.x, _maxLabel.frame.origin.y, _maxLabel.frame.size.width + 5, _maxLabel.frame.size.height);
}

- (UIBezierPath *)pathWithValues:(NSArray *)values {
    CGFloat maxValue = [[values valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat minValue = [[values valueForKeyPath:@"@min.floatValue"] floatValue];
    
    CGFloat scale = 1.f;
    CGFloat xThreshold = self.bounds.size.width / (values.count - 1);
    
    CGPoint graphPoint = CGPointZero;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1.f;
    
    if (maxValue == minValue) {
        graphPoint = CGPointMake(self.frame.size.width, self.frame.size.height / 2);
        
        [path moveToPoint:CGPointMake(0, graphPoint.y)];
        [path addLineToPoint:graphPoint];
    } else {
        for (NSInteger i = 0; i < values.count; i++) {
            CGFloat value = [values[i] floatValue];
            CGFloat normalizedValue = ((value - minValue) * (self.bounds.size.height * scale)) / (MAX(maxValue - minValue, 1));
            
            CGFloat x = values.count == 1 ? self.bounds.size.width : xThreshold * i;
            graphPoint = CGPointMake(x, self.bounds.size.height - normalizedValue);
            
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
    }
    
    return path;
}

@end
