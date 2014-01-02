#import <Foundation/Foundation.h>
#import "Base.h"

namespace Cedar { namespace Matchers {
    class Exist : public Base<> {
    public:
        virtual NSString * failure_message_end() const { return @"exist on the local filesystem"; }
//        template<typename T>
        bool matches(NSURL * const URL) const {
            return [[NSFileManager defaultManager] fileExistsAtPath:[URL path]];
        }
    };

    static const Exist exist = Exist();
}}
