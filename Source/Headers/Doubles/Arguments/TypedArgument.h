#import "Argument.h"

namespace Cedar { namespace Doubles {

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

}}
