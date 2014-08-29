#pragma mark - private interface
namespace Cedar { namespace Matchers { namespace Private {

    class AnInstanceOf {
    private:
        AnInstanceOf & operator=(const AnInstanceOf &);

    public:
        explicit AnInstanceOf(const Class);
        virtual ~AnInstanceOf();
        // Allow default copy ctor.

        AnInstanceOf & or_any_subclass();

        NSString * expected_class_string() const;

        template<typename U>
        bool matches(const U &, Comparators::contains_options) const;
    private:
        const Class class_;
        bool includesSubclasses_;
    };

    inline AnInstanceOf::AnInstanceOf(const Class klass)
    : class_(klass), includesSubclasses_(false) {
    }

    inline /* virtual */ AnInstanceOf::~AnInstanceOf() {
    }

    inline AnInstanceOf & AnInstanceOf::or_any_subclass() {
        includesSubclasses_ = true;
        return *this;
    }

    inline NSString * AnInstanceOf::expected_class_string() const {
        return [NSString stringWithFormat:@"an instance of %@%@", Stringifiers::string_for(class_), includesSubclasses_ ? @" or any subclass" : @""];
    }

#pragma mark - Matches
    template<typename U>
    bool AnInstanceOf::matches(const U & container, Comparators::contains_options options) const {
        return Comparators::compare_contains(container,
                                             class_,
                                             options,
                                             includesSubclasses_ ? [](id lhs, Class rhs) { return [lhs isKindOfClass:rhs]; } : [](id lhs, Class rhs) { return [lhs isMemberOfClass:rhs]; });
    }

#pragma mark Matches Strings
    template<>
    inline bool AnInstanceOf::matches(char * const & container, Comparators::contains_options options) const {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'contain' matcher to check for an object in a string" userInfo:nil] raise];
        return false;
    }

    template<>
    inline bool AnInstanceOf::matches(const char * const & container, Comparators::contains_options options) const {
        return matches((char *)container, options);
    }

    template<>
    inline bool AnInstanceOf::matches(NSString * const & container, Comparators::contains_options options) const {
        return matches((char *)nil, options);
    }

    template<>
    inline bool AnInstanceOf::matches(NSMutableString * const & container, Comparators::contains_options options) const {
        return matches((char *)nil, options);
    }
}}}

#pragma mark - public interface
namespace Cedar { namespace Matchers {
    using CedarAnInstanceOf = Cedar::Matchers::Private::AnInstanceOf;
    inline CedarAnInstanceOf an_instance_of(Class klass) {
        return CedarAnInstanceOf(klass);
    }
}}
