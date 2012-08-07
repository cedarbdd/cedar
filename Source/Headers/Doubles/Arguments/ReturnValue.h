#import "TypedArgument.h"

namespace Cedar { namespace Doubles {

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

}}
