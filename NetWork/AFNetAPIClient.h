//
//  AFNetAPIClient.h
//  AFNetworking3
//
//  Created by 潘伟杰 on 16/5/23.
//  Copyright © 2016年 OKAY.XDF.CN. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>


//请求方式
typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;


//请求错误码
typedef enum {
    //以下是枚举成员,
    APP_OK = 0,//成功
    APP_NSURLINVAILD= 101,    //一个页面没有被完全加载之前收到下一个请求，此时迅速会出现此error,error=-999
    APP_WebkitErrorDomain = 102,//帧框加载已中断
    APP_NSURLError_404= 404,
    APP_NSURLErrorCancelled= -999,    //一个页面没有被完全加载之前收到下一个请求，此时迅速会出现此error,error=-999
    APP_NETWORKUNFONDHOST =-1003, //未找到指定服务器
    APP_NETWOROUTTIME = -1001, //请求超时
    APP_NETWORKSECURITY= -1005,// 网络安全
    APP_NETWORKFAILE= -1009,// 网络失败失败
    APP_H5_WEBVIEW_JUMP =1003,//h5 跳转
    APP_ERROR_H5_GETPERSONAL =1004,
    APP_ERROR_H5_SHARE =1005,
    APP_H5_GET_USER_INFO = 1006,//获取用户信息
    APP_ERROR_H5_TOKEN_INVALID =1001,//token失效
    APP_CREATEVIEWCONTROLLER = 1200,//列表页
    APP_DIND_SUBSCRIBE = 1201,//订阅成功
    APP_FREEREAD = 1202,//免费试读
    APP_FINDDETAIL_WEBCALLAPP_PLAY = 1300,//专栏详情播放
    APP_FIND_WEBCALLAPP_PLAY = 1301,//专栏列表播放
    APP_FAIL = 40000,//失败
    APP_ERROR_GENER ,//服务器开小差了，请您稍后再试
    APP_ERROR_PARAM, //参数错误
    APP_ERROR_TOKEN_INVALID =40003,//token失效
    APP_ERROR_VALIDATE_MANY_TIMES = 40014, //频繁获取验证码
    APP_ERROR_ADDRESSBOOK_NOMESSAGE = 40017, //没有查询到对应的信息

    APP_ERROR_NOT_BIND_STUDENT = 40024, //"未绑定学生
    APP_ALREADY_SUB = 40025,//已订阅
    APP_ERROR_TOKEN_RELOGIN = 40032,//您的帐号在别处登录
    APP_ERROR_TOKEN_TIMEOUT = 40033,//长时间未登录
    APP_ERROR_SPECIAL_COLIUM =40035,//专栏下架
    APP_WXALREADYLOGIN = 40036,//微信已绑定
    Pay_Success_Back = 4003//支付返回首页
}  OkErrCode;//枚举名称

/**
 *  请求成功所走方法
 *
 *  @param response  请求返还的数据
 */
typedef void (^OKResponseSuccess)(NSURLSessionDataTask * task,id responseObject);
/**
 *  请求错误所走方法
 *
 *  @param error 请求错误返还的信息
 */
typedef void (^OKResponseFail)(NSURLSessionDataTask * task, NSError * error);
/**
 *  进度条
 *
 *  @param progress progress
 */
typedef void (^OKProgress)(NSProgress *progress);
/**
 *  上传文件成功回调
 *
 *  @param response response
 *  @param filePath filePath
 */
typedef void(^OKFileSuccess)(NSURLResponse * response,NSURL * filePath);

@interface AFNetAPIClient : AFHTTPSessionManager

+ (AFNetAPIClient *)sharedJsonClient;//单例
/**
 *  网络壮态
 */
-(void)netWorkReachability;

/**
 *  @method      请求网址
 */
- (AFNetAPIClient* (^)(NSString * url))setRequest;

/**
 *  @method      请求类型，默认为GET
 */
- (AFNetAPIClient* (^)(NetworkMethod type))RequestType;
/**
 *  @method      请求参数
 */
- (AFNetAPIClient* (^)(id parameters))Parameters;
/**
 *  @method      请求头
 */
- (AFNetAPIClient* (^)(NSDictionary * HTTPHeaderDic))HTTPHeader;

//................................下面是上传文件.................//
/**
 *  上传的文件NSData
 */
- (AFNetAPIClient* (^)(NSData * file_data))filedata;
/**
 *  上传的文件的参数名
 */
- (AFNetAPIClient* (^)(NSString * name))name;
/**
 *  上传的文件的文件名（要有后缀名）
 */
- (AFNetAPIClient* (^)(NSString * filename))filename;
/**
 *  上传的文件的文件类型
 */
- (AFNetAPIClient* (^)(NSString * mimeType))mimeType;

//................................end.................//
/**
 *  发送请求
 *
 *  @param Success  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的回调
 */
- (void)startRequestWithSuccess:(OKResponseSuccess)Success progress:(OKProgress)Progress failure:(OKResponseFail)Fail;
/**
 *  上传文件
 *
 *  @param Success  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的
 */
-(void)uploadfileWithSuccess:(OKResponseSuccess)Success progress:(OKProgress)Progress failure:(OKResponseFail)Fail;
/**
 *  下载文件
 *
 *  @param WSuccess  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，重新开启下载调用resume方法
 */
-(NSURLSessionDownloadTask *)downloadWithSuccess:(OKFileSuccess)WSuccess progress:(OKProgress)Progress failure:(OKResponseFail)Fail;

/**
 *  取消所有网络请求
 */
- (void)cancelAllRequest;


@end
