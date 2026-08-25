#include <emacs-module.h>

#include <dlfcn.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int plugin_is_GPL_compatible;

#define FFF_CREATE_OPTIONS_VERSION 2

typedef struct FffResult {
    bool success;
    char *error;
    void *handle;
    int64_t int_value;
} FffResult;

typedef struct FffCreateOptions {
    uint32_t version;
    const char *base_path;
    const char *frecency_db_path;
    const char *history_db_path;
    bool enable_mmap_cache;
    bool enable_content_indexing;
    bool watch;
    bool ai_mode;
    const char *log_file_path;
    const char *log_level;
    uint64_t cache_budget_max_files;
    uint64_t cache_budget_max_bytes;
    uint64_t cache_budget_max_file_size;
    bool enable_fs_root_scanning;
    bool enable_home_dir_scanning;
    bool follow_symlinks;
} FffCreateOptions;

typedef struct FffSearchResult FffSearchResult;
typedef struct FffGrepResult FffGrepResult;
typedef struct FffFileItem FffFileItem;
typedef struct FffGrepMatch FffGrepMatch;

typedef struct FffScore {
    int32_t total;
    int32_t base_score;
    int32_t filename_bonus;
    int32_t special_filename_bonus;
    int32_t frecency_boost;
    int32_t distance_penalty;
    int32_t current_file_penalty;
    int32_t combo_match_boost;
    int32_t path_alignment_bonus;
    bool exact_match;
    char *match_type;
} FffScore;

typedef FffResult *(*fff_create_instance_with_fn)(const FffCreateOptions *opts);
typedef void (*fff_destroy_fn)(void *handle);
typedef FffResult *(*fff_wait_for_scan_fn)(void *handle, uint64_t timeout_ms);
typedef FffResult *(*fff_search_fn)(void *handle, const char *query, const char *current_file,
                                    uint32_t max_threads, uint32_t page_index, uint32_t page_size,
                                    int32_t combo_boost_multiplier, uint32_t min_combo_count);
typedef FffResult *(*fff_live_grep_fn)(void *handle, const char *query, uint8_t mode,
                                       uint64_t max_file_size, uint32_t max_matches_per_file,
                                       bool smart_case, uint32_t file_offset, uint32_t page_limit,
                                       uint64_t time_budget_ms, uint32_t before_context,
                                       uint32_t after_context, bool classify_definitions);
typedef void (*fff_free_result_fn)(FffResult *result);
typedef void (*fff_free_search_result_fn)(FffSearchResult *result);
typedef void (*fff_free_grep_result_fn)(FffGrepResult *result);
typedef uint32_t (*fff_search_result_get_count_fn)(const FffSearchResult *result);
typedef uint32_t (*fff_search_result_get_total_matched_fn)(const FffSearchResult *result);
typedef const FffFileItem *(*fff_search_result_get_item_fn)(const FffSearchResult *result, uint32_t index);
typedef const FffScore *(*fff_search_result_get_score_fn)(const FffSearchResult *result, uint32_t index);
typedef const char *(*fff_file_item_get_relative_path_fn)(const FffFileItem *item);
typedef const char *(*fff_file_item_get_file_name_fn)(const FffFileItem *item);
typedef const char *(*fff_file_item_get_git_status_fn)(const FffFileItem *item);
typedef uint64_t (*fff_file_item_get_size_fn)(const FffFileItem *item);
typedef int64_t (*fff_file_item_get_total_frecency_score_fn)(const FffFileItem *item);
typedef uint32_t (*fff_grep_result_get_count_fn)(const FffGrepResult *result);
typedef uint32_t (*fff_grep_result_get_total_matched_fn)(const FffGrepResult *result);
typedef uint32_t (*fff_grep_result_get_next_file_offset_fn)(const FffGrepResult *result);
typedef const FffGrepMatch *(*fff_grep_result_get_match_fn)(const FffGrepResult *result, uint32_t index);
typedef const char *(*fff_grep_match_get_relative_path_fn)(const FffGrepMatch *match);
typedef const char *(*fff_grep_match_get_file_name_fn)(const FffGrepMatch *match);
typedef const char *(*fff_grep_match_get_git_status_fn)(const FffGrepMatch *match);
typedef const char *(*fff_grep_match_get_line_content_fn)(const FffGrepMatch *match);
typedef uint64_t (*fff_grep_match_get_line_number_fn)(const FffGrepMatch *match);
typedef uint32_t (*fff_grep_match_get_col_fn)(const FffGrepMatch *match);
typedef bool (*fff_grep_match_get_is_definition_fn)(const FffGrepMatch *match);

