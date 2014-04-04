//
//  OWSimpleURLConnection.h
//  PhotoBrowserDemo
//
//  Created by Jianjun Wu on 4/4/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWSimpleURLConnection : NSURLConnection

@property (nonatomic, strong, readonly) NSHTTPURLResponse *httpResponse;

+ (id)OW_asyncRequest:(NSURLRequest *) request
      progressHandler:(void (^)(NSUInteger totalBytes, NSUInteger receivedBytes)) progressHanlder
    completionHandler:(void (^)(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError)) completionHandler;
@end
