//
//  CDRSpecStatusBubble.h
//  Cedar
//
//  Created by Remy Demarest on 28/12/2010.
//  Copyright 2010 NuLayer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDRSpec.h"

@interface CDRSpecStatusBubble : UIView
{
@private
    CDRExampleState _state;
}

@property(nonatomic) CDRExampleState state;

@end
