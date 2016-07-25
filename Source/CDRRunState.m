#import "CDRRunState.h"

static CedarRunState CDRCurrentRunState = CedarRunStateNotYetStarted;

CedarRunState CDRCurrentState() {
    return CDRCurrentRunState;
}

void CDRSetCurrentRunState(CedarRunState runState) {
    CDRCurrentRunState = runState;
}
