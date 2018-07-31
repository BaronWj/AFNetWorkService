  //
//  AFNetAPIClient.m
//  AFNetworking3
//
//  Created by 潘伟杰 on 16/5/23.
//  Copyright © 2016年 OKAY.XDF.CN. All rights reserved.
//

#import "AFNetAPIClient.h"
#import "NSObject+Common.h"
#import "ApiUrl.h"
#import "ReplaceUnicode.h"
#import "DeviceTool.h"
#import "LFCGzipUtillity.h"
@interface AFNetAPIClient ()

@property (nonatomic,copy)   NSString * url;
@property (nonatomic,assign) NetworkMethod wRequestType;
@property (nonatomic,strong) NSData * Wyqfile_data;
@property (nonatomic,copy)   NSString * Wyqname;
@property (nonatomic,copy)   NSString * Wyqfilename;
@property (nonatomic,copy)   NSString * WyqmimeType;
@property (nonatomic,copy)   id parameters;
@property (nonatomic,copy)   NSDictionary * wHTTPHeader;

@end

@implementation AFNetAPIClient

+ (AFNetAPIClient *)sharedJsonClient {
    static AFNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL_VALUE]];
    });
    
    return _sharedClient;
}


-(void)netWorkReachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                OKAY_LOG(@"未知信号");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                OKAY_LOG(@"手机信号");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                OKAY_LOG(@"wiFi信号");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                OKAY_LOG(@"没有信号");
            }
                break;

            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    //返回类型默认JSON
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    //返回格式
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"text/html",nil];
    //请求格式
    self.requestSerializer=[AFJSONRequestSerializer serializer];
    [self.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [self.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    OKAY_LOG(@"initdayintou:%@",self.requestSerializer);
    return self;
}


- (AFNetAPIClient *(^)(NSString *))setRequest {
    return ^AFNetAPIClient* (NSString * url) {
        self.url = url;
        return self;
    };
}

- (AFNetAPIClient *(^)(NetworkMethod))RequestType {
    return ^AFNetAPIClient* (NetworkMethod type) {
        self.wRequestType = type;

        return self;
    };
}

- (AFNetAPIClient* (^)(id parameters))Parameters {
    return ^AFNetAPIClient* (id parameters) {
        self.parameters = parameters;
        return self;
    };
}
- (AFNetAPIClient *(^)(NSDictionary *))HTTPHeader {
    return ^AFNetAPIClient* (NSDictionary * HTTPHeaderDic) {
        self.wHTTPHeader = HTTPHeaderDic;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSData * file_data))filedata {
    return ^AFNetAPIClient* (NSData * file_data) {
        self.Wyqfile_data = file_data;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * name))name {
    return ^AFNetAPIClient* (NSString * name) {
        self.Wyqname = name;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * filename))filename {
    return ^AFNetAPIClient* (NSString * filename) {
        self.Wyqfilename = filename;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * mimeType))mimeType {
    return ^AFNetAPIClient* (NSString * mimeType) {
        self.WyqmimeType = mimeType;
        return self;
    };
}

- (void)startRequestWithSuccess:(OKResponseSuccess)Success progress:(OKProgress)Progress failure:(OKResponseFail)Fail {

     AFNetAPIClient * manager = [[self class] sharedJsonClient];
    //超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    //设置请求头
    [self setupHTTPHeaderWithManager:manager];
    
    switch (self.wRequestType) {
        case Get: {
            [manager GET:self.url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
//                progress(downloadProgress.fractionCompleted)
                Progress(downloadProgress);//downloadProgress.fractionCompleted
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                OKAY_LOG(@"task:%lu",(unsigned long)task.taskIdentifier);
                NSString * resopnse = [NSString stringWithFormat:@"%@",responseObject];
                OKAY_LOG(@"str:%@", [ReplaceUnicode replaceUnicode:resopnse]);
                id resultMeta = [responseObject valueForKeyPath:@"meta"];
                if (![resultMeta isEqual:[NSNull null]]) {
                    id error = [self handleResponse:resultMeta withUrl:self.url];
                    if (error) {
                        Fail(task,error);
                    }else{
                        Success(task,responseObject);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Post: {
            //字典转json字符串
            NSString * requestJsonStr = [DictTool handleResponseDictionaryToJson:(NSDictionary *)self.parameters];
            //gzip 压缩
            NSData * cgzipdata = [LFCGzipUtillity gzipData:[requestJsonStr dataUsingEncoding:NSUTF8StringEncoding]];
            
//          gzip 解压缩
//          NSData *data2 = [LFCGzipUtillity uncompressZippedData:cgzipdata];
//          NSString *string2 = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
            
             NSURLSessionDataTask *  requestTask = [manager POST:self.url parameters:cgzipdata progress:^(NSProgress * _Nonnull downloadProgress) {
                Progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSString * resopnse = [NSString stringWithFormat:@"%@",responseObject];
                 OKAY_LOG(@"\n requestUrl:%@ \n task:%lu \n response:%@ ",task.currentRequest.URL,(unsigned long)task.taskIdentifier,[ReplaceUnicode replaceUnicode:resopnse]);
                id resultMeta = [responseObject valueForKeyPath:@"meta"];
                if (![resultMeta isEqual:[NSNull null]]) {
                    id error = [self handleResponse:resultMeta withUrl:self.url];
                    if (error) {
                        Fail(task,error);
                    }else{
                        Success(task,responseObject);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
                OKAY_LOG(@"网络回调:======>\n requestUrl:%@ \n task:%lu \n错误信息::%@ ",task.currentRequest.URL,(unsigned long)task.taskIdentifier,[ReplaceUnicode replaceUnicode:error.description]);
                //弹框处理
                [self handleFailureResponse:error withUrl:self.url];
                
            }];
            OKAY_LOG(@"网络请求:======>\n requestUrl:%@ \n task:%lu \n请求header参数:%@ \n 上行参数:\n%@",requestTask.currentRequest.URL,(unsigned long)requestTask.taskIdentifier,self.wHTTPHeader,requestJsonStr);
        }
            break;

        case Put: {
            [manager PUT:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Delete: {
            [manager DELETE:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               Fail(task,error);
            }];
        }
            break;

        default:
            break;
    }


}

-(void)uploadfileWithSuccess:(OKResponseSuccess)Success progress:(OKProgress)Progress failure:(OKResponseFail)Fail {
    AFNetAPIClient * manager = [[self class]sharedJsonClient];
    [manager POST:self.url parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (self.Wyqfile_data!=nil) {   // 图片数据不为空才传递
            [formData appendPartWithFileData:self.Wyqfile_data name:self.Wyqname fileName:self.Wyqfilename mimeType:self.WyqmimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        Progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString * resopnse = [NSString stringWithFormat:@"%@",responseObject];
        OKAY_LOG(@"str:%@", [ReplaceUnicode replaceUnicode:resopnse]);
        id resultMeta = [responseObject valueForKeyPath:@"meta"];
        if (![resultMeta isEqual:[NSNull null]]) {
            id error = [self handleResponse:resultMeta withUrl:self.url];
            if (error) {
                Fail(task,error);
            }else{
                Success(task,responseObject);
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Fail(task,error);
        [self showError:error];
    }];
}

-(NSURLSessionDownloadTask *)downloadWithSuccess:(OKFileSuccess)WSuccess progress:(OKProgress)Progress failure:(OKResponseFail)Fail {
    AFNetAPIClient * manager = [[self class]sharedJsonClient];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        Progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存文件url (可自己改)
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSURL *fileUrl = [NSURL fileURLWithPath:cachesPath];

        return [fileUrl URLByAppendingPathComponent:[response suggestedFilename]];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            Fail(nil,error);
        }
        else{
            WSuccess(response,filePath);
        }
    }];
    [downloadtask resume];
    return  downloadtask;
}

- (AFNetAPIClient *)setupHTTPHeaderWithManager:(AFNetAPIClient *)manager {
    for (NSString * key in self.wHTTPHeader.allKeys) {
        [manager.requestSerializer setValue:self.wHTTPHeader[key] forHTTPHeaderField:key];
    }
    return manager;
}

- (void)cancelAllRequest {

    [self.operationQueue cancelAllOperations];
}

#pragma mark - https认证
- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"]; //证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];

    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];

    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;

    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    NSSet * set = [NSSet setWithObject:certData];
    securityPolicy.pinnedCertificates = set;

    return securityPolicy;
}


@end
