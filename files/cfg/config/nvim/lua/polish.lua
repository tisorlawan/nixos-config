vim.filetype.add {
  extension = {
    ["env"] = "bash",
    ["templ"] = "templ",
    ["sls"] = "scheme",
  },
  filename = {
    [".env"] = "bash",
    [".env.template"] = "bash",
    [".env.example"] = "bash",
    ["poetry.lock"] = "toml",
    ["composer.lock"] = "json",
  },
}

-- -- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }
