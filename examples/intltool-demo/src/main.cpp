#include <memory>
#include <gio/gio.h>
#include <glib.h>
#include <libintl.h>

using namespace std;

namespace {

static inline char* _(const char *__msgid) {
    return gettext(__msgid);
}

static inline shared_ptr<char> get_string(char* s) {
    return shared_ptr<char>(s, &g_free);
}

static void translations() {
    shared_ptr<GKeyFile> gkf(g_key_file_new(), &g_key_file_free);

    GError* error = NULL;
    if (!g_key_file_load_from_file(gkf.get(), CONFIG_FILE, G_KEY_FILE_KEEP_TRANSLATIONS, &error)) {
        g_warning("Could not read config file '%s': %s", CONFIG_FILE, error->message);
        g_error_free(error);
        g_test_fail();
        return;
    }

    shared_ptr<char> tmp;

    // DisplayName translated through INI file
    tmp = get_string(g_key_file_get_locale_string(gkf.get(), "Config", "DisplayName", LANGUAGE, NULL));
    g_assert_cmpstr(tmp.get(), ==, "FooApp translated");

    // DisplayName translated through gettext
    tmp = get_string(g_key_file_get_string(gkf.get(), "Config", "DisplayName", NULL));
    g_assert_cmpstr(gettext(tmp.get()), ==, "FooApp translated");

    // Description translated through INI file
    tmp = get_string(g_key_file_get_locale_string(gkf.get(), "Config", "Description", LANGUAGE, NULL));
    g_assert_cmpstr(tmp.get(), ==, "FooApp is really great translated");

    // Description translated through gettext
    tmp = get_string(g_key_file_get_string(gkf.get(), "Config", "Description", NULL));
    g_assert_cmpstr(gettext(tmp.get()), ==, "FooApp is really great translated");

    // Plain gettext translation from extracted string in this .cpp file
    g_assert_cmpstr(_("Hello FooApp!"), ==, "Hello translated FooApp!");
}

static void schema_translations() {
    GSettingsSchemaSource* source = g_settings_schema_source_get_default();
    g_assert_nonnull(source);

    shared_ptr<GSettingsSchema> schema(g_settings_schema_source_lookup(source,
                                                                       "com.canonical.cmake-extras.translated-test",
                                                                       false),
                                       &g_settings_schema_unref);
    g_assert_nonnull(schema.get());

    shared_ptr<GSettingsSchemaKey> key(g_settings_schema_get_key(schema.get(), "translated"), &g_settings_schema_key_unref);
    g_assert_nonnull(key.get());

    auto summary = g_settings_schema_key_get_summary(key.get());
    auto description = g_settings_schema_key_get_description(key.get());

    g_assert_cmpstr(summary, ==, "Translated test mate");
    g_assert_cmpstr(description, ==, "G'day mate, it's a test!");
}

}

int main(int argc, char** argv) {
    g_unsetenv("LC_ALL");
    g_unsetenv("GDM_LANG");
    g_unsetenv("LANG");
    g_unsetenv("LANGUAGE");

    g_setenv("LANG", LANGUAGE, TRUE);

    setlocale(LC_ALL, "");

    bindtextdomain(GETTEXT_PACKAGE, LOCALE_DIR);
    bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");
    textdomain(GETTEXT_PACKAGE);

    g_test_init (&argc, &argv, NULL);
    g_test_add_func("/intltool-demo/translations", translations);
    g_test_add_func("/intltool-demo/schema-translations", schema_translations);

    return g_test_run();
}
