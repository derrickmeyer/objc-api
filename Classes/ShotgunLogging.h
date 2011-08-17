//
//  ShotgunLogging.h
//  ShotgunApi
//
//  Created by Rob Blau on 6/22/11.
//  Copyright 2011 Laika. All rights reserved.
//
//  From:
//  http://wranglingmacs.blogspot.com/2009/04/improving-on-nslog.html
//  http://icodesnip.com/snippet/objective-c/a-better-logging-solution
//
/// @file ShotgunLogging.h Macros to make logging easier.

#include <asl.h>

#ifndef ASL_KEY_FACILITY
 #define ASL_KEY_FACILITY "com.laika.objc-ShotgunApi"
#endif

#ifdef DEBUG
  #define SG_NSLOG_LEVEL ASL_LEVEL_DEBUG
#else
  #define SG_NSLOG_LEVEL ASL_LEVEL_WARNING
#endif

#define SGLOG_LEVEL(log_level, format, ...) { \
 asl_log(NULL, NULL, log_level, "[%s:%d%s] %s", __FILE__, __LINE__, __FUNCTION__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); \
 if (log_level <= SG_NSLOG_LEVEL) \
   NSLog(@"[%@:%d%s] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__]); \
}

#define SG_EMERG(format, ...)  SGLOG_LEVEL(ASL_LEVEL_EMERG,   format, ##__VA_ARGS__)
#define SG_ALERT(format, ...)  SGLOG_LEVEL(ASL_LEVEL_ALERT,   format, ##__VA_ARGS__)
#define SG_CRIT(format, ...)   SGLOG_LEVEL(ASL_LEVEL_CRIT,    format, ##__VA_ARGS__)
#define SG_ERROR(format, ...)  SGLOG_LEVEL(ASL_LEVEL_ERR,   format, ##__VA_ARGS__)
#define SG_WARN(format, ...)   SGLOG_LEVEL(ASL_LEVEL_WARNING, format, ##__VA_ARGS__)
#define SG_NOTICE(format, ...) SGLOG_LEVEL(ASL_LEVEL_NOTICE,  format, ##__VA_ARGS__)
#define SG_INFO(format, ...)   SGLOG_LEVEL(ASL_LEVEL_INFO,    format, ##__VA_ARGS__)
#define SG_DEBUG(format, ...)  SGLOG_LEVEL(ASL_LEVEL_DEBUG,   format, ##__VA_ARGS__)