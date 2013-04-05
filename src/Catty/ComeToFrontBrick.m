//
//  ComeToFrontBrick.m
//  Catty
//
//  Created by Mattias Rauter on 18.09.12.
//  Copyright (c) 2012 Graz University of Technology. All rights reserved.
//

#import "Cometofrontbrick.h"

@implementation Cometofrontbrick

- (void)performFromScript:(Script*)script
{
    NSLog(@"Performing: %@", self.description);
    
    [self.object comeToFront];
    
    //    float sleepTime = ((float)self.timeToWaitInMilliseconds.intValue)/1000;
    //    NSLog(@"wating for %f seconds", sleepTime);
    //    NSLog(@"---- BEFORE SLEEP -----");
    //    [NSThread sleepForTimeInterval:sleepTime];
    //    NSLog(@"---- AFTER SLEEP ------");
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"ComeToFront"];
}

@end