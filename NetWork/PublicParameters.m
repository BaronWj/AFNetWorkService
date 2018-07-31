//
//  PublicParameters.m
//  okayEducation
//
//  Created by lee on 16/5/31.
//  Copyright © 2016年 OKAY.XDF.CN. All rights reserved.
//

#import "PublicParameters.h"
#import "DeviceTool.h"
#import "NSString+Common.h"

@interface PublicParameters ()

@end

@implementation PublicParameters

- (id)init {
    self = [super init];
    if(self){
        _parameters = [[NSMutableDictionary alloc]init];
        [_parameters setObject:[DeviceTool getUA] forKey:@"ua"];
        [_parameters setObject:@"ios" forKey:@"os"];
        [_parameters setObject:[DeviceTool getDeviceVersionCode] forKey:@"vs"];
        [_parameters setObject:[DeviceTool getAppVersionCode] forKey:@"vc"];
        [_parameters setObject:[NSString stringWithFormat:@"%d",[DeviceTool getScreenWidthInPixel]] forKey:@"sw"];
        [_parameters setObject:[NSString stringWithFormat:@"%d",[DeviceTool getScreenHeightInPixel]] forKey:@"sh"];
        [_parameters setObject:[NSString toString:[DeviceTool getSerialCode]] forKey:@"serial"];
        [_parameters setObject:[DeviceTool getUUID] forKey:@"udid"];
        [_parameters setObject:@"okay" forKey:@"channel"];
        [_parameters setObject:[NSNumber numberWithInt:[DeviceTool getNetworkStatus]] forKey:@"contype"];
        [_parameters setObject:@"" forKey:@"imei"];
        [_parameters setObject:@"" forKey:@"imsi"];
        [_parameters setObject:@"" forKey:@"mac"];
    }
    return self;
}

- (void)put:(NSObject *)value forKey:(NSString *)key
{
    if(!value){
        value = @"";
    }
    [_parameters setObject:value forKey:key];
}

@end
