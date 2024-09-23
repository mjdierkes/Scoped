#import <Foundation/Foundation.h>

@interface ObjectiveCUtilities : NSObject

+ (double)calculatePayloadCapacity:(double)thrust orbitAltitude:(double)altitude;
+ (NSInteger)daysUntilLaunch:(NSDate *)launchDate;

@end