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

// for each PROPERTY these will create a setter and getter and helpers
// - setValPROPERTY
// - valPROPERTY
// - existsPROPERTY (if property exists)
// for mutable properties it creates
// - isMutablePROPERTY
// - immutablePROPERTY
// isMutablePROPERTY is a bool that is true if the property was stored as
// mutable. If it is false then changes to the property may not be saved back
// if it returned a mutable copy and the container is immutable. If a nutable
// PList was created then it will update the leaf to be mutable if it was read
// as immutable. immutablePROPERTY is used when do the caller doesn't really
// need it to be mutable so saves the write-back if it was not.

// Typical uses are:
// PROP_NSString(Location, "@loc", nil);
// PROP_NSMutableDictionary(Trip, @"Trip", NSMutableDictionary.dictionary);
//
// Params:
//  PROP - property
//  KEY - string key
//  DEFAULT - default value if does not exist

//------------------------------------------------------------------------------
// Helper macros (not expected to be used by consumers)
// Internal params:
//  MTYPE - Mutable type
//  ITYPE - Immutable type
//  TYPE - Type
//  GETTER - value getter from NSNumber (e.g. intValue)
//  OBJ - object to cast
//  FMT - format string for debugging

#define SAFE_OBJ(OBJ, TYPE, DEFAULT)                                                               \
    ((TYPE *)([(OBJ) isKindOfClass:[TYPE class]] ? (OBJ) : (DEFAULT)))

#define PROP_EXISTS(PROP, KEY)                                                                     \
    -(bool)exists##PROP {                                                                          \
        DEBUG_LOG(@"PROP_EXISTS " KEY " %d", self.dictionary[KEY] != nil);                         \
        return self.dictionary[KEY] != nil;                                                        \
    }

#define PROP_NSNumber(PROP, KEY, TYPE, GETTER, DEFAULT)                                            \
    -(void)setVal##PROP : (TYPE)value {                                                            \
        ASSERT(self.mDict != NULL);                                                                \
        self.mDict[KEY] = @(value);                                                                \
        DEBUG_LOG(@"set PROP_NSNumber %f to " KEY, (double)value);                                 \
    }                                                                                              \
    -(TYPE)val##PROP {                                                                             \
        NSObject *obj = self.dictionary[KEY];                                                      \
        TYPE value = (TYPE)(SAFE_OBJ(obj, NSNumber, @(DEFAULT)).GETTER);                           \
        DEBUG_LOG(@"got PROP_NSNumber %f from " KEY, (double)value);                               \
        return value;                                                                              \
    }                                                                                              \
    PROP_EXISTS(PROP, KEY)

#define PROP_NEWL(X) (X) ? @"\n" : @" ", (X)

#define PROP_OBJ(PROP, KEY, DEFAULT, TYPE, FMT, ...)                                               \
    -(void)setVal##PROP : (TYPE *)value {                                                          \
        ASSERT(self.mDict != NULL);                                                                \
        self.mDict[KEY] = value;                                                                   \
        DEBUG_LOG(@" set " FMT @" to " KEY, ##__VA_ARGS__);                                        \
    }                                                                                              \
    -(TYPE *)val##PROP {                                                                           \
        NSObject *obj = self.dictionary[KEY];                                                      \
        TYPE *value = SAFE_OBJ(obj, TYPE, DEFAULT);                                                \
        DEBUG_LOG(@" got " FMT @" from " KEY, ##__VA_ARGS__);                                      \
        return value;                                                                              \
    }                                                                                              \
    PROP_EXISTS(PROP, KEY)

#define MPROP_OBJ(PROP, KEY, DEFAULT, MTYPE, ITYPE, FMT, ...)                                      \
    -(void)setVal##PROP : (MTYPE *)value {                                                         \
        ASSERT(self.mDict != NULL);                                                                \
        self.mDict[KEY] = value;                                                                   \
        DEBUG_LOG(@" set " FMT @" to " KEY, ##__VA_ARGS__);                                        \
    }                                                                                              \
    -(MTYPE *)val##PROP {                                                                          \
        NSObject *obj = self.dictionary[KEY];                                                      \
        MTYPE *value = SAFE_OBJ(obj, MTYPE, nil);                                                  \
        if (value == nil) {                                                                        \
            ITYPE *immutable = SAFE_OBJ(obj, ITYPE, nil);                                          \
            if (immutable) {                                                                       \
                value = immutable.mutableCopy;                                                     \
                DEBUG_LOG(@" copied from " KEY);                                                   \
                if (self.mDict != NULL) {                                                          \
                    DEBUG_LOG(@" replaced " KEY);                                                  \
                    self.mDict[KEY] = value;                                                       \
                }                                                                                  \
            } else {                                                                               \
                value = (DEFAULT);                                                                 \
            }                                                                                      \
        }                                                                                          \
        DEBUG_LOG(@" got " FMT @" from " KEY, ##__VA_ARGS__);                                      \
        return value;                                                                              \
    }                                                                                              \
    -(ITYPE *)immutable##PROP {                                                                    \
        NSObject *obj = self.dictionary[KEY];                                                      \
        ITYPE *value = SAFE_OBJ(obj, ITYPE, DEFAULT);                                              \
        DEBUG_LOG(@" got immutable " FMT @" from " KEY, ##__VA_ARGS__);                            \
        return value;                                                                              \
    }                                                                                              \
    -(bool)isMutable##PROP {                                                                       \
        NSObject *obj = self.dictionary[KEY];                                                      \
        MTYPE *value = SAFE_OBJ(obj, MTYPE, nil);                                                  \
        DEBUG_LOG(@"PROP_MUTABLE " KEY " %d", value != nil);                                       \
        return value != nil;                                                                       \
    }                                                                                              \
    PROP_EXISTS(PROP, KEY);

