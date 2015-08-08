#import "ValueArgument.h"

namespace Cedar { namespace Doubles {

    class ReturnValue {
    public:
        virtual ~ReturnValue() = 0;

        virtual const char * const value_encoding() const = 0;
        virtual void * value_bytes() const = 0;
        virtual bool compatible_with_encoding(const char *) const = 0;

        typedef std::shared_ptr<ReturnValue> shared_ptr_t;
    };

    inline /* virtual */ ReturnValue::~ReturnValue() {}

    template<typename T>
    class TypedReturnValue : public ReturnValue {
    private:
        TypedReturnValue<T> & operator=(const TypedReturnValue<T> &);

    public:
        explicit TypedReturnValue(const T &);
        virtual ~TypedReturnValue();

        virtual const char * const value_encoding() const;
        virtual void * value_bytes() const;
        virtual bool compatible_with_encoding(const char *) const;

    private:
        bool matches_encoding(const char *)const;

    private:
        const T value_;
    };

    template<typename T>
    TypedReturnValue<T>::TypedReturnValue(const T & value) : value_(value) {}

    template<typename T>
    /* virtual */ TypedReturnValue<T>::~TypedReturnValue() {}

    template<typename T>
    /* virtual */ const char * const TypedReturnValue<T>::value_encoding() const {
        return @encode(T);
    }

    template<typename T>
    /* virtual */ void * TypedReturnValue<T>::value_bytes() const {
        return (const_cast<T *>(&value_));
    }

    template<typename T>
    /* virtual */ bool TypedReturnValue<T>::compatible_with_encoding(const char * actual_argument_encoding) const {
        return matches_encoding(actual_argument_encoding);
    }

    template<>
    /* virtual */ inline bool TypedReturnValue<std::nullptr_t>::compatible_with_encoding(const char * actual_argument_encoding) const {
        return 0 == strcmp(@encode(id), actual_argument_encoding);
    }

    template<>
    /* virtual */ inline bool TypedReturnValue<NSInteger>::compatible_with_encoding(const char * actual_argument_encoding) const {
        return (value_ == (NSInteger)nil && 0 == strcmp(@encode(id), actual_argument_encoding)) || this->matches_encoding(actual_argument_encoding);
    }

    template<typename T>
    bool TypedReturnValue<T>::matches_encoding(const char * actual_argument_encoding) const {
        return 0 == strcmp(@encode(T), actual_argument_encoding);
    }
}}
