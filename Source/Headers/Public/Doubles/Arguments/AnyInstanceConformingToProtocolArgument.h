#import "AnyInstanceArgument.h"

namespace Cedar { namespace Doubles {

    class AnyInstanceConformingToProtocolArgument : public AnyInstanceArgument {
    private:
        AnyInstanceConformingToProtocolArgument & operator=(const AnyInstanceConformingToProtocolArgument &);

    public:
        explicit AnyInstanceConformingToProtocolArgument(Protocol *);
        virtual ~AnyInstanceConformingToProtocolArgument();
        // Allow default copy ctor.

        virtual NSString * value_string() const;
        virtual bool matches_bytes(void *) const;
        virtual bool matches(const Argument &) const;
    private:
        Protocol *protocol_;
    };

    namespace Arguments {
        Argument::shared_ptr_t any(Protocol *);
    }
}}
