/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ABI36_0_0React/attributedstring/AttributedString.h>
#import <ABI36_0_0React/attributedstring/ParagraphAttributes.h>
#import <ABI36_0_0React/core/LayoutConstraints.h>
#import <ABI36_0_0React/graphics/Geometry.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * iOS-specific TextLayoutManager
 */
@interface ABI36_0_0RCTTextLayoutManager : NSObject

- (ABI36_0_0facebook::ABI36_0_0React::Size)
    measureWithAttributedString:
        (ABI36_0_0facebook::ABI36_0_0React::AttributedString)attributedString
            paragraphAttributes:
                (ABI36_0_0facebook::ABI36_0_0React::ParagraphAttributes)paragraphAttributes
              layoutConstraints:
                  (ABI36_0_0facebook::ABI36_0_0React::LayoutConstraints)layoutConstraints;

- (void)drawAttributedString:(ABI36_0_0facebook::ABI36_0_0React::AttributedString)attributedString
         paragraphAttributes:
             (ABI36_0_0facebook::ABI36_0_0React::ParagraphAttributes)paragraphAttributes
                       frame:(CGRect)frame;

- (ABI36_0_0facebook::ABI36_0_0React::SharedEventEmitter)
    getEventEmitterWithAttributeString:
        (ABI36_0_0facebook::ABI36_0_0React::AttributedString)attributedString
                   paragraphAttributes:
                       (ABI36_0_0facebook::ABI36_0_0React::ParagraphAttributes)paragraphAttributes
                                 frame:(CGRect)frame
                               atPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
