//
//  Task.h
//  TodoApp
//
//  Created by Aya on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject <NSCoding , NSSecureCoding>
@property NSString *name;
@property NSString *desc;
@property NSString *priority;
@property NSString *state;
@property NSDate *date;

-(void) encodeWithCoder : (NSCoder *) encoder;

@end

NS_ASSUME_NONNULL_END
