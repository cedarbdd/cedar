#import "Base.h"

namespace Cedar { namespace Matchers {

    class RespondTo : public Base<> {
    private:
        RespondTo & operator=(const RespondTo &);

    public:
        explicit RespondTo(NSString *);
        RespondTo(SEL selector);
        ~RespondTo();
        // Allow default copy ctor.

        bool matches(const id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        NSString *const expectedSelectorName_;
    };

    inline RespondTo respond_to(const SEL selector) {
        return RespondTo(selector);
    }

    inline RespondTo respond_to(NSString *selectorName) {
        return RespondTo(selectorName);
    }
}}
