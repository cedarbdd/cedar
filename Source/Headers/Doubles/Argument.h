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

#pragma mark - TypedArgument
    template<typename T>
    class TypedArgument : public Argument {
    private:
        TypedArgument<T> & operator=(const TypedArgument<T> &);

    public:
        explicit TypedArgument(const T &);
        virtual ~TypedArgument();
        // Allow default copy ctor.

        virtual const char * const value_encoding() const;
        virtual void * value_bytes() const;
        virtual NSString * value_string() const;
        virtual size_t value_size() const;

        virtual bool matches_encoding(const char * expected_argument_encoding) const;
        virtual bool matches_bytes(void * expected_argument_bytes) const;

    private:
        const T value_;
    };

    template<typename T>
    class ReturnValue : public TypedArgument<T> {
    private:
        ReturnValue & operator=(const ReturnValue &);

    public:
        explicit ReturnValue(const T &);
        virtual ~ReturnValue();

        virtual bool matches_encoding(const char * expected_argument_encoding) const;
    };

    template<typename T>
    ReturnValue<T>::ReturnValue(const T & value) : TypedArgument<T>(value) {}

    template<typename T>
    /* virtual */ ReturnValue<T>::~ReturnValue() {}

    template<typename T>
    /* virtual */ bool ReturnValue<T>::matches_encoding(const char * expected_argument_encoding) const {
        return 0 == strcmp(@encode(T), expected_argument_encoding);
    }

    template<typename T>
    TypedArgument<T>::TypedArgument(const T & value) : Argument(), value_(value) {}

    template<typename T>
    /* virtual */ TypedArgument<T>::~TypedArgument() {}

    template<typename T>
    /* virtual */ const char * const TypedArgument<T>::value_encoding() const {
        return @encode(T);
    }

    template<typename T>
    /* virtual */ void * TypedArgument<T>::value_bytes() const {
        return (const_cast<T *>(&value_));
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
    /* virtual */ bool TypedArgument<T>::matches_encoding(const char * expected_argument_encoding) const {
        return (0 == strncmp(@encode(T), "@", 1) && 0 == strncmp(expected_argument_encoding, "@", 1)) ||
            (0 != strncmp(@encode(T), "@", 1) && 0 != strncmp(expected_argument_encoding, "@", 1));
    }

    template<typename T>
    /* virtual */ bool TypedArgument<T>::matches_bytes(void * expected_argument_bytes) const {
        return Matchers::Comparators::compare_equal(value_, *(static_cast<T *>(expected_argument_bytes)));
    }

    class AnyArgument : public Argument {
    private:
        AnyArgument & operator=(const AnyArgument &);

    public:
        AnyArgument() {};
        virtual ~AnyArgument() {};
        // Allow default copy ctor.

        virtual const char * const value_encoding() const { return ""; };
        virtual void * value_bytes() const { return NULL; };
        virtual NSString * value_string() const { return @"anything"; };
        virtual size_t value_size() const { return 0; };

        virtual bool matches_encoding(const char * expected_argument_encoding) const { return true; }
        virtual bool matches_bytes(void * expected_argument_bytes) const { return true; }

    };

    namespace Arguments {
        static const Argument::shared_ptr_t anything = Argument::shared_ptr_t(new Doubles::AnyArgument());
    }

}}
