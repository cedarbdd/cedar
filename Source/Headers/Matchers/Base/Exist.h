#import <Foundation/Foundation.h>
#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    class Exist : public Base<> {
    public:
        virtual NSString * failure_message_end() const {
            return @"exist on the local filesystem";
        }

        template<typename T>
        bool matches(T * const &) const;

        bool matches(NSString * const path) const {
            return [[NSFileManager defaultManager] fileExistsAtPath:path];
        }

        bool matches(NSURL * const URL) const {
            return matches([URL path]);
        }
    };
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarExist = Cedar::Matchers::Private::Exist;
    static const CedarExist exist = CedarExist();
}}
