//
//  PlistParams.h
//
//  Created by Andy Wallace on 2/18/25.
//

// Copyright 2025 Andrew Wallace
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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlistParams : NSObject

- (instancetype)init;
- (instancetype)initMutable;

+ (instancetype)make:(NSDictionary *)params;
+ (instancetype)makeMutable:(NSMutableDictionary *)params;

+ (bool)safeBool:(NSObject *)obj def:(bool)def;
+ (unsigned long)hexValFromString:(NSString *)str;

+ (void)enumerateMethods:(Class)theClass
                  prefix:(NSString *)prefix
                   block:(void(NS_NOESCAPE ^)(SEL sel, BOOL *stop))block;

@property(nonatomic, retain) NSDictionary *dictionary;

@end

NS_ASSUME_NONNULL_END
