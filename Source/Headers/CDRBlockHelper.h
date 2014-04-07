
// See http://clang.llvm.org/docs/Block-ABI-Apple.html
struct Block_literal {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor {
        unsigned long int reserved;
        unsigned long int size;

        union Block_descriptor_rest {
            struct rest_with_copy_dispose {
                void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
                void (*dispose_helper)(void *src);             // IFF (1<<25)
                const char *signature;
            } layout_with_copy_dispose;

            struct rest_without_copy_dispose {
                const char *signature;
            } layout_without_copy_dispose;
        } rest;
    } *descriptor;
};

