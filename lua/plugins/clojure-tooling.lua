return {
  "Olical/conjure",
  "guns/vim-sexp",
  "tpope/vim-sexp-mappings-for-regular-people",
  "tpope/vim-repeat",
  "tpope/vim-surround",

  config = function(plugin, opts)
    require("Olical/conjure").setup(opts)
    require("guns/vim-sexp").setup(opts)
    require("tpope/vim-sexp-mappings-for-regular-people").setup(opts)
    require("tpope/vim-repeat").setup(opts)
    require("tpope/vim-surround").setup(opts)
  end,
}
