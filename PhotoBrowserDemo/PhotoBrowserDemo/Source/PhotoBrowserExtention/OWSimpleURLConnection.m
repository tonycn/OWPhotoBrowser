//
//  OWSimpleURLConnection.m
//  PhotoBrowserDemo
//
//  Created by Jianjun Wu on 4/4/14.
//  Copyright (c) 2014 Jianjun. All rights reserved.
//

#import "OWSimpleURLConnection.h"

@interface OWSimpleURLConnection () <NSURLConnectionDataDelegate>
@property (nonatomic, copy) void(^progressHandler)(NSUInteger totalBytes, NSUInteger receivedBytes);
@property (nonatomic, copy) void(^completionHandler)(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError);
@property (nonatomic, strong, readwrite) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, strong) NSMutableData *receivedData;
@end

@implementation OWSimpleURLConnection

+ (id)OW_asyncRequest:(NSURLRequest *) request
      progressHandler:(void (^)(NSUInteger totalBytes, NSUInteger downloadBytes))progressHanlder
    completionHandler:(void (^)(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError))completionHandler
{
  OWSimpleURLConnection *conn = [[OWSimpleURLConnection alloc] initWithCustomHTTPRequest:request];
  conn.progressHandler = progressHanlder;
  conn.completionHandler = completionHandler;
  return conn;
}

- (id)initWithCustomHTTPRequest:(NSURLRequest *)request
{
  self = [super initWithRequest:request delegate:self];
  return self;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  self.completionHandler(nil, nil, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
  self.httpResponse = response;
  NSString *contentLength = [self.httpResponse.allHeaderFields objectForKey:@"Content-Length"];
  self.totalBytes = [contentLength integerValue];
  self.receivedData = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.receivedData appendData:data];
  self.progressHandler(self.totalBytes, self.receivedData.length);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  self.completionHandler(self, self.receivedData, nil);
}

@end
