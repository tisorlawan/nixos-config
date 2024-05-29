vim.filetype.add({
  extension = {
    ["env"] = "bash",
    ["templ"] = "templ",
    ["sls"] = "scheme",
  },
  filename = {
    [".env"] = "bash",
    [".env.template"] = "bash",
    ["poetry.lock"] = "toml",
  },
})
