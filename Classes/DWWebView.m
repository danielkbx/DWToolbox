//
//  DWWebView.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 16.11.11.
//  Copyright (c) 2011 danielkbx. All rights reserved.
//

#import "DWWebView.h"

#import "UIDevice+DWToolbox.h"
#import "Log.h"

@interface DWWebView() {

}

@property (nonatomic, readwrite, copy) NSURL *URL;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation DWWebView

@synthesize URL = lastURL_;

@synthesize numberOfRunningRequest = numberOfRunningRequest_;

+ (BOOL)enableRemoteDebugging
{
	if ([UIDevice currentDevice].isIOS5OrLater)
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		SEL selector = NSSelectorFromString(@"_enableRemoteInspector");
		Class WebViewClass = NSClassFromString(@"WebView");
		[WebViewClass performSelector:selector];
#pragma clang diagnostic pop
		return YES;
	}
	return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
		self.webView = [[UIWebView alloc] initWithFrame:self.bounds];
		self.webView.delegate = self;
		self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.webView];
		
    }
    return self;
}

- (void)setHeaderView:(UIView *)headerView {
	
	[self.headerView removeFromSuperview];
	self.webView.scrollView.contentOffset = CGPointZero;
	
	self->_headerView = headerView;
	
	[self.webView.scrollView addSubview:headerView];
	
	CGFloat headerHeight = headerView.frame.size.height;
	self.headerView.frame = (CGRect){{0.0f,0 - headerHeight,},self.headerView.frame.size};
	self.webView.scrollView.contentInset =  UIEdgeInsetsMake(headerHeight, 0.0f, 0.0f, 0.0f);
}

#pragma mark - Loading

- (void)loadURL:(NSURL *)url {
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	self.URL = url;
	[self.webView loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)request
{
	self.URL = request.URL;
	[self.webView loadRequest:request];
}

- (void)loadHTML:(NSString *)html baseURL:(NSURL *)baseURL {
	self.URL = nil;
	[self.webView loadHTMLString:html baseURL:baseURL];
}

#pragma mark - JS Injection

- (NSString *)injectJavascript:(NSString *)javscript
{
	return [self.webView stringByEvaluatingJavaScriptFromString:javscript];
}

- (NSString *)injectJavascriptFromFile:(NSString *)javscriptFile
{
	if (javscriptFile)
	{
		NSError *error = nil;
		NSString *javascript = [NSString stringWithContentsOfFile:javscriptFile
														 encoding:NSUTF8StringEncoding
															error:&error];
		if (error == nil && [javascript length] > 0)
		{
			return [self injectJavascript:javascript];
		}
	}
	return nil;
}

#pragma mark - WebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *scheme = [request.URL scheme];
	BOOL shouldStart = YES;
	
	if (![scheme hasPrefix:@"http"])
	{
		if ([self.delegate respondsToSelector:@selector(webView:shouldHandleRequestWithURL:)])
		{
			shouldStart = [self.delegate webView:self shouldHandleRequestWithURL:request.URL];
		}
	}
	
	if (shouldStart)
	{
		
		DWLog(@"Webview requests %@",request.URL);
		if (navigationType == UIWebViewNavigationTypeLinkClicked)
		{
			self.URL = request.URL;
		}
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	self->numberOfRunningRequest_++;
	[[UIDevice currentDevice] addNetworkActivity];
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (self->numberOfRunningRequest_ > 0)
	{
		self->numberOfRunningRequest_--;
	}
	if (self->numberOfRunningRequest_ == 0)
	{
		if ([self.delegate respondsToSelector:@selector(webView:didFinishLoadingOfURL:)])
		{
			[self.delegate webView:self didFinishLoadingOfURL:self.URL];
		}
	}
	[[UIDevice currentDevice] removeNetworkActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	if (self->numberOfRunningRequest_ > 0)
	{
		self->numberOfRunningRequest_--;
	}
	[[UIDevice currentDevice] removeNetworkActivity];
	DWLog(@"Webview did fail to load a resource: %@",error.description);
}

- (BOOL)isLoading {
	return (self.numberOfRunningRequest > 0);
}


#pragma mark - Property relaying

- (void)setScalesPageToFit:(BOOL)scalesPageToFit {
	self.webView.scalesPageToFit = scalesPageToFit;
}

- (BOOL)scalesPageToFit {
	return self.webView.scalesPageToFit;
}

@end
