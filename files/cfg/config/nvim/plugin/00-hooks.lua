local hooks = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind

  if (name == 'blink.cmp' or name == 'parinfer-rust') and (kind == 'install' or kind == 'update') then
    vim
      .system({ 'cargo', 'build', '--release' }, {
        cwd = ev.data.path,
        env = {
          CARGO_TARGET_DIR = 'target',
        },
      })
      :wait()
  end

  if (name == 'fff.nvim') and (kind == 'install' or kind == 'update') then
    if not ev.data.active then
      vim.cmd.packadd 'fff.nvim'
    end
    require('fff.download').download_or_build_binary()
  end

  if (name == 'nvim-treesitter') and (kind == 'install' or kind == 'update') then
    if not ev.data.active then
      vim.cmd.packadd 'nvim-treesitter'
    end
    vim.cmd 'TSUpdate'
  end
end

vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })
