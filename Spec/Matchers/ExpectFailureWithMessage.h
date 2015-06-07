#import <Foundation/Foundation.h>
#import "CDRExampleBase.h"

#ifdef __cplusplus
extern "C" {
#endif
void expectFailureWithMessage(NSString *message, CDRSpecBlock block);
void expectExceptionWithReason(NSString *reason, CDRSpecBlock block);
#ifdef __cplusplus
}
#endif
