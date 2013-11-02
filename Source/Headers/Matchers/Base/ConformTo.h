#import "Base.h"

namespace Cedar { namespace Matchers {

    class ConformTo : public Base<> {
    private:
        ConformTo & operator=(const ConformTo &);

    public:
        explicit ConformTo(const char *);
        ConformTo(Protocol *protocol);
        ~ConformTo();
        // Allow default copy ctor.

        bool matches(const id) const;

    protected:
        virtual NSString * failure_message_end() const;

    private:
        const char *expectedProtocolName_;
    };

    inline ConformTo conform_to(Protocol *protocol) {
        return ConformTo(protocol);
    }

    inline ConformTo conform_to(const char *protocolName) {
        return ConformTo(protocolName);
    }
}}
