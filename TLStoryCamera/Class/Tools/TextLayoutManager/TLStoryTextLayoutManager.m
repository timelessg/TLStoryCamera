//
//  TLStoryTextLayoutManager.m
//  TLStoryCamera
//
//  Created by GarryGuo on 2017/6/1.
//  Copyright © 2017年 GarryGuo. All rights reserved.
//

#import "TLStoryTextLayoutManager.h"

@interface TLStoryTextLayoutManager()
@property (nonatomic, assign) CGPoint lastDrawPoint;
@end

@implementation TLStoryTextLayoutManager
- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    self.lastDrawPoint = origin;
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    self.lastDrawPoint = CGPointZero;
}

- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        [super fillBackgroundRectArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    
    CGContextSaveGState(ctx);
    
    NSRange glyphRange = [self glyphRangeForCharacterRange:charRange actualCharacterRange:NULL];
    CGPoint textOffset = self.lastDrawPoint;
    
    NSRange lineRange = NSMakeRange(glyphRange.location, 1);
    while (NSMaxRange(lineRange) <= NSMaxRange(glyphRange)) {
        CGRect lineBounds = [self lineFragmentUsedRectForGlyphAtIndex:lineRange.location effectiveRange:&lineRange];
        lineBounds.origin.x += textOffset.x;
        lineBounds.origin.y += textOffset.y;
        
        NSRange glyphRangeInLine = NSIntersectionRange(glyphRange,lineRange);
        NSRange truncatedGlyphRange = [self truncatedGlyphRangeInLineFragmentForGlyphAtIndex:glyphRangeInLine.location];
        if (truncatedGlyphRange.location != NSNotFound) {
            NSRange sameRange = NSIntersectionRange(glyphRangeInLine, truncatedGlyphRange);
            if (sameRange.length > 0 && NSMaxRange(sameRange) == NSMaxRange(glyphRangeInLine)) {
                glyphRangeInLine = NSMakeRange(glyphRangeInLine.location, sameRange.location - glyphRangeInLine.location);
            }
        }
        
        if (glyphRangeInLine.length > 0) {
            CGFloat startDrawY = CGFLOAT_MAX;
            CGFloat maxLineHeight = 0.0f;
            for (NSInteger glyphIndex = glyphRangeInLine.location; glyphIndex < NSMaxRange(glyphRangeInLine); glyphIndex ++) {
                NSInteger charIndex = [self characterIndexForGlyphAtIndex:glyphIndex];
                UIFont *font = [self.textStorage attribute:NSFontAttributeName
                                                   atIndex:charIndex
                                            effectiveRange:nil];
                
                CGPoint location = [self locationForGlyphAtIndex:glyphIndex];
                startDrawY = fmin(startDrawY, lineBounds.origin.y + location.y - font.ascender);
                maxLineHeight = fmax(maxLineHeight, font.lineHeight);
            }
            
            CGSize size = lineBounds.size;
            CGPoint orgin = lineBounds.origin;
            orgin.y = startDrawY;
            size.height = maxLineHeight;
            
            lineBounds.size = size;
            lineBounds.origin = orgin;
        }
        
        CGFloat cornerRadius = 10;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        if (rectCount == 1) {
            CGRect validRect = rectArray[0];
            validRect.origin.y -= 10;
            validRect.origin.x -= 10;
            validRect.size.height += 20;
            validRect.size.width += 20;
            
            CGPathMoveToPoint(path, NULL, CGRectGetMinX(validRect) + cornerRadius * 2, CGRectGetMinY(validRect));
            CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(validRect), CGRectGetMinY(validRect), CGRectGetMaxX(validRect), CGRectGetMinY(validRect) + cornerRadius * 2, cornerRadius);
            CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(validRect), CGRectGetMaxY(validRect), CGRectGetMaxX(validRect) - cornerRadius * 2, CGRectGetMaxY(validRect), cornerRadius);
            CGPathAddArcToPoint(path, NULL, CGRectGetMinX(validRect), CGRectGetMaxY(validRect), CGRectGetMinX(validRect), CGRectGetMaxY(validRect) - cornerRadius * 2, cornerRadius);
            CGPathAddArcToPoint(path, NULL, CGRectGetMinX(validRect), CGRectGetMinY(validRect), CGRectGetMinX(validRect) + cornerRadius * 2, CGRectGetMinY(validRect), cornerRadius);
        }else {
            CGRect firstRect = rectArray[0];
            firstRect.origin.y -= 10;
            firstRect.origin.x -= 10;
            firstRect.size.height += 10;
            firstRect.size.width += 20;
            
            CGRect lastRect = CGRectIntersection(lineBounds, rectArray[rectCount - 1]);
            if (CGRectIsEmpty(lastRect)) {
                lastRect = rectArray[rectCount - 1];
            }
            lastRect.origin.x -= 10;
            lastRect.size.height += 10;
            lastRect.size.width += 20;
            
            if (self.textAlignment == NSTextAlignmentLeft) {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect));
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect), CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect) + cornerRadius * 2, cornerRadius);
                
                if (CGRectGetMaxX(firstRect) - CGRectGetMaxX(lastRect) > cornerRadius * 2) {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMinY(lastRect), CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMinY(lastRect), cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(lastRect), CGRectGetMinY(lastRect), CGRectGetMaxX(lastRect), CGRectGetMinY(lastRect) + cornerRadius * 2, cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(lastRect), CGRectGetMaxY(lastRect), CGRectGetMaxX(lastRect) - cornerRadius * 2, CGRectGetMaxY(lastRect) , cornerRadius);
                }else {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMaxY(lastRect) , cornerRadius);
                }
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect) - cornerRadius * 2, cornerRadius);
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMinY(firstRect), CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect), cornerRadius);
                CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMinY(firstRect));
            }else if (self.textAlignment == NSTextAlignmentRight) {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect));
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect), CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect) + cornerRadius * 2, cornerRadius);
                CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMaxY(lastRect), cornerRadius);
                
                //判断边界
                if (CGRectGetMinX(lastRect) - CGRectGetMinX(firstRect) > cornerRadius * 2) {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(lastRect), CGRectGetMaxY(lastRect), CGRectGetMinX(lastRect), CGRectGetMaxY(lastRect) - cornerRadius * 2, cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(lastRect), CGRectGetMinY(lastRect), CGRectGetMinX(lastRect) - cornerRadius * 2, CGRectGetMinY(lastRect), cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMinY(lastRect), CGRectGetMinX(firstRect), CGRectGetMinY(lastRect) - cornerRadius * 2, cornerRadius);
                }else {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect) - cornerRadius * 2, cornerRadius);
                }
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMinY(firstRect), CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect), cornerRadius);
            }else {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect));
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect), CGRectGetMaxX(firstRect), CGRectGetMinY(firstRect) + cornerRadius * 2, cornerRadius);
                
                if (CGRectGetMaxX(firstRect) - CGRectGetMaxX(lastRect) > cornerRadius * 2) {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMinY(lastRect), CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMinY(lastRect), cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(lastRect), CGRectGetMinY(lastRect), CGRectGetMaxX(lastRect), CGRectGetMinY(lastRect) + cornerRadius * 2, cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(lastRect), CGRectGetMaxY(lastRect), CGRectGetMaxX(lastRect) - cornerRadius * 2, CGRectGetMaxY(lastRect), cornerRadius);
                }else {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMaxX(firstRect) - cornerRadius * 2, CGRectGetMaxY(lastRect), cornerRadius);
                }
                
                if (CGRectGetMinX(lastRect) - CGRectGetMinX(firstRect) > cornerRadius * 2) {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(lastRect), CGRectGetMaxY(lastRect), CGRectGetMinX(lastRect), CGRectGetMaxY(lastRect) - cornerRadius * 2, cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(lastRect), CGRectGetMinY(lastRect), CGRectGetMinX(lastRect) - cornerRadius * 2, CGRectGetMinY(lastRect), cornerRadius);
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMinY(lastRect), CGRectGetMinX(firstRect), CGRectGetMinY(lastRect) - cornerRadius * 2, cornerRadius);
                }else {
                    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect), CGRectGetMinX(firstRect), CGRectGetMaxY(lastRect) - cornerRadius * 2, cornerRadius);
                }
                
                CGPathAddArcToPoint(path, NULL, CGRectGetMinX(firstRect), CGRectGetMinY(firstRect), CGRectGetMinX(firstRect) + cornerRadius * 2, CGRectGetMinY(firstRect), cornerRadius);
            }
        }
        CGContextClearRect(ctx, [[UIScreen mainScreen] bounds]);
        
        CGContextAddPath(ctx, path);
        [color setFill];
        CGContextSetLineWidth(ctx, 0);
        CGPathRelease(path);
        CGContextDrawPath(ctx, kCGPathFill);
        
        lineRange = NSMakeRange(NSMaxRange(lineRange), 1);
    }
    CGContextRestoreGState(ctx);
}
@end
