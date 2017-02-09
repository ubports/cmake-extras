#include <demolib/good-header.h>
#include <glib.h>

using namespace std;

namespace {

static void test_new_unique_string() {
    auto s = demolib::new_unique_string();    
    g_assert_cmpstr(s->c_str(), ==, "hi");
}

}

int main(int argc, char** argv) {
    g_test_init (&argc, &argv, NULL);
    g_test_add_func("/includechecker-demo/good-header/test_new_unique_string", test_new_unique_string);
    return g_test_run();
}
