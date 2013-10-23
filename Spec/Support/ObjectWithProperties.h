//
//  ObjectWithProperties.h
//  Cedar
//
//  Created by Paul Taykalo on 10/23/13.
//
//

#import <Foundation/Foundation.h>

@interface ObjectWithProperties : NSObject

@property(nonatomic, assign) CGFloat floatProperty;
@property(nonatomic, copy) NSString * stringProperty;
@property(nonatomic, strong) id objectProperty;

@end
