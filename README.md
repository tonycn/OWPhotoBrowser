OWPhotoBrowser
==============

Light-weight photo browser for iOS.



Features
--------
* Multiple photo browser with UIScrollView
* Photo  popup and dimiss with animations
* Photo zooming supported
* Single tap to dismiss
* Doubale taps to reset photo zooming scale

Demo
----
**Two demo controllers**

* FlickrImagesViewController
* LocalImagesViewController 

**Screen snapshots**

![alt Photo dimissing](https://raw.github.com/tonycn/OWPhotoBrowser/master/PhotoBrowserDemo/snapshots/snapshot-1.jpg)
![alt Progress HUD](https://raw.github.com/tonycn/OWPhotoBrowser/master/PhotoBrowserDemo/snapshots/snapshot-2.jpg)


Usage
-----
**Tap thumbnail to create photo browser with datasource**

    - (void)showFromView:(UIImageView *)view
    {
      OWCustomPhotosDataSource *datasource = [[OWCustomPhotosDataSource alloc] initWithImageURLs:gLargeImages];
      datasource.thumbnailViews = self.imageViews;
      OWPhotoBrowserController *photoBrowser = [[OWPhotoBrowserController alloc] initWithDataSource:datasource];
      [photoBrowser setCurrentPage:[self.imageViews indexOfObject:view]];
      photoBrowser.fromView = view;
      [self presentViewController:photoBrowser
                         animated:view.image ? YES : NO
                       completion:NULL];
    }

** Implement Custom OWPhotoDataSource Protocol 

    - (void)loadImageAtIndex:(NSUInteger)index
                    progress:(PhotoLoadProgress)progress
                    complete:(PhotoLoadComplete)complete
    {
      NSParameterAssert(index < self.imageURLs.count);
      NSParameterAssert(complete);
      NSURL *url = [NSURL URLWithString:self.imageURLs[index]];
      if ([self.loadingConnections objectForKey:url]) {
        return;
      }
      NSURLRequest *req = [NSURLRequest requestWithURL:url];

      __weak typeof(self) weakSelf = self;
      __block OWSimpleURLConnection * connection = nil;
      connection = [OWSimpleURLConnection OW_asyncRequest:req progressHandler:^(NSUInteger totalBytes, NSUInteger receivedBytes) {
        if (progress) {
          progress(receivedBytes * 1.f / totalBytes);
        }
      } completionHandler:^(OWSimpleURLConnection *conn, NSData *data, NSError *connectionError) {
        if (connectionError == nil && conn.httpResponse.statusCode == 200) {
          connection = conn;
          complete([[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale], connectionError);
        }
        [weakSelf.loadingConnections removeObjectForKey:url];
      }];
      [connection start];
      progress(0.f);
      [self.loadingConnections setObject:connection forKey:url];
    }

**Or implement datasource with SDWebImage**

    - (void)loadImageAtIndex:(NSUInteger)index
                    progress:(PhotoLoadProgress)progress
                    complete:(PhotoLoadComplete)complete
    {
      NSParameterAssert(index < self.imageURLs.count);
      NSParameterAssert(complete);

      NSURL *url = [NSURL URLWithString:self.imageURLs[index]];
      SDWebImageManager *manager = [SDWebImageManager sharedManager];
      __weak typeof(self) weakSelf = self;
      __block id<SDWebImageOperation> op = nil;
      op = [manager downloadWithURL:url
                            options:0
                           progress:^(NSInteger receivedSize,
                                      NSInteger expectedSize) {
                             if (progress) {
                               progress(receivedSize * 1.f / expectedSize);
                             }
                           }
                          completed:^(UIImage *image,
                                      NSError *error,
                                      SDImageCacheType cacheType,
                                      BOOL finished) {
                            if (finished) {
                              complete(image);
                            }
                            [weakSelf.loadingOperations removeObject:op];
                          }];
      [self.loadingOperations addObject:op];
    }

    - (BOOL)imageExistedInCacheAtIndex:(NSUInteger)index
    {
      SDWebImageManager *manager = [SDWebImageManager sharedManager];
      NSString *url = self.imageURLs[index];
      if ([manager.imageCache imageFromMemoryCacheForKey:url] != nil) {
        return YES;
      } else if ([manager diskImageExistsForURL:[NSURL URLWithString:url]]) {
        return YES;
      } else {
        return NO;
      }
    }


Releases
--------
**0.1.1**
* Add gap between photo pages
* Compatible with iOS 6.x

**0.1.0**

* Photo browser with zooming
* Photo popup & dimiss animation supported
* A simple demo
