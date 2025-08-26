//
//  PlistMacros.h
//
//  Created by Andy Wallace on 2/22/25.
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

// -----------------------------------------------------------------------------
// PlistMacros and PlistParams are a framework for managing a dictionary
// with properties. This came about because I had a dictionary and hated using
// the strings all the time.

// The idea is the helper object has properties called valXXX where setting and
// reading will update an underlying dictionary.  Macros are used to define
// the properties in a type-safe way.

#define SAFE_OBJ(OBJ, T, D)                                                    \
    ((T *)([(OBJ) isKindOfClass:[T class]] ? (OBJ) : (D)))

#define PROP_EXISTS(PROP, KEY)                                                 \
    -(bool)exists##PROP {                                                      \
        DEBUG_LOG(@"PROP_EXISTS " KEY " %d", self.dictionary[KEY] != nil);     \
        return self.dictionary[KEY] != nil;                                    \
    }

#define PROP_NSNumber(PROP, KEY, T, GETTER, D)                                 \
    -(void)setVal##PROP : (T)value {                                           \
        ASSERT(self.mDict != NULL)                                             \
        self.mDict[KEY] = @(value);                                            \
        DEBUG_LOG(@"set PROP_NSNumber %f to " KEY, (double)value);             \
    }                                                                          \
    -(T)val##PROP {                                                            \
        NSObject *obj = self.dictionary[KEY];                                  \
        T value = (T)(SAFE_OBJ(obj, NSNumber, @(D)).GETTER);                   \
        DEBUG_LOG(@"got PROP_NSNumber %f from " KEY, (double)value);           \
        return value;                                                          \
    }                                                                          \
    PROP_EXISTS(PROP, KEY)

#define PROP_NSInteger(PROP, KEY, D)                                           \
    PROP_NSNumber(PROP, KEY, NSInteger, integerValue, D)

#define PROP_CGFloat(PROP, KEY, D)                                             \
    PROP_NSNumber(PROP, KEY, CGFloat, doubleValue, D)

#define PROP_double(PROP, KEY, D)                                              \
    PROP_NSNumber(PROP, KEY, double, doubleValue, D)

#define PROP_int(PROP, KEY, D) PROP_NSNumber(PROP, KEY, int, intValue, D)

#define PROP_bool(PROP, KEY, D)                                                \
    -(void)setVal##PROP : (bool)value {                                        \
        ASSERT(self.mDict != NULL)                                             \
        self.mDict[KEY] = @(value);                                            \
        DEBUG_LOG(@"set PROP_bool %d to " KEY, value);                         \
    }                                                                          \
    -(bool)val##PROP {                                                         \
        bool value = [PlistParams safeBool:self.dictionary[KEY] def:(D)];      \
        DEBUG_LOG(@"got PROP_bool %d from " KEY, value);                       \
        return value;                                                          \
    }                                                                          \
    PROP_EXISTS(PROP, KEY)

#define PROP_NEWL(X) (X) ? @"\n" : @" ", (X)

#define PROP_OBJ(PROP, KEY, D, T, S, ...)                                      \
    -(void)setVal##PROP : (T *)value {                                         \
        ASSERT(self.mDict != NULL)                                             \
        self.mDict[KEY] = value;                                               \
        DEBUG_LOG(@" set " S @" to " KEY, ##__VA_ARGS__);                      \
    }                                                                          \
    -(T *)val##PROP {                                                          \
        NSObject *obj = self.dictionary[KEY];                                  \
        T *value = SAFE_OBJ(obj, T, D);                                        \
        DEBUG_LOG(@" got " S @" from " KEY, ##__VA_ARGS__);                    \
        return value;                                                          \
    }                                                                          \
    PROP_EXISTS(PROP, KEY)

#define MPROP_OBJ(PROP, KEY, D, M, I, S, ...)                                  \
    -(void)setVal##PROP : (M *)value {                                         \
        ASSERT(self.mDict != NULL)                                             \
        self.mDict[KEY] = value;                                               \
        DEBUG_LOG(@" set " S @" to " KEY, ##__VA_ARGS__);                      \
    }                                                                          \
    -(M *)val##PROP {                                                          \
        NSObject *obj = self.dictionary[KEY];                                  \
        M *value = SAFE_OBJ(obj, M, D);                                        \
        if (value == nil) {                                                    \
            I *immutable = SAFE_OBJ(obj, I, D);                                \
            if (immutable) {                                                   \
                value = immutable.mutableCopy;                                 \
            }                                                                  \
        }                                                                      \
        DEBUG_LOG(@" got " S @" from " KEY, ##__VA_ARGS__);                    \
        return value;                                                          \
    }                                                                          \
    PROP_EXISTS(PROP, KEY)

#define PROP_NSString(PROP, KEY, D)                                            \
    PROP_OBJ(PROP, KEY, D, NSString, @"PROP_NSString \"%@\"", value)

#define PROP_NSArray(PROP, KEY, D)                                             \
    PROP_OBJ(PROP, KEY, D, NSArray, @"PROP_NSArray size %ld%@%@",              \
             (long)(value ? value.count : -1), PROP_NEWL(value.description));

#define PROP_NSMutableArray(PROP, KEY, D)                                      \
    MPROP_OBJ(PROP, KEY, D, NSMutableArray, NSArray,                           \
              @"PROP_NSMutableArray size %ld%@%@",                             \
              (long)(value ? value.count : -1), PROP_NEWL(value.description));

#define PROP_NSDictionary(PROP, KEY, D)                                        \
    PROP_OBJ(PROP, KEY, D, NSDictionary, @"PROP_NSDictionary size %ld%@%@",    \
             (long)(value ? value.count : -1), PROP_NEWL(value.description))

#define PROP_NSMutableDictionary(PROP, KEY, D)                                 \
    MPROP_OBJ(PROP, KEY, D, NSMutableDictionary, NSDictionary,                 \
              @"PROP_NSMutableDictionary size %ld%@%@",                        \
              (long)(value ? value.count : -1), PROP_NEWL(value.description));

#define PROP_NSData(PROP, KEY, D)                                              \
    PROP_OBJ(PROP, KEY, D, NSData, @"PROP_NSData size %ld%@%@",                \
             (long)(value ? value.length : -1), PROP_NEWL(value.description));
