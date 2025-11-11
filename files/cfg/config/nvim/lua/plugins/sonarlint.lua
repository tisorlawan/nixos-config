return {
  "https://gitlab.com/schrieveslaach/sonarlint.nvim",
  opts = {
    server = {
      cmd = {
        "sonarlint-language-server",
        "-stdio",
        "-analyzers",
        vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
      },
      settings = {
        sonarlint = {
          connectedMode = {
            connections = {
              sonarqube = {
                {
                  connectionId = "sqa-obrol",
                  serverUrl = "https://sqa.obrol.id",
                  disableNotifications = false,
                },
              },
            },
          },
        },
      },

      before_init = function(params, config)
        local project_root_and_ids = {
          ["/home/agung-b-sorlawan/Documents/services-llm-service"] = "nlp",
        }

        config.settings.sonarlint.connectedMode.project = {
          connectionId = "sqa-obrol",
          projectKey = project_root_and_ids[params.rootPath],
        }
      end,
    },
    filetypes = {
      "python",
    },
  },
}