static void *fff_library;
static char *fff_library_path;
static char *fff_root;
static void *fff_handle;
static char fff_load_error[512];

static fff_create_instance_with_fn p_create;
static fff_destroy_fn p_destroy;
static fff_wait_for_scan_fn p_wait;
static fff_search_fn p_search;
static fff_live_grep_fn p_grep;
static fff_free_result_fn p_free_result;
static fff_free_search_result_fn p_free_search;
static fff_free_grep_result_fn p_free_grep;
static fff_search_result_get_count_fn p_search_count;
static fff_search_result_get_total_matched_fn p_search_total;
static fff_search_result_get_item_fn p_search_item;
static fff_search_result_get_score_fn p_search_score;
static fff_file_item_get_relative_path_fn p_file_path;
static fff_file_item_get_file_name_fn p_file_name;
static fff_file_item_get_git_status_fn p_file_status;
static fff_file_item_get_size_fn p_file_size;
static fff_file_item_get_total_frecency_score_fn p_file_frecency;
static fff_grep_result_get_count_fn p_grep_count;
static fff_grep_result_get_total_matched_fn p_grep_total;
static fff_grep_result_get_next_file_offset_fn p_grep_next;
static fff_grep_result_get_match_fn p_grep_match;
static fff_grep_match_get_relative_path_fn p_match_path;
static fff_grep_match_get_file_name_fn p_match_name;
static fff_grep_match_get_git_status_fn p_match_status;
static fff_grep_match_get_line_content_fn p_match_line;
static fff_grep_match_get_line_number_fn p_match_line_number;
static fff_grep_match_get_col_fn p_match_col;
static fff_grep_match_get_is_definition_fn p_match_definition;

static emacs_value intern(emacs_env *env, const char *name) {
    return env->intern(env, name);
}

static emacs_value string_value(emacs_env *env, const char *s) {
    return env->make_string(env, s ? s : "", s ? (ptrdiff_t)strlen(s) : 0);
}

static char *copy_lisp_string(emacs_env *env, emacs_value value) {
    ptrdiff_t size = 0;
    env->copy_string_contents(env, value, NULL, &size);
    char *buffer = malloc((size_t)size);
    if (!buffer) return NULL;
    env->copy_string_contents(env, value, buffer, &size);
    return buffer;
}

static emacs_value signal_error(emacs_env *env, const char *message) {
    emacs_value data[] = {string_value(env, message)};
    env->non_local_exit_signal(env, intern(env, "error"), env->funcall(env, intern(env, "list"), 1, data));
    return intern(env, "nil");
}

static void *load_symbol(const char *name) {
    return dlsym(fff_library, name);
}

static bool load_library(void) {
    if (fff_library) return true;
    fff_load_error[0] = '\0';
    const char *path = fff_library_path && fff_library_path[0] ? fff_library_path : "libfff_c.so";
    fff_library = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!fff_library) {
        const char *error = dlerror();
        snprintf(fff_load_error, sizeof(fff_load_error), "%s",
                 error ? error : "unable to load libfff_c.so");
        return false;
    }

#define LOAD(name, field) do {                                                \
    dlerror();                                                               \
    field = (name##_fn)load_symbol(#name);                                   \
    if (!field) {                                                            \
        const char *error = dlerror();                                       \
        snprintf(fff_load_error, sizeof(fff_load_error),                     \
                 "missing FFF symbol %s: %s", #name,                        \
                 error ? error : "unknown dynamic loader error");           \
        dlclose(fff_library);                                                \
        fff_library = NULL;                                                  \
        return false;                                                        \
    }                                                                        \
} while (0)
    LOAD(fff_create_instance_with, p_create);
    LOAD(fff_destroy, p_destroy);
    LOAD(fff_wait_for_scan, p_wait);
    LOAD(fff_search, p_search);
    LOAD(fff_live_grep, p_grep);
    LOAD(fff_free_result, p_free_result);
    LOAD(fff_free_search_result, p_free_search);
    LOAD(fff_free_grep_result, p_free_grep);
    LOAD(fff_search_result_get_count, p_search_count);
    LOAD(fff_search_result_get_total_matched, p_search_total);
    LOAD(fff_search_result_get_item, p_search_item);
    LOAD(fff_search_result_get_score, p_search_score);
    LOAD(fff_file_item_get_relative_path, p_file_path);
    LOAD(fff_file_item_get_file_name, p_file_name);
    LOAD(fff_file_item_get_git_status, p_file_status);
    LOAD(fff_file_item_get_size, p_file_size);
    LOAD(fff_file_item_get_total_frecency_score, p_file_frecency);
    LOAD(fff_grep_result_get_count, p_grep_count);
    LOAD(fff_grep_result_get_total_matched, p_grep_total);
    LOAD(fff_grep_result_get_next_file_offset, p_grep_next);
    LOAD(fff_grep_result_get_match, p_grep_match);
    LOAD(fff_grep_match_get_relative_path, p_match_path);
    LOAD(fff_grep_match_get_file_name, p_match_name);
    LOAD(fff_grep_match_get_git_status, p_match_status);
    LOAD(fff_grep_match_get_line_content, p_match_line);
    LOAD(fff_grep_match_get_line_number, p_match_line_number);
    LOAD(fff_grep_match_get_col, p_match_col);
    LOAD(fff_grep_match_get_is_definition, p_match_definition);
