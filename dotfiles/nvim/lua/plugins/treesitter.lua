return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"query",
			"elixir",
			"heex",
			"eex",
			"javascript",
			"html",
			"ruby",
			"go",
		},
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },
	},
}
