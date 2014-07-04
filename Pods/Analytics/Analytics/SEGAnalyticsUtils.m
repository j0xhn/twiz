// AnalyticsUtils.m
// Copyright (c) 2014 Segment.io. All rights reserved.

#import "SEGAnalyticsUtils.h"
#import <AdSupport/ASIdentifierManager.h>

static BOOL kAnalyticsLoggerShowLogs = NO;

NSURL *SEGAnalyticsURLForFilename(NSString *filename) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    return [NSURL fileURLWithPath:path];
}

// Async Utils
dispatch_queue_t dispatch_queue_create_specific(const char *label, dispatch_queue_attr_t attr) {
    dispatch_queue_t queue = dispatch_queue_create(label, attr);
    dispatch_queue_set_specific(queue, (__bridge const void *)queue, (__bridge void *)queue, NULL);
    return queue;
}

BOOL dispatch_is_on_specific_queue(dispatch_queue_t queue) {
    return dispatch_get_specific((__bridge const void *)queue) != NULL;
}

void dispatch_specific(dispatch_queue_t queue, dispatch_block_t block, BOOL waitForCompletion) {
    if (dispatch_get_specific((__bridge const void *)queue)) {
        block();
    } else if (waitForCompletion) {
        dispatch_sync(queue, block);
    } else {
        dispatch_async(queue, block);
    }
}

void dispatch_specific_async(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_specific(queue, block, NO);
}

void dispatch_specific_sync(dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_specific(queue, block, YES);
}

// Logging

void SEGSetShowDebugLogs(BOOL showDebugLogs) {
    kAnalyticsLoggerShowLogs = showDebugLogs;
}

void SEGLog(NSString *format, ...) {
  if (!kAnalyticsLoggerShowLogs) return;

  va_list args;
  va_start(args, format);
  NSLogv(format, args);
  va_end(args);
}

// JSON Utils

static id SEGCoerceJSONObject(id obj) {
    // if the object is a NSString, NSNumber or NSNull
    // then we're good
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNumber class]] ||
        [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id i in obj)
            [array addObject:SEGCoerceJSONObject(i)];
        return array;
    }

    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSString *key in obj) {
            if (![key isKindOfClass:[NSString class]])
                SEGLog(@"warning: dictionary keys should be strings. got: %@. coercing to: %@", [key class], [key description]);
            dict[key.description] = SEGCoerceJSONObject(obj[key]);
        }
        return dict;
    }

    // NSDate description is already a valid ISO8061 string
    if ([obj isKindOfClass:[NSDate class]])
        return [obj description];

    if ([obj isKindOfClass:[NSURL class]])
        return [obj absoluteString];

    // default to sending the object's description
    SEGLog(@"warning: dictionary values should be valid json types. got: %@. coercing to: %@", [obj class], [obj description]);
    return [obj description];
}

static void AssertDictionaryTypes(id dict) {
    assert([dict isKindOfClass:[NSDictionary class]]);
    for (id key in dict) {
        assert([key isKindOfClass: [NSString class]]);
        id value = dict[key];

        assert([value isKindOfClass:[NSString class]] ||
               [value isKindOfClass:[NSNumber class]] ||
               [value isKindOfClass:[NSNull class]] ||
               [value isKindOfClass:[NSArray class]] ||
               [value isKindOfClass:[NSDictionary class]] ||
               [value isKindOfClass:[NSDate class]] ||
               [value isKindOfClass:[NSURL class]]);
    }
}

NSDictionary *SEGCoerceDictionary(NSDictionary *dict) {
    // make sure that a new dictionary exists even if the input is null
    dict = dict ?: @{};
    // assert that the proper types are in the dictionary
    AssertDictionaryTypes(dict);
    // coerce urls, and dates to the proper format
    return SEGCoerceJSONObject(dict);
}

NSString *SEGIDFA() {
  id identifierManager = NSClassFromString(@"ASIdentifierManager");
  if (identifierManager && [[identifierManager sharedManager] isAdvertisingTrackingEnabled]) {
    return [[[identifierManager sharedManager] advertisingIdentifier] UUIDString];
  } else {
    return nil;
  }
}