//------------------------------------------------------------------------------
// Macros for each type of property

#define PROP_NSInteger(PROP, KEY, DEFAULT)                                                         \
    PROP_NSNumber(PROP, KEY, NSInteger, integerValue, DEFAULT)

#define PROP_CGFloat(PROP, KEY, DEFAULT) PROP_NSNumber(PROP, KEY, CGFloat, doubleValue, DEFAULT)

#define PROP_double(PROP, KEY, DEFAULT) PROP_NSNumber(PROP, KEY, double, doubleValue, DEFAULT)

#define PROP_int(PROP, KEY, DEFAULT) PROP_NSNumber(PROP, KEY, int, intValue, DEFAULT)

#define PROP_bool(PROP, KEY, DEFAULT)                                                              \
    -(void)setVal##PROP : (bool)value {                                                            \
        ASSERT(self.mDict != NULL);                                                                \
        self.mDict[KEY] = @(value);                                                                \
        DEBUG_LOG(@"set PROP_bool %d to " KEY, value);                                             \
    }                                                                                              \
    -(bool)val##PROP {                                                                             \
        bool value = [PlistParams safeBool:self.dictionary[KEY] def:(DEFAULT)];                    \
        DEBUG_LOG(@"got PROP_bool %d from " KEY, value);                                           \
        return value;                                                                              \
    }                                                                                              \
    PROP_EXISTS(PROP, KEY)

#define PROP_NSString(PROP, KEY, DEFAULT)                                                          \
    PROP_OBJ(PROP, KEY, DEFAULT, NSString, @"PROP_NSString \"%@\"", value)

#define PROP_NSArray(PROP, KEY, DEFAULT)                                                           \
    PROP_OBJ(PROP,                                                                                 \
             KEY,                                                                                  \
             DEFAULT,                                                                              \
             NSArray,                                                                              \
             @"PROP_NSArray size %ld%@%@",                                                         \
             (long)(value ? value.count : -1),                                                     \
             PROP_NEWL(value.description));

#define PROP_NSMutableArray(PROP, KEY, DEFAULT)                                                    \
    MPROP_OBJ(PROP,                                                                                \
              KEY,                                                                                 \
              DEFAULT,                                                                             \
              NSMutableArray,                                                                      \
              NSArray,                                                                             \
              @"PROP_NSMutableArray size %ld%@%@",                                                 \
              (long)(value ? value.count : -1),                                                    \
              PROP_NEWL(value.description));

#define PROP_NSDictionary(PROP, KEY, DEFAULT)                                                      \
    PROP_OBJ(PROP,                                                                                 \
             KEY,                                                                                  \
             DEFAULT,                                                                              \
             NSDictionary,                                                                         \
             @"PROP_NSDictionary size %ld%@%@",                                                    \
             (long)(value ? value.count : -1),                                                     \
             PROP_NEWL(value.description))

#define PROP_NSMutableDictionary(PROP, KEY, DEFAULT)                                               \
    MPROP_OBJ(PROP,                                                                                \
              KEY,                                                                                 \
              DEFAULT,                                                                             \
              NSMutableDictionary,                                                                 \
              NSDictionary,                                                                        \
              @"PROP_NSMutableDictionary size %ld%@%@",                                            \
              (long)(value ? value.count : -1),                                                    \
              PROP_NEWL(value.description));

#define PROP_NSData(PROP, KEY, DEFAULT)                                                            \
    PROP_OBJ(PROP,                                                                                 \
             KEY,                                                                                  \
             DEFAULT,                                                                              \
             NSData,                                                                               \
             @"PROP_NSData size %ld%@%@",                                                          \
             (long)(value ? value.length : -1),                                                    \
             PROP_NEWL(value.description));
