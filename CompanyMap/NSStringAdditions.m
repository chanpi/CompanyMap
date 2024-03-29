#import "NSStringAdditions.h"


@implementation NSString (NSStringAdditions)

- (const xmlChar *)xmlChar
{
	return (const xmlChar *)[self UTF8String];
}

#ifdef GNUSTEP
- (NSString *)stringByTrimming
{
	return [self stringByTrimmingSpaces];
}
#else
- (NSString *)stringByTrimming
{
	NSMutableString *mStr = [self mutableCopy];
	//CFStringTrimWhitespace((CFMutableStringRef)mStr);
    CFStringTrimWhitespace((__bridge CFMutableStringRef)mStr);
        
	NSString *result = [mStr copy];
	
	//[mStr release];
	//return [result autorelease];
    return result;
}
#endif

@end
