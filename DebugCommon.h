//
//  DebugCommon.h
//
//  Created by Andrew Wallace on 4/18/20.
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

#ifndef DebugCommon_h
#define DebugCommon_h

#ifdef DEBUGLOGGING

#if defined __cplusplus
extern "C" {
#else
#import <Foundation/Foundation.h>
#endif

extern long CommonDebugLogLevel(void);
extern const char *CommonDebugLogStr(debugLogLevel level);
extern void CommonDebugAssert(void);

#if defined __cplusplus
};
#endif

#define DEBUG_BLOCK(X)                                                         \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        void (^block)(void) = (X);                                             \
        block();                                                               \
    }
#define DEBUG_ON_FOR_FILE ((CommonDebugLogLevel() & DEBUG_LEVEL_FOR_FILE))
#define DEBUG_AND(X) (DEBUG_ON_FOR_FILE) ? ((X)) : (FALSE)

#define DEBUG_LOG_PREFIX @"<%-12s:%s:%d> "
#define DEBUG_LOG_PREFIX_VALS                                                  \
    CommonDebugLogStr(DEBUG_LEVEL_FOR_FILE), __func__, __LINE__

#define DEBUG_LOG(s, ...)                                                      \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        NSLog(DEBUG_LOG_PREFIX @"%@", DEBUG_LOG_PREFIX_VALS,                   \
              [NSString stringWithFormat:(s), ##__VA_ARGS__]);                 \
    }
#define DEBUG_PRINTF(format, args...)                                          \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        printf(format, ##args);                                                \
    }
