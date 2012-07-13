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

        virtual void * value_bytes() const = 0;
        virtual const char * value_encoding() const = 0;
        virtual NSString * value_string() const = 0;
        virtual size_t value_size() const = 0;

        virtual bool matches_bytes(void * expectedArgumentBytes) const = 0;

        typedef std::tr1::shared_ptr<Argument> shared_ptr_t;
    };

    inline /* virtual */ Argument::~Argument() {}

#pragma mark - TypedArgument
    template<typename T>
    class TypedArgument : public Argument {
    private:
        TypedArgument<T> & operator=(const TypedArgument<T> &);

    public:
        explicit TypedArgument(const T &);
        virtual ~TypedArgument();
        // Allow default copy ctor.

        virtual void * value_bytes() const;
        virtual const char * value_encoding() const;
        virtual NSString * value_string() const;
        virtual size_t value_size() const;

        virtual bool matches_bytes(void * expectedArgumentBytes) const;

    private:
        const T value_;
    };

    class AnyArgument : public Argument {
    private:
        AnyArgument & operator=(const AnyArgument &) {};

    public:
        AnyArgument() {};
        virtual ~AnyArgument() {};
        // Allow default copy ctor.

        virtual void * value_bytes() const { return NULL; };
        virtual const char * value_encoding() const { return NULL; };
        virtual NSString * value_string() const { return @"anything"; };
        virtual size_t value_size() const { return 0; };

        virtual bool matches_bytes(void * expectedArgumentBytes) const { return true; }

    };

    template<typename T>
    TypedArgument<T>::TypedArgument(const T & value) : Argument(), value_(value) {}

    template<typename T>
    /* virtual */ TypedArgument<T>::~TypedArgument() {}

    template<typename T>
    /* virtual */ void * TypedArgument<T>::value_bytes() const {
        return (const_cast<T *>(&value_));
    }

    template<typename T>
    /* virtual */ const char * TypedArgument<T>::value_encoding() const {
        return @encode(T);
    }

    template<typename T>
    /* virtual */ NSString * TypedArgument<T>::value_string() const {
        return Matchers::Stringifiers::string_for(value_);
    }

    template<typename T>
    /* virtual */ size_t TypedArgument<T>::value_size() const {
        return sizeof(T);
    }

    template<typename T>
    /* virtual */ bool TypedArgument<T>::matches_bytes(void * expectedArgumentBytes) const {
        return Matchers::Comparators::compare_equal(value_, *(static_cast<T *>(expectedArgumentBytes)));
    }

    namespace Arguments {
        extern Argument::shared_ptr_t anything;
    }

}}
