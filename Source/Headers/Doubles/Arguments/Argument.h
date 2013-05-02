#import <Foundation/Foundation.h>
#import "CompareEqual.h"
#import "CedarStringifiers.h"
#import "CedarComparators.h"
#import <memory>

namespace Cedar { namespace Doubles {

#pragma mark - Argument
    class Argument {
    public:
        virtual ~Argument() = 0;

        virtual const char * const value_encoding() const = 0;
        virtual void * value_bytes() const = 0;
        virtual NSString * value_string() const = 0;

        virtual bool matches_encoding(const char *) const = 0;
        virtual bool matches_bytes(void *) const = 0;
        bool operator==(const Argument &other_argument) const {
            return this->matches_encoding(other_argument.value_encoding()) && this->matches_bytes(other_argument.value_bytes());
        };

        bool operator!=(const Argument &other_argument) const {
            return !(*this == other_argument);
        };

        typedef std::shared_ptr<Argument> shared_ptr_t;
    };

    inline /* virtual */ Argument::~Argument() {}

}}