#undef LOAD
    return true;
}

static emacs_value Fset_library_path(emacs_env *env, ptrdiff_t nargs, emacs_value *args, void *data) {
    (void)nargs; (void)data;
    char *path = copy_lisp_string(env, args[0]);
    if (!path) return signal_error(env, "out of memory");
    if (fff_library) {
        free(path);
        return signal_error(env, "FFF library path must be set before the first FFF call");
    }
    free(fff_library_path);
    fff_library_path = path;
    return intern(env, "t");
}

static bool ensure_instance(const char *root, uint64_t timeout_ms, char **error) {
    if (!load_library()) {
        *error = strdup(fff_load_error[0]
                        ? fff_load_error
                        : "libfff_c.so is unavailable");
        return false;
    }
    if (fff_handle && fff_root && strcmp(fff_root, root) == 0) return true;
    if (fff_handle) p_destroy(fff_handle);
    free(fff_root);
    fff_handle = NULL;
    fff_root = NULL;

    FffCreateOptions opts = {0};
    opts.version = FFF_CREATE_OPTIONS_VERSION;
    opts.base_path = root;
    opts.enable_mmap_cache = true;
    opts.enable_content_indexing = true;
    opts.watch = true;
    opts.ai_mode = false;
    opts.enable_home_dir_scanning = true;

    FffResult *created = p_create(&opts);
    if (!created || !created->success) {
        *error = strdup(created && created->error ? created->error : "failed to create FFF instance");
        if (created) p_free_result(created);
        return false;
    }
    fff_handle = created->handle;
    p_free_result(created);

    FffResult *waited = p_wait(fff_handle, timeout_ms);
    if (!waited || !waited->success) {
        *error = strdup(waited && waited->error ? waited->error : "FFF scan failed");
        if (waited) p_free_result(waited);
        p_destroy(fff_handle);
        fff_handle = NULL;
        return false;
    }
    p_free_result(waited);
    fff_root = strdup(root);
    return true;
}

static emacs_value plist_file(emacs_env *env, const FffFileItem *item, const FffScore *score) {
    emacs_value args[14] = {
    intern(env, ":path"), string_value(env, p_file_path(item)),
    intern(env, ":name"), string_value(env, p_file_name(item)),
    intern(env, ":git-status"), string_value(env, p_file_status(item)),
    intern(env, ":size"), env->make_integer(env, (intmax_t)p_file_size(item)),
    intern(env, ":frecency"), env->make_integer(env, (intmax_t)p_file_frecency(item)),
    intern(env, ":score"), env->make_integer(env, score ? score->total : 0),
    intern(env, ":type"), intern(env, "file")
};
    return env->funcall(env, intern(env, "list"), 14, args);
}

static emacs_value plist_match(emacs_env *env, const FffGrepMatch *match) {
    emacs_value args[16] = {
    intern(env, ":path"), string_value(env, p_match_path(match)),
    intern(env, ":name"), string_value(env, p_match_name(match)),
    intern(env, ":git-status"), string_value(env, p_match_status(match)),
    intern(env, ":line"), env->make_integer(env, (intmax_t)p_match_line_number(match)),
    intern(env, ":column"), env->make_integer(env, (intmax_t)p_match_col(match) + 1),
    intern(env, ":text"), string_value(env, p_match_line(match)),
    intern(env, ":definition"), p_match_definition(match) ? intern(env, "t") : intern(env, "nil"),
    intern(env, ":type"), intern(env, "grep")
};
    return env->funcall(env, intern(env, "list"), 16, args);
}