#define ASSERT(X)                                                              \
    if (!(X)) {                                                                \
        NSLog(@"ASSERTION Failed: " @ #X);                                     \
        CommonDebugAssert();                                                   \
        raise(SIGINT);                                                         \
    }
#define DEBUG_MODE @" debug"

#define DEBUG_LOG_MAYBE(C, S, ...)                                             \
    if (DEBUG_ON_FOR_FILE && (C)) {                                            \
        NSLog(DEBUG_LOG_PREFIX @"%@", DEBUG_LOG_PREFIX_VALS,                   \
              [NSString stringWithFormat:(S), ##__VA_ARGS__]);                 \
    }

#else

#define DEBUG_BLOCK(X)
#define DEBUG_ON_FOR_FILE (FALSE)
#define DEBUG_LOG(s, ...)
#define DEBUG_PRINTF(format, args...)
#define ASSERT(X)
#define DEBUG_MODE @""
#define DEBUG_LOG_MAYBE(C, S, ...)
#define DEBUG_AND(X) (false)

#endif

#define DEBUG_HERE() DEBUG_LOG(@"here")
#define DEBUG_LOG_RAW(s, ...)                                                  \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        NSLog(s, ##__VA_ARGS__);                                               \
    }
#define ERROR_LOG(s, ...)                                                      \
    NSLog(@"<%s:%d> %@", __func__, __LINE__,                                   \
          [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define WARNING_LOG(s, ...)                                                    \
    {                                                                          \
        NSLog(@"**** WARNING **** <%s:%d> %@", __func__, __LINE__,             \
              [NSString stringWithFormat:(s), ##__VA_ARGS__]);                 \
    }

#define DEBUG_ITEM_PREFIX @"%-20s "
#define DEBUG_LOG_BOOL(B)                                                      \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #B, (B) ? @"True" : @"False")
#define DEBUG_LOG_CGRect(X)                                                    \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"(%g, %g) -> (%g, %g) (%g, %g)", #X,          \
              (X).origin.x, (X).origin.y, (X).origin.x + (X).size.width,       \
              (X).origin.y + (X).size.height, (X).size.width, (X).size.height)
#define DEBUG_LOG_CGSize(X)                                                    \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #X, NSStringFromCGSize(X))
#define DEBUG_LOG_NSString(X) DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #X, X)
#define DEBUG_LOG_CGPoint(X)                                                   \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #X, NSStringFromCGPoint(X))
#define DEBUG_LOG_CGFloat(X)                                                   \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%g", #X, (CGFloat)(X))
#define DEBUG_LOG_double(X) DEBUG_LOG(DEBUG_ITEM_PREFIX @"%f", #X, (double)(X))
#define DEBUG_LOG_long(X) DEBUG_LOG(DEBUG_ITEM_PREFIX @"%ld", #X, (long)(X))
#define DEBUG_LOG_ulong(X)                                                     \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%lu", #X, (unsigned long)(X))
#define DEBUG_LOG_longX(X) DEBUG_LOG(DEBUG_ITEM_PREFIX @"0x%lx", #X, (long)(X))
#define DEBUG_LOG_NSDate(X)                                                    \
    {                                                                          \
        NSDateFormatter *formatter = [NSDateFormatter new];                    \
        formatter.locale =                                                     \
            [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];              \
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];             \
        DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #X,                                 \
                  [formatter stringFromDate:(X)]);                             \
    }
#define DEBUG_LOG_ADDRESS(X) DEBUG_LOG(DEBUG_ITEM_PREFIX @"%p", #X, (X))
#define DEBUG_LOG_DebugString(X)                                               \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%s", #X, (X).DebugString())
#define DEBUG_LOG_UIEdgeInsets(X)                                              \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%g, %g, %g, %g", #X, (X).top, (X).left,      \
              (X).bottom, (X).right)
#define LOG_NSError(error)                                                     \
    if (error) {                                                               \
        ERROR_LOG(@"NSError: %@\n", error.description);                        \
    }
#define LOG_NSError_info(error, S, ...)                                        \
    if (error) {                                                               \
        ERROR_LOG(@"NSError: %@\n %@", error.description,                      \
                  [NSString stringWithFormat:(S), ##__VA_ARGS__]);             \
    }
#define DEBUG_FUNC() DEBUG_LOG(@"enter")
#define DEBUG_FUNCEX() DEBUG_LOG(@"exit")
#define DEBUG_LOG_description(X)                                               \
    DEBUG_LOG(DEBUG_ITEM_PREFIX @"%@", #X, (X).description)
#define DEBUG_LOG_class(X) DEBUG_LOG(@"%s: %s", #X, object_getClassName(X))
#define DEBUG_LOG_NSIndexPath(I)                                               \
    DEBUG_LOG(@"%s: section %d row %d", #I, (int)((I).section), (int)((I).row));

// For the log level name, wee store a malloced padded cstring into NSData
// that would free it, but it will never get around to freeing it.
#define DEBUG_LOG_LEVEL_1(X)                                                   \
    {                                                                          \
        logLevel |= X;                                                         \
        const char *str =                                                      \
            [[NSString stringWithFormat:@"%-12s", #X] UTF8String];             \
        debugLevelNames[@(X)] = [NSData dataWithBytesNoCopy:strdup(str)        \
                                                     length:strlen(str) + 1    \
                                               freeWhenDone:YES];              \
                                                                               \
        NSLog(@"    Log 0x%04x %s", (unsigned int)X,                           \
              (const char *)debugLevelNames[@((NSInteger)X)].bytes);           \
    }

#define DEBUG_LOG_LEVEL_0(X)

#ifdef DEBUGLOGGING

#define DEBUG_LOG_LEVELS(B)                                                    \
    static NSMutableDictionary<NSNumber *, NSData *> *debugLevelNames = nil;   \
    const char *CommonDebugLogStr(debugLogLevel level) {                       \
        return (const char *)debugLevelNames[@((NSInteger)level)].bytes;       \
    }                                                                          \
    long CommonDebugLogLevel() {                                               \
        static NSInteger logLevel = 0;                                         \
                                                                               \
        DoOnce(^{                                                              \
          NSLog(@"Debug Logging Initializing");                                \
                                                                               \
          debugLevelNames = NSMutableDictionary.dictionary;                    \
                                                                               \
          B();                                                                 \
        });                                                                    \
                                                                               \
        return logLevel;                                                       \
    }                                                                          \
    void CommonDebugAssert() { NSLog(@"Assertion"); }
#else

#define DEBUG_LOG_LEVELS(B)                                                    \
    void CommonDebugAssert() { NSLog(@"Assertion"); }

#endif

#endif /* DebugLogging_h */
