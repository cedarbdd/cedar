#import <Foundation/Foundation.h>
#import <memory>
#import <vector>
#import "InvocationMatcher.h"
#import "Argument.h"
#import "ReturnValue.h"

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
