/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */


#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "UIDefines.h"
#import "LanguageTranslationDefines.h"
#import "BrickProtocol.h"
#import "CBMutableCopying.h"

@class Brick;
@class SpriteObject;
@class GDataXMLElement;

@interface Script : SKNode <ScriptProtocol, CBMutableCopying>

@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, readonly) kBrickCategoryType brickCategoryType;
@property (nonatomic, readonly) kBrickType brickType;
@property (nonatomic, strong, readonly) NSString *brickTitle;
@property (nonatomic, weak) SpriteObject *object;
@property (strong, nonatomic) NSMutableArray *brickList;
@property (nonatomic, getter=isAnimated) BOOL animate;

- (BOOL)isSelectableForObject;

- (BOOL)isAnimateable;

- (void)addBrick:(Brick*)brick atIndex:(NSUInteger)index;

- (void)computeSequenceList;

- (void)start;

- (void)selfBroadcastRestart; // should only be used for self-broadcasts

- (void)restart;

- (void)stop;

- (NSString*)description;

- (BOOL)isEqualToScript:(Script*)script;

- (void)removeFromObject;

- (void)removeReferences;

@end
