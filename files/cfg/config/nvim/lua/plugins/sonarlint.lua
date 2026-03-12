return {
  'https://gitlab.com/schrieveslaach/sonarlint.nvim',
  name = 'sonarlint.nvim',
  lazy = true,
  init = function()
    vim.api.nvim_create_user_command('SonarlintEnable', function()
      require('lazy').load { plugins = { 'sonarlint.nvim' } }
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == 'python' then
          vim.api.nvim_exec_autocmds('FileType', { buffer = buf })
        end
      end
    end, { desc = 'Enable SonarLint for Python buffers' })
  end,
  opts = {
    server = {
      cmd = {
        'sonarlint-ls',
        '-stdio',
        '-analyzers',
        vim.fn.expand '$HOME/.rice/files/misc/sonarpython.jar',
      },
      settings = {
        sonarlint = {
          connectedMode = {
            connections = {
              sonarqube = {
                {
                  connectionId = 'gdp-admin',
                  serverUrl = 'https://sonarcloud.io',
                  disableNotifications = false,
                },
              },
              sonarcloud = {
                {
                  connectionId = 'gdp-admin',
                  serverUrl = 'https://sonarcloud.io',
                  region = 'US',
                  organizationKey = 'gdp-admin',
                  disableNotifications = false,
                },
              },
            },
          },
        },
      },
      before_init = function(params, config)
        local project_root_and_ids = {
          ['/home/agung-b-sorlawan/Documents/services-llm-service'] = 'nlp',
          ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-core'] = 'gllm-core',
          ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-privacy'] = 'gllm-core',
          ['/home/agung-b-sorlawan/Documents/gen-ai-internal/libs/gllm-evals'] = 'gllm-evals',
        }

        config.settings.sonarlint.connectedMode.project = {
          connectionId = 'gdp-admin',
          projectKey = project_root_and_ids[params.rootPath],
        }
      end,
    },
    filetypes = { 'python' },
  },
}
