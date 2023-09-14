local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
  -- {{{ Libraries
  {
    "https://github.com/nvim-lua/plenary.nvim",
    lazy = true,
  },
  -- }}}

  -- {{{ UI
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000
  },
  {
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    config = function()
      require("ibl").setup({
        indent = {
          char = "▏",
          tab_char = "→",
        },
        scope = {
          enabled = false,
        },
      })
    end,
  },
  -- }}}}

  -- {{{ Miscellaneous
  {
    "https://github.com/farmergreg/vim-lastplace",
    event = "BufReadPost",
  },
  -- }}}}
})
