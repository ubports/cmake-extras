#include "dbus-standard.h"
#include "dbus-namespaced.h"

#include <memory>
#include <gio/gio.h>
#include <glib.h>

using namespace std;

namespace {

static void test_standard()
{
    GError* error{nullptr};
    shared_ptr<DBus> proxy(dbus_proxy_new_for_bus_sync(G_BUS_TYPE_SYSTEM,
                                                       G_DBUS_PROXY_FLAGS_NONE,
                                                       "org.freedesktop.DBus",
                                                       "/",
                                                       nullptr,
                                                       &error),
                               &g_object_unref);
    g_assert_null(error);
    g_assert_nonnull(proxy.get());

    gchar* result_id{nullptr};
    dbus_call_get_id_sync(proxy.get(), &result_id, nullptr, &error);
    g_assert_null(error);

    g_assert_nonnull(result_id);
    g_free(result_id);
}

static void test_namespaced()
{
    GError* error{nullptr};
    shared_ptr<DBusDBus> proxy(dbus_dbus_proxy_new_for_bus_sync(G_BUS_TYPE_SYSTEM,
                                                                G_DBUS_PROXY_FLAGS_NONE,
                                                                "org.freedesktop.DBus",
                                                                "/",
                                                                nullptr,
                                                                &error),
                               &g_object_unref);
    g_assert_null(error);
    g_assert_nonnull(proxy.get());

    gchar* result_id{nullptr};
    dbus_dbus_call_get_id_sync(proxy.get(), &result_id, nullptr, &error);
    g_assert_null(error);

    g_assert_nonnull(result_id);
    g_free(result_id);
}

}

int main(int argc, char** argv) {
    g_test_init(&argc, &argv, nullptr);
    g_test_add_func("/gdbus-demo/generated", test_standard);
    g_test_add_func("/gdbus-demo/namespaced", test_namespaced);

    return g_test_run();
}
