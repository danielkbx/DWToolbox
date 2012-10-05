//
//  Log.h
//  dwToolbox
//
//  Created by Daniel Wetzel on 19.07.12.
//
//

#ifdef DEBUG
#define DLog(__FORMAT__, ...) NSLog((@"%s:%d " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(__FORMAT__, ...)
#endif
