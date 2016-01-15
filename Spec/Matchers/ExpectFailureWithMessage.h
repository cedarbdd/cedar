#import <Foundation/Foundation.h>
#import "CDRNullabilityCompat.h"
#import "CDRExampleBase.h"

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif
void expectFailureWithMessage(NSString *message, CDRSpecBlock block);
void expectExceptionWithReason(NSString *reason, CDRSpecBlock block);
#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
