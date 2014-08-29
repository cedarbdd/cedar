#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {
    class BeEmpty : public Base<> {
    private:
        BeEmpty & operator=(const BeEmpty &);

    public:
        inline BeEmpty() : Base<>() {}
        inline ~BeEmpty() {}
        // Allow default copy ctor.

        inline const BeEmpty & operator()() const { return *this; }

        template<typename U>
        bool matches(const U &) const;

    protected:
        inline /*virtual*/ NSString * failure_message_end() const { return @"be empty"; }
    };

#pragma mark Generic
    template<typename U>
    bool BeEmpty::matches(const U & actualValue) const {
        return Comparators::compare_empty(actualValue);
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarBeEmpty = Cedar::Matchers::Private::BeEmpty;
    static const CedarBeEmpty be_empty = CedarBeEmpty();
}}
