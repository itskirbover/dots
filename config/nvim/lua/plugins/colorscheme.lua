return {
  -- 1. Tell LazyVim to use catppuccin as the default
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- 2. Configure Catppuccin and force it to load properly
  {
    "catppuccin/nvim",
    lazy = false, -- Ensure it loads on startup
    priority = 1000, -- Load this before all other plugins
    name = "catppuccin",
    opts = {
      transparent_background = true,
      flavour = "mocha", -- or latte, frappe, macchiato
      integrations = {
        telescope = true,
        neotree = true,
        notify = true,
        mini = true,
      },
      custom_highlights = function(colors)
        return {
          -- Make the cursor line background transparent
          CursorLine = { bg = "none" },
          -- Optional: make floating windows transparent too
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
        }
      end,
    },
    -- This 'config' block ensures the theme is applied with your opts immediately
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
