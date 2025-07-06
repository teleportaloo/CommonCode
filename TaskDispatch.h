//
//  TaskDispatch.h
//  Trail Map Locator
//
//  Created by Andy Wallace on 4/14/25.
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

#define MainTask(B) dispatch_async(dispatch_get_main_queue(), (B))
#define WorkerTask(B)                                                          \
    dispatch_async(                                                            \
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), (B))

#define DoOnce(B)                                                              \
    {                                                                          \
        static dispatch_once_t onceToken;                                      \
        dispatch_once(&onceToken, (B));                                        \
    }

#define MainTaskDelay(T, B)                                                    \
    dispatch_after(                                                            \
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)((T) * NSEC_PER_SEC)),       \
        dispatch_get_main_queue(), (B))
