#import <Foundation/Foundation.h>

@protocol CedarDouble;

namespace Cedar { namespace Doubles {
    class StubbedMethod;

    class StubbedMethodPrototype {
    private:
        StubbedMethodPrototype(const StubbedMethodPrototype & );
        StubbedMethodPrototype & operator=(const StubbedMethodPrototype &);

    public:
        explicit StubbedMethodPrototype(id<CedarDouble> parent);

        StubbedMethod & operator()(SEL ) const;
        StubbedMethod & operator()(const char * ) const;

    private:
        id<CedarDouble> parent_;
    };

}}
