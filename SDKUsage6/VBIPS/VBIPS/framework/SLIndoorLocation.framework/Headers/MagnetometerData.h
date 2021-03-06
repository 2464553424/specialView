//
//  MagnetometerData.h
//  SLIndoorLocation
//
//  Created by David Törnqvist on 11/28/13.
//
//

#import <Foundation/Foundation.h>

@interface MagnetometerData : NSObject

- (id) initWithTimestamp:(NSTimeInterval)timestamp_ x:(double)x_ y:(double)y_ z:(double)z_;
- (id) initWithMessage:(NSString*)message;

@property(readonly, nonatomic) double x;
@property(readonly, nonatomic) double y;
@property(readonly, nonatomic) double z;
@property(readonly, nonatomic) NSTimeInterval timestamp;

@end
