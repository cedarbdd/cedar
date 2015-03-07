#import "BeInstanceOf.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    inline BeInstanceOf BeString() {
        return be_instance_of([NSString class]).or_any_subclass();
    }

    inline BeInstanceOf BeNumber() {
        return be_instance_of([NSNumber class]).or_any_subclass();
    }

    inline BeInstanceOf BeArray() {
        return be_instance_of([NSArray class]).or_any_subclass();
    }

    inline BeInstanceOf BeDictionary() {
        return be_instance_of([NSDictionary class]).or_any_subclass();
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    static const Private::BeInstanceOf be_string = Private::BeString();
    static const Private::BeInstanceOf be_number = Private::BeNumber();
    static const Private::BeInstanceOf be_array = Private::BeArray();
    static const Private::BeInstanceOf be_dictionary = Private::BeDictionary();
}}
