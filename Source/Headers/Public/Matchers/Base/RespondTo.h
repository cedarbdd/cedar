#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {

    class RespondTo : public Base<> {
    private:
        RespondTo & operator=(const RespondTo &);

    public:
        explicit RespondTo(const char *);
        RespondTo(SEL selector);
        ~RespondTo();
        // Allow default copy ctor.

        bool matches(const id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const char *expectedSelectorName_;
    };
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarRespondTo = Cedar::Matchers::Private::RespondTo;

    inline CedarRespondTo respond_to(const SEL selector) {
        return CedarRespondTo(selector);
    }

    inline CedarRespondTo respond_to(const char *selectorName) {
        return CedarRespondTo(selectorName);
    }
}}
