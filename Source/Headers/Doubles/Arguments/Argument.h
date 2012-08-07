#import <Foundation/Foundation.h>
#import "CompareEqual.h"
#import "CedarStringifiers.h"
#import "CedarComparators.h"
#import <tr1/memory>

namespace Cedar { namespace Doubles {

#pragma mark - Argument
    class Argument {
    public:
        virtual ~Argument() = 0;

        virtual const char * const value_encoding() const = 0;
        virtual void * value_bytes() const = 0;
        virtual NSString * value_string() const = 0;
        virtual size_t value_size() const = 0;

        virtual bool matches_encoding(const char * expected_argument_encoding) const = 0;
        virtual bool matches_bytes(void * expected_argument_bytes) const = 0;

        typedef std::tr1::shared_ptr<Argument> shared_ptr_t;
    };

    inline /* virtual */ Argument::~Argument() {}

}}
