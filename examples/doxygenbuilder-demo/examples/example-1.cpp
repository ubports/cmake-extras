#include <my-namespace/my-class.h>

using namespace MyNamespace;

int main(int argc, char** argv) {
    //! [Creating the class.]
    MyClass foo;
    //! [Creating the class.]

    //! [Calling my method.]
    foo.myMethod("hello");
    //! [Calling my method.]

    //! [Calling my other method.]
    return foo.myOtherMethod();
    //! [Calling my other method.]
}
