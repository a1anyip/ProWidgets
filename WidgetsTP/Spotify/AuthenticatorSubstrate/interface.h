@interface OTPStore : NSObject

- (NSArray *)authURLs;

@end

@interface OTPGenerator : NSObject

- (NSString *)generateOTP;
- (NSTimeInterval)period;

@end

@interface OTPAuthURL : NSObject

- (NSString *)name;
- (NSString *)issuer;
- (NSTimeInterval)lastProgress;
- (OTPGenerator *)generator;

- (void)generateNextOTPCode;
- (NSString *)otpCode;

@end