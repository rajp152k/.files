local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'MeanderingProgrammer/render-markdown.nvim',
  gh 'ice345/markdown-table-wrap.nvim',
  gh 'tadmccorkle/markdown.nvim',
  gh '3rd/image.nvim',
  gh '3rd/diagram.nvim',
}

require('render-markdown').setup {
  completions = { lsp = { enabled = true } },
  sign = { enabled = false },
  heading = {
    sign = false,
    icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
    position = 'inline',
  },
  code = {
    sign = false,
    language_icon = false,
  },
  pipe_table = {
    enabled = false,
  },
  checkbox = {
    unchecked = { icon = '[ ] ' },
    checked = { icon = '[x] ' },
    custom = {
      todo = { raw = '[-]', rendered = '[-] ' },
    },
  },
}

require('markdown-table-wrap').setup {
  preview_mode = 'reader',
  auto_preview = true,
  render_all = true,
  max_width_ratio = 0.95,
  min_col_width = 8,
  max_col_width = 40,
  reader = {
    auto_open = 'has_table',
    wrap = true,
    linebreak = true,
    breakindent = true,
  },
}

require('image').setup {
  backend = 'kitty',
  processor = 'magick_cli',
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = true,
      download_remote_images = false,
      only_render_image_at_cursor = true,
      only_render_image_at_cursor_mode = 'popup',
      floating_windows = false,
      filetypes = { 'markdown' },
    },
  },
}

local function zoom_image(factor)
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  local is_markdown = vim.bo[current_buf].filetype == 'markdown'

  for _, image in ipairs(require('image').get_images()) do
    local win = image.window
    if win and vim.api.nvim_win_is_valid(win) then
      local is_popup = vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'image_nvim_popup'
      if (is_markdown and is_popup) or (not is_markdown and image.window == current_win and image.buffer == current_buf) then
        local width = image.geometry.width or image.rendered_geometry.width
        local height = image.geometry.height or image.rendered_geometry.height
        if not width or not height or width == 0 then break end

        local max_width = is_popup and vim.o.columns - 4 or vim.api.nvim_win_get_width(win)
        local max_height = is_popup and vim.o.lines - 4 or vim.api.nvim_win_get_height(win)
        local target_width = math.max(1, math.floor(width * factor + 0.5))
        local target_height = math.max(1, math.floor(height * factor + 0.5))
        local fit = math.min(1, max_width / target_width, max_height / target_height)
        target_width = math.max(1, math.floor(target_width * fit))
        target_height = math.max(1, math.floor(target_height * fit))

        if is_popup then
          local config = vim.api.nvim_win_get_config(win)
          config.width, config.height = target_width, target_height
          vim.api.nvim_win_set_config(win, config)
        end
        image.ignore_global_max_size = true
        image:render { width = target_width, height = target_height }
        return
      end
    end
  end
  vim.notify('No visible image to zoom', vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'image_nvim',
  callback = function(event)
    vim.keymap.set('n', '<leader>m+', function() zoom_image(1.25) end, { buffer = event.buf, desc = '[M]arkdown image zoom in' })
    vim.keymap.set('n', '<leader>m-', function() zoom_image(0.8) end, { buffer = event.buf, desc = '[M]arkdown image zoom out' })
  end,
})

require('diagram').setup {
  integrations = {
    require 'diagram.integrations.markdown',
  },
  events = {
    render_buffer = {},
    clear_buffer = { 'BufLeave' },
  },
  renderer_options = {
    mermaid = {
      theme = 'dark',
      scale = 2,
    },
  },
}

-- Heading-based folding with fenced code-block folds.
_G.MarkdownHeadingFold = function(lnum)
  local line = vim.fn.getline(lnum)

  -- Toggle code fences open/close.
  if line:match '^%s*```+%s*.*' or line:match '^%s*~~~+%s*.*' then
    local fence_count_before = 0
    for i = 1, lnum - 1 do
      local prev = vim.fn.getline(i)
      if prev:match '^%s*```+%s*.*' or prev:match '^%s*~~~+%s*.*' then
        fence_count_before = fence_count_before + 1
      end
    end
    return fence_count_before % 2 == 0 and 'a1' or 's1'
  end

  -- Heading-based folds: # => 1, ## => 2, etc.
  local heading = line:match '^(#+)%s+'
  if heading and #heading <= 6 then
    return '>' .. #heading
  end
  return '='
end

require('markdown').setup {
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

    map('n', '<leader>mt', '<Cmd>MarkdownTableToggleReader<CR>', '[M]arkdown table reader [T]oggle')
    map('n', '<leader>mp', '<Cmd>MarkdownTablePreview<CR>', '[M]arkdown table [P]review')
    map('n', '<leader>m+', function() zoom_image(1.25) end, '[M]arkdown image zoom in')
    map('n', '<leader>m-', function() zoom_image(0.8) end, '[M]arkdown image zoom out')
    map('n', '<leader>md', function() require('diagram').show_diagram_hover() end, '[M]arkdown [D]iagram preview')
    map('n', '<leader>mx', '<Cmd>MDTaskToggle<CR>', '[M]arkdown task toggle')
    map('x', '<leader>mx', ':MDTaskToggle<CR>', '[M]arkdown task toggle')
    map('n', '<leader>mo', '<Cmd>MDListItemBelow<CR>', '[M]arkdown list item bel[O]w')
    map('n', '<leader>mO', '<Cmd>MDListItemAbove<CR>', '[M]arkdown list item ab[O]ve')
  end,
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.colorcolumn = ''
    -- Builtin matchparen can visibly block on `)` in large markdown files while
    -- scanning links/prose. Markdown does not need structural paren matching.
    vim.opt_local.matchpairs = ''

    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr = 'v:lua.MarkdownHeadingFold(v:lnum)'
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldenable = true
  end,
})

local ok, which_key = pcall(require, 'which-key')
if ok then which_key.add { { '<leader>m', group = '[M]arkdown' } } end

-- vim: ts=2 sts=2 sw=2 et
