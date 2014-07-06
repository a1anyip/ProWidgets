@class DDActionController, DDAction, DDCreateEventAction, DDScannerResult;

@interface DDActionController : NSObject

- (void)performAction:(DDAction *)action;

@end

//EventTitle
//ReferenceDate

@interface DDAction : NSObject

- (NSDictionary *)context;
- (void *)result;
- (void *)coalescedResult;
- (CFArrayRef)associatedResults;

@end

@interface DDCreateEventAction : DDAction

@end

@interface DDScannerResult : NSObject

+ (instancetype)resultFromCoreResult:(void *)result;

- (NSString *)type;

- (BOOL)extractStartDate:(id *)arg1 startTimezone:(id *)arg2 endDate:(id *)arg3 endTimezone:(id *)arg4 allDayRef:(BOOL *)arg5 referenceDate:(id)arg6 referenceTimezone:(id)arg7;

- (NSDate *)dateFromReferenceDate:(id)arg1 referenceTimezone:(id)arg2 timezoneRef:(id *)arg3 allDayRef:(BOOL *)arg4;

@end