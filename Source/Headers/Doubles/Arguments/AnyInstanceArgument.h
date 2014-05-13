#import "Argument.h"

namespace Cedar { namespace Doubles {

    class AnyInstanceArgument : public Argument {
    public:
        virtual ~AnyInstanceArgument() = 0;

        virtual const char * const value_encoding() const;
        virtual void * value_bytes() const { return NULL; }
        virtual NSString * value_string() const = 0;

        virtual bool matches_encoding(const char *) const;
        virtual bool matches_bytes(void *) const = 0;
        virtual unsigned int specificity_ranking() const { return 1; }
    };
}}
