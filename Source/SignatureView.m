//
//  SignatureView.m
//  SignatureView
//
//  Created by Michal Konturek on 05/05/2014.
//  Copyright (c) 2014 Michal Konturek. All rights reserved.
//

#import "SignatureView.h"

@interface SignatureView ()

@property (nonatomic, strong) NSMutableArray *drawnPoints;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, strong) UIImage *tempImage;

@property (nonatomic, assign) BOOL blank;

@end

@implementation SignatureView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)_initialize {
    
    self.userInteractionEnabled = YES;
    self.blank = YES;
    
    [self _setupDefaultValues];
    [self _initializeRecognizer];
}

- (void)_setupDefaultValues {
    self.foregroundLineColor = [UIColor redColor];
    self.foregroundLineWidth = 3.0;
    
    self.backgroundLineColor = [UIColor blackColor];
    self.backgroundLineWidth = 3.0;
}

- (void)_initializeRecognizer {
    id recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(clear)];
    self.recognizer = recognizer;
    [self addGestureRecognizer:recognizer];
}

- (void)setLineColor:(UIColor *)color {
    self.foregroundLineColor = color;
    self.backgroundLineColor = color;
}

- (void)setLineWidth:(CGFloat)width {
    self.backgroundLineWidth = width;
    self.foregroundLineWidth = width;
}

- (void)clear {
    self.blank = YES;
    
    [self clearWithColor:[UIColor whiteColor]];
    [self clearWithColor:[UIColor clearColor]];
}

- (void)clearWithColor:(UIColor *)color {
    CGSize screenSize = self.frame.size;
    
    UIGraphicsBeginImageContext(screenSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, screenSize.width, screenSize.height));
    
    UIImage *cleanImage = UIGraphicsGetImageFromCurrentImageContext();
    self.image = cleanImage;
    
    UIGraphicsEndImageContext();
}

- (BOOL)isSigned {
    return !self.blank;
}

- (UIImage *)signatureImage {
    return [self.image copy];
}

- (NSData *)signatureData {
    return UIImagePNGRepresentation(self.image);
}


#pragma mark - Touch handlers

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint currentPoint = [self _touchPointForTouches:touches];
    self.drawnPoints = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:currentPoint]];
    self.previousPoint = currentPoint;
    
    /*
     To be able to replace the jagged polylines with the smooth
     polylines, we need to save the unmodified image.
     */
    self.tempImage = self.image;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint currentPoint = [self _touchPointForTouches:touches];
    [self.drawnPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    self.image = [self _drawLineFromPoint:self.previousPoint toPoint:currentPoint image:self.image];
    self.previousPoint = currentPoint;
    
    self.blank = NO;
}

- (CGPoint)_touchPointForTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    return point;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *generalizedPoints = [self _douglasPeucker:self.drawnPoints epsilon:2];
    NSArray *splinePoints = [self _catmullRomSpline:generalizedPoints segments:4];
    
    self.image = [self _drawLineWithPoints:splinePoints image:self.tempImage];
    
    self.drawnPoints = nil;
    self.tempImage = nil;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


#pragma mark - Drawing

