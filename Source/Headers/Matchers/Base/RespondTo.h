#import "Base.h"

namespace Cedar { namespace Matchers {

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

    inline RespondTo respond_to(const SEL selector) {
        return RespondTo(selector);
    }

    inline RespondTo respond_to(const char *selectorName) {
        return RespondTo(selectorName);
    }
}}
