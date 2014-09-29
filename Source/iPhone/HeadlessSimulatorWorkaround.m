#import "HeadlessSimulatorWorkaround.h"
#import <objc/runtime.h>

void suppressStandardPipesWhileLoadingClasses() {
    int saved_stdout = dup(STDOUT_FILENO);
    int saved_stderr = dup(STDERR_FILENO);
    freopen("/dev/null", "w", stdout);
    freopen("/dev/null", "w", stderr);

    unsigned int count = 0;
    Class *classes = objc_copyClassList(&count);
    for (int i = 0; i < count; i++) {
        if (class_respondsToSelector(classes[i], @selector(initialize))) {
            [classes[i] initialize];
        }
    }
    free(classes);

    dup2(saved_stdout, STDOUT_FILENO);
    dup2(saved_stderr, STDERR_FILENO);
}