- (UIImage *)_drawLineFromPoint:(CGPoint)fromPoint
                        toPoint:(CGPoint)toPoint image:(UIImage *)image {
    
    CGSize screenSize = self.frame.size;
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(screenSize);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, self.foregroundLineWidth);
    CGContextSetStrokeColorWithColor(context, self.foregroundLineColor.CGColor);
	
    CGContextBeginPath(context);
    
	CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
	CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
	CGContextStrokePath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage *)_drawLineWithPoints:(NSArray *)points image:(UIImage *)image {
    
    CGSize screenSize = self.frame.size;
    
    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(screenSize);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetLineCap(context, kCGLineCapRound);
	CGContextSetLineWidth(context, self.backgroundLineWidth);
    CGContextSetStrokeColorWithColor(context, self.backgroundLineColor.CGColor);
    
	CGContextBeginPath(context);
    
    NSInteger count = [points count];
    CGPoint point = [[points objectAtIndex:0] CGPointValue];
	CGContextMoveToPoint(context, point.x, point.y);
    for(int i = 1; i < count; i++) {
        point = [[points objectAtIndex:i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    CGContextStrokePath(context);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return result;
}


#pragma mark - Smoothing Alrgorithms

- (NSArray *)_douglasPeucker:(NSArray *)points epsilon:(float)epsilon {
    
    NSInteger count = [points count];
    if(count < 3) return points;
    
    //Find the point with the maximum distance
    float dmax = 0;
    int index = 0;
    for(int i = 1; i < count - 1; i++) {
        CGPoint point = [[points objectAtIndex:i] CGPointValue];
        CGPoint lineA = [[points objectAtIndex:0] CGPointValue];
        CGPoint lineB = [[points objectAtIndex:count - 1] CGPointValue];
        float d = [self _perpendicularDistance:point lineA:lineA lineB:lineB];
        if(d > dmax) {
            index = i;
            dmax = d;
        }
    }
    
    // If max distance is greater than epsilon, recursively simplify
    NSArray *resultList;
    if(dmax > epsilon) {
        NSArray *recResults1 = [self _douglasPeucker:[points subarrayWithRange:NSMakeRange(0, index + 1)]
                                             epsilon:epsilon];
        
        NSArray *recResults2 = [self _douglasPeucker:[points subarrayWithRange:NSMakeRange(index, count - index)]
                                             epsilon:epsilon];
        
        NSMutableArray *tmpList = [NSMutableArray arrayWithArray:recResults1];
        [tmpList removeLastObject];
        [tmpList addObjectsFromArray:recResults2];
        resultList = tmpList;
    } else {
        resultList = [NSArray arrayWithObjects:[points objectAtIndex:0], [points objectAtIndex:count - 1],nil];
    }
    
    return resultList;
}

- (float)_perpendicularDistance:(CGPoint)point
                          lineA:(CGPoint)lineA lineB:(CGPoint)lineB {
    
    CGPoint v1 = CGPointMake(lineB.x - lineA.x, lineB.y - lineA.y);
    CGPoint v2 = CGPointMake(point.x - lineA.x, point.y - lineA.y);
    
    float lenV1 = sqrt(v1.x * v1.x + v1.y * v1.y);
    float lenV2 = sqrt(v2.x * v2.x + v2.y * v2.y);
    float angle = acos((v1.x * v2.x + v1.y * v2.y) / (lenV1 * lenV2));
    
    return sin(angle) * lenV2;
}

- (NSArray *)_catmullRomSpline:(NSArray *)points segments:(int)segments {

    NSInteger count = [points count];
    if(count < 4) return points;
    
    float b[segments][4];
    {
        // precompute interpolation parameters
        float t = 0.0f;
        float dt = 1.0f/(float)segments;
        for (int i = 0; i < segments; i++, t+=dt) {
            float tt = t*t;
            float ttt = tt * t;
            b[i][0] = 0.5f * (-ttt + 2.0f*tt - t);
            b[i][1] = 0.5f * (3.0f*ttt -5.0f*tt +2.0f);
            b[i][2] = 0.5f * (-3.0f*ttt + 4.0f*tt + t);
            b[i][3] = 0.5f * (ttt - tt);
        }
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    {
        int i = 0; // first control point
        [resultArray addObject:[points objectAtIndex:0]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = (b[j][0]+b[j][1])*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = (b[j][0]+b[j][1])*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    for (int i = 1; i < count - 2; i++) {
        // the first interpolated point is always the original control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            CGPoint pointIp2 = [[points objectAtIndex:(i + 2)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + b[j][2]*pointIp1.x + b[j][3]*pointIp2.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + b[j][2]*pointIp1.y + b[j][3]*pointIp2.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    {
        NSInteger i = count - 2; // second to last control point
        [resultArray addObject:[points objectAtIndex:i]];
        for (int j = 1; j < segments; j++) {
            CGPoint pointIm1 = [[points objectAtIndex:(i - 1)] CGPointValue];
            CGPoint pointI = [[points objectAtIndex:i] CGPointValue];
            CGPoint pointIp1 = [[points objectAtIndex:(i + 1)] CGPointValue];
            float px = b[j][0]*pointIm1.x + b[j][1]*pointI.x + (b[j][2]+b[j][3])*pointIp1.x;
            float py = b[j][0]*pointIm1.y + b[j][1]*pointI.y + (b[j][2]+b[j][3])*pointIp1.y;
            [resultArray addObject:[NSValue valueWithCGPoint:CGPointMake(px, py)]];
        }
    }
    
    // the very last interpolated point is the last control point
    [resultArray addObject:[points objectAtIndex:(count - 1)]];
    
    return resultArray;
}

@end
