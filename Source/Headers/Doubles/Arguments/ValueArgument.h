#import "Argument.h"
#import "CedarStringifiers.h"
#import "CedarComparators.h"

namespace Cedar { namespace Doubles {

    inline const char *strip_encoding_qualifiers(const char *);

    const char *strip_encoding_qualifiers(const char *encoding) {
        static const char *encoding_qualifiers = "rnNoORV";
        const char *stripped = encoding;
        while (strchr(encoding_qualifiers, stripped[0])) {
            ++ stripped;
        }
        return stripped;
    }

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

        virtual bool matches_encoding(const char *) const;
        virtual bool matches_bytes(void *) const;
        virtual unsigned int specificity_ranking() const;

    protected:
        bool matches_encoding_excluding_qualifiers(const char *) const;
        bool both_are_objects(const char *) const;
        bool both_are_not_objects(const char *) const;
        bool both_are_not_pointers(const char *) const;
        bool both_are_not_cstrings(const char *) const;
        bool both_are_not_objects_pointers_nor_cstrings(const char *) const;
        bool nil_argument(const char *) const;
        bool both_are_nil(void *) const;

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
    /* virtual */ bool ValueArgument<T>::matches_encoding(const char * actual_argument_encoding) const {
        return this->matches_encoding_excluding_qualifiers(actual_argument_encoding) ||
        this->both_are_not_objects_pointers_nor_cstrings(actual_argument_encoding) ||
        this->nil_argument(actual_argument_encoding);
    }

    template<typename T>
    /* virtual */ bool ValueArgument<T>::matches_bytes(void * actual_argument_bytes) const {
        if (actual_argument_bytes) {
            return (Matchers::Comparators::compare_equal(value_, *(static_cast<T *>(actual_argument_bytes))) ||
                    this->both_are_nil(actual_argument_bytes));
        } else {
            return false;
        }
    }

    template<typename T>
    /* virtual */ unsigned int ValueArgument<T>::specificity_ranking() const { return 1000; }

#pragma mark - Protected interface
    template<typename T>
    bool ValueArgument<T>::matches_encoding_excluding_qualifiers(const char * actual_argument_encoding) const {
        const char *encoding_excluding_qualifiers = strip_encoding_qualifiers(@encode(T));
        const char *actual_argument_encoding_excluding_qualifiers = strip_encoding_qualifiers(actual_argument_encoding);
        if (strlen(encoding_excluding_qualifiers) == strlen(actual_argument_encoding_excluding_qualifiers)) {
            return 0 == strcmp(encoding_excluding_qualifiers, actual_argument_encoding_excluding_qualifiers);
        }
        return false;
    }

    template<typename T>
    bool ValueArgument<T>::both_are_objects(const char * actual_argument_encoding) const {
        return 0 == strncmp(@encode(T), "@", 1) && 0 == strncmp(actual_argument_encoding, "@", 1);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_not_objects(const char * actual_argument_encoding) const {
        return 0 != strncmp(@encode(T), "@", 1) && 0 != strncmp(actual_argument_encoding, "@", 1);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_not_pointers(const char * actual_argument_encoding) const {
        return 0 != strncmp(@encode(T), "^", 1) && 0 != strncmp(actual_argument_encoding, "^", 1);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_not_cstrings(const char * actual_argument_encoding) const {
        return 0 != strncmp(@encode(T), "*", 1) && 0 != strncmp(actual_argument_encoding, "*", 1);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_not_objects_pointers_nor_cstrings(const char * actual_argument_encoding) const {
        return this->both_are_not_objects(actual_argument_encoding) &&
        this->both_are_not_pointers(actual_argument_encoding) &&
        this->both_are_not_cstrings(actual_argument_encoding);
    }

    template<typename T>
    bool ValueArgument<T>::nil_argument(const char * actual_argument_encoding) const {
        void *nil_pointer = 0;
        return 0 == strncmp(actual_argument_encoding, "@", 1) && this->matches_bytes(&nil_pointer);
    }

    template<typename T>
    bool ValueArgument<T>::both_are_nil(void * actual_argument_bytes) const {
        return (0 == strncmp(@encode(T), "@", 1) &&
                [[NSValue value:&value_ withObjCType:@encode(T)] nonretainedObjectValue] == nil &&
                [[NSValue value:actual_argument_bytes withObjCType:@encode(id)] nonretainedObjectValue] == nil);
    }

#pragma mark - CharValueArgument
    class CharValueArgument : public ValueArgument<const char*> {
    public:
        explicit CharValueArgument(const char *value) : ValueArgument<const char*>(value) {};
        virtual bool matches_encoding(const char * actual_argument_encoding) const {
            return this->both_are_objects(actual_argument_encoding) ||
            this->both_are_cstrings(actual_argument_encoding) ||
            this->nil_argument(actual_argument_encoding);
        }
    private:
        bool both_are_cstrings(const char * actual_argument_encoding) const {
            return this->both_are_not_objects(actual_argument_encoding) &&
            this->both_are_not_pointers(actual_argument_encoding) &&
            0 == strncmp(actual_argument_encoding, "*", 1);
        }
    };

}}
