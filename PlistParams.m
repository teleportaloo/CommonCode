//
//  PlistParams.m
//
//  Created by Andy Wallace on 2/18/25.
//
// Copyright 2020 Andrew Wallace
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "PlistParams.h"
#import "Debuglogging.h"
#import <objc/runtime.h>

#define DEBUG_LEVEL_FOR_FILE LogUI

@interface PlistParams ()

// Protected mutable access
@property (nonatomic, retain) NSMutableDictionary *mDict;

@end

@implementation PlistParams

- (instancetype)init {
    if ((self = [super init])) {
        self.dictionary = NSDictionary.dictionary;
    }
    return self;
}

- (instancetype)initMutable {
    if ((self = [super init])) {
        self.mDict = NSMutableDictionary.dictionary;
        self.dictionary = self.mDict;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        self.dictionary = dictionary;
    }
    return self;
}

- (instancetype)initWithMutableDictionary:(NSMutableDictionary *)dictionary {
    if ((self = [super init])) {
        self.dictionary = dictionary;
        self.mDict = dictionary;
    }
    return self;
}

+ (instancetype)make:(NSDictionary *)params {
    PlistParams *obj = [[[self class] alloc] initWithDictionary:params];
    return obj;
}

+ (instancetype)makeMutable:(NSMutableDictionary *)params {
    PlistParams *obj = [[[self class] alloc] initWithMutableDictionary:params];
    return obj;
}

+ (bool)safeBool:(NSObject *)obj def:(bool)def {
    if ([obj isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)obj).boolValue;
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSString *str = ((NSString *)obj);

        if ([str caseInsensitiveCompare:@"YES"] == 0) {
            return TRUE;
        }

        if ([str caseInsensitiveCompare:@"NO"] == 0) {
            return FALSE;
        }
    }
    return def;
}

+ (unsigned long)hexValFromString:(NSString *)str {
    unsigned long long val = 0;
    [[NSScanner scannerWithString:str] scanHexLongLong:&val];
    return (unsigned long)val;
}

+ (void)enumerateMethods:(Class)theClass
                  prefix:(NSString *)prefix
                   block:(void(NS_NOESCAPE ^)(SEL sel, BOOL *stop))block {
    unsigned int methodCount = 0;

    DEBUG_LOG_NSString(NSStringFromClass(theClass));

    Method *methods = class_copyMethodList(theClass, &methodCount);
    BOOL stop;

    for (unsigned int i = 0; i < methodCount; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *methodName = NSStringFromSelector(selector);

        if ([methodName hasPrefix:prefix]) {
            block(selector, &stop);

            if (stop) {
                break;
            }
        }
    }

    free(methods);
}
@end
