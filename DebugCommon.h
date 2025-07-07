//
//  DebugLogging.h
//  Automata
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

extern long DebugLogLevel(void);
extern void DebugAssert(void);

#if defined __cplusplus
};

#endif

#define DEBUG_BLOCK(X)                                                         \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        void (^block)(void) = (X);                                             \
        block();                                                               \
    }
#define DEBUG_ON_FOR_FILE ((DebugLogLevel() & DEBUG_LEVEL_FOR_FILE))
#define DEBUG_AND(X) (DEBUG_ON_FOR_FILE) ? ((X)) : (FALSE)

#define DEBUG_LOG(s, ...)                                                      \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        NSLog(@"<%s:%d> %@", __func__, __LINE__,                               \
              [NSString stringWithFormat:(s), ##__VA_ARGS__]);                 \
    }
#define DEBUG_PRINTF(format, args...)                                          \
    if (DEBUG_ON_FOR_FILE) {                                                   \
        printf(format, ##args);                                                \
    }
#define ASSERT(X)                                                              \
    if (!(X)) {                                                                \
        NSLog(@"ASSERTION Failed: " @ #X);                                     \
        DebugAssert();                                                         \
        raise(SIGINT);                                                         \
    }
#define DEBUG_MODE @" debug"

#else
#define DEBUG_BLOCK(X)
#define DEBUG_ON_FOR_FILE (FALSE)
#define DEBUG_LOG(s, ...)
#define DEBUG_PRINTF(format, args...)
#define ASSERT(X)
#define DEBUG_MODE @""


#endif

#define DEBUG_HERE() DEBUG_LOG(@"here")
#define ERROR_LOG(s, ...)                                                      \
    NSLog(@"<%s:%d> %@", __func__, __LINE__,                                   \
          [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define DEBUG_LOG_BOOL(B) DEBUG_LOG(@"%-40s %@", #B, (B) ? @"True" : @"False")
#define DEBUG_LOG_CGRect(X)                                                    \
    DEBUG_LOG(@"%-40s (%g, %g) -> (%g, %g) (%g, %g)", #X, (X).origin.x,        \
              (X).origin.y, (X).origin.x + (X).size.width,                     \
              (X).origin.y + (X).size.height, (X).size.width, (X).size.height)
#define DEBUG_LOG_CGSize(X) DEBUG_LOG(@"%-40s %@", #X, NSStringFromCGSize(X))
#define DEBUG_LOG_NSString(X) DEBUG_LOG(@"%-40s %@", #X, X)
#define DEBUG_LOG_CGPoint(X) DEBUG_LOG(@"%-40s %@", #X, NSStringFromCGPoint(X))
#define DEBUG_LOG_CGFloat(X) DEBUG_LOG(@"%-40s %g", #X, (CGFloat)(X))
#define DEBUG_LOG_long(X) DEBUG_LOG(@"%-40s %ld", #X, (long)(X))
#define DEBUG_LOG_longX(X) DEBUG_LOG(@"%-40s 0x%lx", #X, (long)(X))
#define DEBUG_LOG_NSDate(X)                                                    \
    {                                                                          \
        NSDateFormatter *formatter = [NSDateFormatter new];                    \
        formatter.locale =                                                     \
            [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];              \
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];             \
        DEBUG_LOG(@"%-40s %@", #X, [formatter stringFromDate:(X)]);            \
    }
#define DEBUG_LOG_ADDRESS(X) DEBUG_LOG(@"%-40s %p", #X, (X))
#define DEBUG_LOG_DebugString(X) DEBUG_LOG(@"%-40s %s", #X, (X).DebugString())
#define DEBUG_LOG_UIEdgeInsets(X)                                              \
    DEBUG_LOG(@"%-40s %g, %g, %g, %g", #X, (X).top, (X).left, (X).bottom,      \
              (X).right)
#define LOG_NSError(error)                                                     \
    if (error) {                                                               \
        ERROR_LOG(@"NSError: %@\n", error.description);                        \
    }

#define DEBUG_LOG_description(X) DEBUG_LOG(@"%-40s %@", #X, (X).description)


#endif /* DebugLogging_h */
