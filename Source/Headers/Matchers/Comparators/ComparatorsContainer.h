#import <vector>
#import <map>
#import <set>
#import <algorithm>

// Container
namespace Cedar { namespace Matchers { namespace Comparators {
#pragma mark compare_empty
    template<typename T>
    bool compare_empty(const T & container) {
        if ([container respondsToSelector:@selector(count)]) {
            return 0 == [container performSelector:@selector(count)];
        } else {
            return 0 == [container performSelector:@selector(length)];
        }
    }

    template<typename T>
    bool compare_empty(const typename std::vector<T> & container) {
        return container.empty();
    }

    template<typename T, typename U>
    bool compare_empty(const typename std::map<T, U> & container) {
        return container.empty();
    }

    template<typename T>
    bool compare_empty(const typename std::set<T> & container) {
        return container.empty();
    }

#pragma mark compare_contains
    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, NSString *elementsKeyPath, bool nested, F comparator) {
        for (id object in elementsKeyPath ? [container valueForKeyPath:elementsKeyPath] : container) {
            if (comparator(object, element)) {
                return YES;
            }

            if (nested && [(elementsKeyPath ? [object valueForKeyPath:elementsKeyPath] : object) respondsToSelector:@selector(containsObject:)] && compare_contains(object, element, elementsKeyPath, nested, comparator)) {
                return YES;
            }
        }

        return NO;
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, bool nested, F comparator) {
        return compare_contains(container, element, nil, nested, comparator);
    }

/////
    template<typename T, typename U, typename F>
    bool compare_contains(const T & container, const U & element, F comparator) {
        return container.end() != std::find_if(container.begin(), container.end(), [=](const U &lhs) { return comparator(lhs, element);});
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const std::vector<T> & container, const U & element, bool nested, F comparator) {
        return compare_contains(container, element, comparator);
    }

    template<typename U>
    bool compare_contains(const std::vector<U> & container, const U & element, bool nested) {
        return compare_contains(container, element, nested, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }

    template<typename T, typename U, typename F>
    bool compare_contains(const std::set<T> & container, const U & element, bool nested, F comparator) {
        return compare_contains(container, element, comparator);
    }

    template<typename U>
    bool compare_contains(const std::set<U> & container, const U & element, bool nested) {
        return compare_contains(container, element, nested, [](const U & lhs, const U & rhs) { return compare_equal(lhs, rhs); });
    }
/////

    template<typename U>
    bool compare_contains(NSDictionary * const container, const U & element, bool nested) {
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'contain' matcher with dictionary; use contain_key or contain_value" userInfo:nil] raise];
        return false;
    }

    template<typename U, typename F>
    bool compare_contains(NSDictionary * const container, const U & element, bool nested, F comparator) {
        return compare_contains(container, element, nested);
    }

    template<typename U>
    bool compare_contains(NSMutableDictionary * const container, const U & element, bool nested) {
        return compare_contains(static_cast<NSDictionary * const>(container), element, nested);
    }

    template<typename U, typename F>
    bool compare_contains(NSMutableDictionary * const container, const U & element, bool nested, F comparator) {
        return compare_contains(static_cast<NSDictionary * const>(container), element, nested);
    }

    template<typename T, typename U, typename V>
    bool compare_contains(const typename std::map<T, U> & container, const V & element, bool nested) {
        return compare_contains(static_cast<NSDictionary * const>(nil), element, nested);
    }

    template<typename T, typename U, typename V, typename F>
    bool compare_contains(const typename std::map<T, U> & container, const V & element, bool nested, F comparator) {
        return compare_contains(static_cast<NSDictionary * const>(nil), element, nested);
    }

/////
    template<typename U>
    bool compare_contains(NSString * const container, const U & element, bool nested) {
        if (nested) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'nested' modifier on 'contain' matcher with string" userInfo:nil] raise];
        }
        NSRange range = [container rangeOfString:element];
        return container && range.location != NSNotFound;
    }

    template<typename U>
    bool compare_contains(NSMutableString * const container, const U & element, bool nested) {
        return compare_contains(static_cast<NSString * const>(container), element, nested);
    }

    template<typename U>
    bool compare_contains(char *actualValue, const U & expectedContains, bool nested) {
        if (nested) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unexpected use of 'nested' modifier on 'contain' matcher with string" userInfo:nil] raise];
        }
        return actualValue != NULL && strstr(actualValue, expectedContains) != NULL;
    }

    template<typename U>
    bool compare_contains(const char *actualValue, const U & expectedContains, bool nested) {
        return compare_contains((char *)actualValue, expectedContains, nested);
    }
}}}
