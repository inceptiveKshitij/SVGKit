//
//  SKSVGObject.h
//  Demo-OSX
//
//  Created by C.W. Betts on 6/7/13.
//  Copyright (c) 2013 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SKSVGObject <NSObject>

- (NSURL *)svgURL;
- (NSString *)fileName;

@end

@interface SKSVGBundleObject : NSObject <SKSVGObject>

- (id)initWithName:(NSString *)theName;
- (id)initWithName:(NSString *)theName bundle:(NSBundle*)aBundle;

@end

@interface SKSVGURLObject : NSObject <SKSVGObject>

@property (strong, readonly) NSURL *svgURL;

- (id)initWithURL:(NSURL *)aURL;

@end
