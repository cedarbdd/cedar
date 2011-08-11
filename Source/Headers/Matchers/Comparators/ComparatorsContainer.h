#import <vector>
#import <map>
#import <set>

// Container
namespace Cedar { namespace Matchers { namespace Comparators {
#pragma mark Generic
    template<typename T>
    bool compare_empty(const T & container) {
        return 0 == [container count];
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
}}}
