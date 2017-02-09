#pragma once

#include <memory>
#include <glib-object.h>

namespace demolib {
namespace bad {

inline std::unique_ptr<GObject, decltype(&g_object_unref)> make_gobject() {
    return std::unique_ptr<GObject, decltype(&g_object_unref)>(G_OBJECT(g_object_new(G_TYPE_OBJECT, nullptr)), &g_object_unref);
}

}
}
