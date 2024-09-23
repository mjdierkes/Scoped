#import "ObjectiveCUtilities.h"

@implementation ObjectiveCUtilities

+ (NSString *)getVersionString {
    return @"1.0.0";
}

+ (NSInteger)daysUntilLaunch:(NSDate *)launchDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:now
                                                 toDate:launchDate
                                                options:0];
    return MAX(0, [components day]);
}

+ (double)calculatePayloadCapacity:(double)thrust orbitAltitude:(double)altitude {
    // This is a simplified calculation and not scientifically accurate
    double gravitationalConstant = 9.8; // m/s^2
    double earthRadius = 6371000; // meters
    
    double orbitalVelocity = sqrt((gravitationalConstant * earthRadius) / (earthRadius + altitude));
    double energyRequired = 0.5 * orbitalVelocity * orbitalVelocity;
    
    // Assume 10% of thrust is converted to payload capacity
    double payloadCapacity = (thrust * 0.10) / energyRequired;
    
    return payloadCapacity;
}

@end