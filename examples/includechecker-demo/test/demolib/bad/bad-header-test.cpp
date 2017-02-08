#include <demolib/bad/bad-header.h>

using namespace std;

namespace {

static void test_make_gobject() {
    auto o = demolib::bad::make_gobject();
}

}

int main(int argc, char** argv) {
    g_test_init (&argc, &argv, NULL);
    g_test_add_func("/includechecker-demo/bad-header/test_make_gobject", test_make_gobject);
    return g_test_run();
}
