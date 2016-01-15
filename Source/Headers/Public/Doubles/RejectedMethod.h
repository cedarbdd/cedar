#import <Foundation/Foundation.h>
#import "InvocationMatcher.h"
#import "Argument.h"
#import "ReturnValue.h"

#ifdef __cplusplus

#import <memory>
#import <vector>

namespace Cedar { namespace Doubles {

    class RejectedMethod : private InvocationMatcher {

    private:
        RejectedMethod & operator=(const RejectedMethod &);

    public:
        RejectedMethod(SEL);
        RejectedMethod(const char *);

        const SEL selector() const;
    };
}}

#endif // __cplusplus
