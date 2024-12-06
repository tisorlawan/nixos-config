local utils = require("utils")
local used_ft = {}
local fpath = vim.fn.stdpath("config") .. "/ft"

if utils.file_exists(fpath) then
  for line in io.lines(fpath) do
    local trimmed_line = utils.trim(line)
    if trimmed_line:len() > 0 and trimmed_line:sub(1, 1) ~= "#" and trimmed_line:sub(1, 4) ~= "vim:" then
      table.insert(used_ft, trimmed_line)
    end
  end
end

local config = {
  blade = {
    formatters = { "blade-formatter" },
  },
  c = {
    formatters = { "clang_format" },
    servers = { "clangd" },
  },
  cabal = {
    formatters = { "cabal_fmt" },
  },
  css = {
    servers = { "tailwindcss" },
    linters = { "stylelint" },
  },
  dockerfile = {
    linters = { "hadolint" },
  },
  go = {
    formatters = { "gofumpt", "goimports", "golines" },
    servers = { "gopls" },
  },
  haskell = {
    formatters = { "ormolu" },
    servers = { "hls" },
  },
  html = {
    servers = { "html" },
    formatters = { "prettierd" },
    linters = { "htmlhint" },
  },
  javascript = {
    formatters = { "biome" },
  },
  json = {
    formatters = { "biome" },
    linters = { "jsonlint" },
    -- servers = { "jsonls" },
  },
  lua = {
    formatters = { "stylua" },
    servers = { "lua_ls" },
  },
  markdown = {
    linters = { "markdownlint" },
    formatters = { "prettierd" },
    servers = { "marksman" },
  },
  nix = {
    servers = { "nil_ls" },
    formatters = { "nixpkgs_fmt" },
  },
  php = {
    formatters = { "php_cs_fixer" },
    servers = { "phpactor", "html" },
  },
  python = {
    formatters = { "ruff_format", "ruff_organize_imports" },
    servers = { "pyright", "ruff" },
  },
  rust = {
    servers = { "rust_analyzer" },
    -- formatters = { "rustfmt", "leptosfmt" },
    formatters = { "rustfmt" },
  },
  sh = {
    servers = { "bashls" },
    formatters = { "shfmt" },
  },
  templ = {
    formatters = { "templ" },
    servers = { "templ" },
  },
  toml = {
    formatters = { "taplo" },
  },
  typescript = {
    formatters = { "prettierd" },
    servers = { "ts_ls", "eslint" },
  },
  typescriptreact = {
    formatters = { "prettierd" },
    servers = { "ts_ls", "eslint" },
  },
  zig = {
    formatters = { "zigfmt" },
    servers = { "zls" },
  },
}

local formatters_by_ft = {}
for _, ft in pairs(used_ft) do
  local cfg = (config[ft] or {}).formatters
  if cfg ~= nil then
    formatters_by_ft[ft] = cfg
  end
end

local linters_by_ft = {}
for _, ft in pairs(used_ft) do
  local cfg = (config[ft] or {}).linters
  if cfg ~= nil then
    linters_by_ft[ft] = cfg
  end
end

local M = {
  formatters_by_ft = formatters_by_ft,
  linters_by_ft = linters_by_ft,
  config = config,
  used_ft = used_ft,
}

return M
