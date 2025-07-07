//
//  DebugLogging.swift
//  Trail Map Locator
//
//  Created by Andy Wallace on 3/25/25.
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

// clang-format off
#if DEBUG_LOGGING
    @inline(__always)
    func DEBUG_LOG(
        _ level: debugLogLevel,
        _ messages: Any...,
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) {
        if (CommonDebugLogLevel() & level.rawValue) != 0 {
            let output = messages.map { "\($0)" }.joined(separator: " ")
            let fileName = (file as NSString).lastPathComponent
            print("<\(fileName):\(function):\(line)> \(output)")
        }
    }
#else
    @inline(__always)
    func DEBUG_LOG(_ level: debugLogLevel, _ messages: Any...) {

    }

#endif
// clang-format on
