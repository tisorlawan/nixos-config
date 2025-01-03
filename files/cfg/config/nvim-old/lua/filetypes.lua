vim.filetype.add({
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
})
