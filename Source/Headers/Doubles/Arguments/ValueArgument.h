#import "Argument.h"

namespace Cedar { namespace Doubles {

    template<typename T>
    class ValueArgument : public Argument {
    private:
        ValueArgument<T> & operator=(const ValueArgument<T> &);

    public:
        explicit ValueArgument(const T &);
        virtual ~ValueArgument();
        // Allow default copy ctor.

        virtual const char * const value_encoding() const;
        virtual void * value_bytes() const;
        virtual NSString * value_string() const;
        virtual size_t value_size() const;

        virtual bool matches_encoding(const char * expected_argument_encoding) const;
        virtual bool matches_bytes(void * expected_argument_bytes) const;

    private:
        bool both_are_objects(const char * expected_argument_encoding) const;
        bool both_are_not_objects(const char * expected_argument_encoding) const;
        bool nil_argument(const char * expected_argument_encoding) const;

    private:
        const T value_;
    };


    template<typename T>
    ValueArgument<T>::ValueArgument(const T & value) : Argument(), value_(value) {}

    template<typename T>
    /* virtual */ ValueArgument<T>::~ValueArgument() {}

    template<typename T>
    /* virtual */ const char * const ValueArgument<T>::value_encoding() const {
        return @encode(T);
    }

    template<typename T>
    /* virtual */ void * ValueArgument<T>::value_bytes() const {
        return (const_cast<T *>(&value_));
    }

    template<typename T>
    /* virtual */ NSString * ValueArgument<T>::value_string() const {
        return Matchers::Stringifiers::string_for(value_);
    }

    template<typename T>
    /* virtual */ size_t ValueArgument<T>::value_size() const {
        return sizeof(T);
    }

    template<typename T>
    /* virtual */ bool ValueArgument<T>::matches_encoding(const char * expected_argument_encoding) const {
        return this->both_are_objects(expected_argument_encoding) ||
        this->both_are_not_objects(expected_argument_encoding) ||
        this->nil_argument(expected_argument_encoding);
    }

    template<typename T>
    /* virtual */ bool ValueArgument<T>::matches_bytes(void * expected_argument_bytes) const {
        return Matchers::Comparators::compare_equal(value_, *(static_cast<T *>(expected_argument_bytes)));
    }

#pragma mark - Private interface
    template<typename T>
    bool ValueArgument<T>::both_are_objects(const char * expected_argument_encoding) const {
        return 0 == strncmp(@encode(T), "@", 1) && 0 == strncmp(expected_argument_encoding, "@", 1);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_not_objects(const char * expected_argument_encoding) const {
        return 0 != strncmp(@encode(T), "@", 1) && 0 != strncmp(expected_argument_encoding, "@", 1);
    }

    template<typename T>
    bool ValueArgument<T>::nil_argument(const char * expected_argument_encoding) const {
        void *nil_pointer = 0;
        return 0 == strncmp(expected_argument_encoding, "@", 1) && this->matches_bytes(&nil_pointer);
    }

}}
