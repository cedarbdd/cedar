#import "Base.h"

#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {

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
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarConformTo = Cedar::Matchers::Private::ConformTo;
    inline CedarConformTo conform_to(Protocol *protocol) {
        return CedarConformTo(protocol);
    }

    inline CedarConformTo conform_to(const char *protocolName) {
        return CedarConformTo(protocolName);
    }
}}
