//
//  DWWebView.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 16.11.11.
//

#import <UIKit/UIKit.h>

@protocol DWWebViewDelegate;

@interface DWWebView : UIView <UIWebViewDelegate>

@property (nonatomic, assign) id <DWWebViewDelegate> delegate;
@property (nonatomic, readonly, copy) NSURL *URL;

@property (nonatomic, readonly) NSUInteger numberOfRunningRequest;

@property(nonatomic) BOOL scalesPageToFit;

+ (BOOL)enableRemoteDebugging;

- (void)loadURL:(NSURL *)url;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTML:(NSString *)html baseURL:(NSURL *)baseURL;

- (void)injectJavascript:(NSString *)javscript;
- (void)injectJavascriptFromFile:(NSString *)javscriptFile;

@end

@protocol DWWebViewDelegate <NSObject>

@optional

- (void)webView:(DWWebView *)webView didFinishLoadingOfURL:(NSURL *)URL;
- (BOOL)webView:(DWWebView *)webView shouldHandleRequestWithURL:(NSURL *)URL;

@end