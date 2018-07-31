//
//  PublicParameters.h
//  okayEducation
//
//  Created by lee on 16/5/31.
//  Copyright © 2016年 OKAY.XDF.CN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicParameters : NSObject
{
    NSMutableDictionary *_parameters;
}
@property (strong ,nonatomic,readonly) NSMutableDictionary *parameters;

- (void)put:(NSObject *)value forKey:(NSString *)key;

@end
