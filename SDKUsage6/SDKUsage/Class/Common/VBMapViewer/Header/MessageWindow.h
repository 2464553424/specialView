//
//  MessageWindow.h
//  VBMapViewer-SKT
//
//  Created by Leejoohyun on 2014. 1. 7..
//  Copyright (c) 2014년 Virtual Builders. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAPoi;

@interface MessageWindow : UIWindow

-(id)init:(NSString*)text;
-(void)Show;

@end