static emacs_value Fsearch(emacs_env *env, ptrdiff_t nargs, emacs_value *args, void *data) {
    (void)nargs; (void)data;
    char *root = copy_lisp_string(env, args[0]);
    char *query = copy_lisp_string(env, args[1]);
    char *current = copy_lisp_string(env, args[2]);
    char *error = NULL;
    if (!root || !query || !current) return signal_error(env, "out of memory");
    if (!ensure_instance(root, 10000, &error)) {
        emacs_value result = signal_error(env, error);
        free(root); free(query); free(current); free(error);
        return result;
    }
    FffResult *raw = p_search(fff_handle, query, current, 0, 0, 100, 100, 3);
    if (!raw || !raw->success) {
        emacs_value result = signal_error(env, raw && raw->error ? raw->error : "FFF file search failed");
        if (raw) p_free_result(raw);
        free(root); free(query); free(current);
        return result;
    }
    FffSearchResult *search = raw->handle;
    uint32_t count = p_search_count(search);
    emacs_value list = intern(env, "nil");
    for (uint32_t i = count; i > 0; --i) {
        const FffFileItem *item = p_search_item(search, i - 1);
        const FffScore *score = p_search_score(search, i - 1);
        emacs_value cons_args[] = {plist_file(env, item, score), list};
        list = env->funcall(env, intern(env, "cons"), 2, cons_args);
    }
    p_free_search(search);
    p_free_result(raw);
    free(root); free(query); free(current);
    return list;
}

static emacs_value Fgrep(emacs_env *env, ptrdiff_t nargs, emacs_value *args, void *data) {
    (void)nargs; (void)data;
    char *root = copy_lisp_string(env, args[0]);
    char *query = copy_lisp_string(env, args[1]);
    intmax_t mode_value = env->extract_integer(env, args[2]);
    char *error = NULL;
    if (!root || !query) {
        free(root); free(query);
        return signal_error(env, "out of memory");
    }
    if (mode_value < 0 || mode_value > 2) {
        free(root); free(query);
        return signal_error(env, "FFF grep mode must be 0, 1, or 2");
    }
    uint8_t mode = (uint8_t)mode_value;
    if (!ensure_instance(root, 10000, &error)) {
        emacs_value result = signal_error(env, error);
        free(root); free(query); free(error);
        return result;
    }
    FffResult *raw = p_grep(fff_handle, query, mode, 10 * 1024 * 1024, 100, true, 0, 100, 150, 0, 0, true);
    if (!raw || !raw->success) {
        emacs_value result = signal_error(env, raw && raw->error ? raw->error : "FFF grep failed");
        if (raw) p_free_result(raw);
        free(root); free(query);
        return result;
    }
    FffGrepResult *grep = raw->handle;
    uint32_t count = p_grep_count(grep);
    emacs_value list = intern(env, "nil");
    for (uint32_t i = count; i > 0; --i) {
        const FffGrepMatch *match = p_grep_match(grep, i - 1);
        emacs_value cons_args[] = {plist_match(env, match), list};
        list = env->funcall(env, intern(env, "cons"), 2, cons_args);
    }
    p_free_grep(grep);
    p_free_result(raw);
    free(root); free(query);
    return list;
}

static void bind_function(emacs_env *env, const char *name, emacs_value function) {
    emacs_value args[] = {intern(env, name), function};
    env->funcall(env, intern(env, "defalias"), 2, args);
}

int emacs_module_init(struct emacs_runtime *runtime) {
    emacs_env *env = runtime->get_environment(runtime);
    bind_function(env, "tiso-fff-module-search",
                  env->make_function(env, 3, 3, Fsearch, "Search files with libfff_c.", NULL));
    bind_function(env, "tiso-fff-module-grep",
                  env->make_function(env, 3, 3, Fgrep, "Search content with libfff_c.", NULL));
    bind_function(env, "tiso-fff-module-set-library-path",
                  env->make_function(env, 1, 1, Fset_library_path, "Set libfff_c path before first use.", NULL));
    emacs_value provide_args[] = {intern(env, "tiso-fff-module")};
    env->funcall(env, intern(env, "provide"), 1, provide_args);
    return 0;
}
