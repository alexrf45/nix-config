local vault = vim.fn.expand("~/notes")

local M = {}

local function uuid() return os.date("%Y%m%d%H%M") end
local function rfc3339() return os.date("%Y-%m-%dT%H:%M:%SZ") end

local function read_template(name)
  local path = vault .. "/templates/" .. name
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a"); f:close(); return s
end

local function fill_template(content, title)
  local id = uuid()
  return (content
    :gsub("{{title}}", title)
    :gsub("{{uuid}}", id)
    :gsub("{{rfc3339}}", rfc3339())), id
end

local function write_and_open(path, content)
  local f = io.open(path, "w")
  if not f then
    vim.notify("Cannot create: " .. path, vim.log.levels.ERROR); return
  end
  f:write(content); f:close()
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function open_or_create(filename, template_name, title)
  local path = vault .. "/" .. filename
  if vim.fn.filereadable(path) == 0 then
    local tmpl = read_template(template_name) or "# " .. title .. "\n\n"
    local content = fill_template(tmpl, title)
    write_and_open(path, content)
  else
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

local function from_template(template_name, prompt_text)
  local title = vim.fn.input(prompt_text)
  if title == "" then return end
  local tmpl = read_template(template_name) or "# {{title}}\n\n"
  local content, id = fill_template(tmpl, title)
  write_and_open(vault .. "/" .. id .. ".md", content)
end

-- ── pickers ──────────────────────────────────────────────────────────────────

function M.find_notes()
  require("fzf-lua").files({ cwd = vault, prompt = "Notes> " })
end

function M.search_notes()
  require("fzf-lua").live_grep({ cwd = vault, prompt = "Search> " })
end

function M.goto_today()
  open_or_create(os.date("%Y-%m-%d") .. ".md", "daily.md", os.date("%Y-%m-%d"))
end

function M.goto_thisweek()
  local week = os.date("%Y-W%V")
  open_or_create(week .. ".md", "weekly.md", week)
end

function M.follow_link()
  local line = vim.api.nvim_get_current_line()
  local col  = vim.api.nvim_win_get_cursor(0)[2] + 1
  local link, pos = nil, 1
  while true do
    local s, e, target = line:find("%[%[(.-)%]%]", pos)
    if not s then break end
    if col >= s and col <= e then link = target; break end
    pos = e + 1
  end
  if not link then
    vim.notify("No [[wiki link]] under cursor", vim.log.levels.WARN); return
  end

  local matches = vim.fn.globpath(vault, "**/*" .. vim.fn.escape(link, "[]()") .. "*.md", false, true)
  if #matches == 0 then
    local tmpl = read_template("note.md") or "# {{title}}\n\n"
    local content, id = fill_template(tmpl, link)
    write_and_open(vault .. "/" .. id .. ".md", content)
  elseif #matches == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
  else
    require("fzf-lua").fzf_exec(matches, {
      prompt = "Follow link> ",
      actions = {
        ["default"] = function(selected)
          if selected and selected[1] then
            vim.cmd("edit " .. vim.fn.fnameescape(selected[1]))
          end
        end,
      },
    })
  end
end

function M.new_note()  from_template("note.md", "Note title: ") end
function M.new_poem()  from_template("poem.md", "Poem title: ") end

function M.show_backlinks()
  local name = vim.fn.expand("%:t:r")
  if name == "" then vim.notify("No file open", vim.log.levels.WARN); return end
  require("fzf-lua").grep({
    cwd    = vault,
    search = "\\[\\[" .. name,
    no_esc = true,
    prompt = "Backlinks> ",
  })
end

function M.insert_link()
  require("fzf-lua").files({
    cwd    = vault,
    prompt = "Insert link> ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then return end
        local name = vim.fn.fnamemodify(selected[1], ":t:r")
        local link = "[[" .. name .. "]]"
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { link })
        vim.api.nvim_win_set_cursor(0, { row, col + #link })
      end,
    },
  })
end

function M.insert_img_link()
  require("fzf-lua").files({
    cwd    = vault .. "/media/images",
    prompt = "Insert image> ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then return end
        local name = vim.fn.fnamemodify(selected[1], ":t")
        local link = "![" .. name .. "](media/images/" .. name .. ")"
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { link })
        vim.api.nvim_win_set_cursor(0, { row, col + #link })
      end,
    },
  })
end

function M.show_tags()
  local tag_files = {}

  -- Pass 1: inline  tags: [tag1, tag2]
  local inline = vim.fn.systemlist(
    "rg --with-filename -o 'tags: \\[[^\\]]+\\]' "
    .. vim.fn.shellescape(vault)
    .. " --glob='*.md' --glob='!templates/*.md' 2>/dev/null"
  )
  for _, line in ipairs(inline) do
    local path, inner = line:match("^(.-):tags: %[(.-)%]$")
    if inner then
      for tag in inner:gmatch("[^,]+") do
        tag = tag:match("^%s*(.-)%s*$")
        if tag ~= "" then
          tag_files[tag] = tag_files[tag] or {}
          tag_files[tag][path] = true
        end
      end
    end
  end

  -- Pass 2: multi-line list items in frontmatter (line ≤ 15)
  local multiline = vim.fn.systemlist(
    "rg --vimgrep '^\\s+- [a-zA-Z0-9_/-]+$' "
    .. vim.fn.shellescape(vault)
    .. " --glob='*.md' --glob='!templates/*.md' 2>/dev/null"
  )
  for _, line in ipairs(multiline) do
    local path, lnum, tag = line:match("^(.-):(%d+):%d+:%s+%-%s+(.-)%s*$")
    if path and tag ~= "" and tonumber(lnum) <= 15 then
      tag_files[tag] = tag_files[tag] or {}
      tag_files[tag][path] = true
    end
  end

  local entries, tag_map = {}, {}
  for tag, paths in pairs(tag_files) do
    local files = vim.tbl_keys(paths)
    local label = string.format("%-32s (%d notes)", tag, #files)
    entries[#entries + 1] = label
    tag_map[label] = files
  end
  table.sort(entries)

  if #entries == 0 then
    vim.notify("No tags found in vault", vim.log.levels.WARN); return
  end

  require("fzf-lua").fzf_exec(entries, {
    prompt = "Tags> ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then return end
        local files = tag_map[selected[1]]
        if not files then return end
        if #files == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
        else
          require("fzf-lua").fzf_exec(files, {
            prompt = "Tagged notes> ",
            actions = {
              ["default"] = function(sel)
                if sel and sel[1] then vim.cmd("edit " .. vim.fn.fnameescape(sel[1])) end
              end,
            },
          })
        end
      end,
    },
  })
end

function M.panel()
  local cmds = {
    { "Find notes",   M.find_notes },
    { "Search notes", M.search_notes },
    { "Today's note", M.goto_today },
    { "Weekly note",  M.goto_thisweek },
    { "New note",     M.new_note },
    { "New poem",     M.new_poem },
    { "Follow link",  M.follow_link },
    { "Show tags",    M.show_tags },
    { "Backlinks",    M.show_backlinks },
    { "Insert link",  M.insert_link },
    { "Insert image", M.insert_img_link },
  }
  local labels = vim.tbl_map(function(c) return c[1] end, cmds)
  require("fzf-lua").fzf_exec(labels, {
    prompt = "Zettelkasten> ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then return end
        for _, c in ipairs(cmds) do
          if c[1] == selected[1] then c[2](); return end
        end
      end,
    },
  })
end

-- ── plugin spec ──────────────────────────────────────────────────────────────

return {
  {
    "ibhagwan/fzf-lua",
    optional = true,
    keys = {
      { "<leader>z",  function() M.panel() end,           desc = "Zettelkasten panel" },
      { "<leader>zf", function() M.find_notes() end,      desc = "Find notes" },
      { "<leader>zs", function() M.search_notes() end,    desc = "Search notes" },
      { "<leader>zd", function() M.goto_today() end,      desc = "Today's note" },
      { "<leader>zw", function() M.goto_thisweek() end,   desc = "Weekly note" },
      { "<leader>zz", function() M.follow_link() end,     desc = "Follow [[link]]" },
      { "<leader>zn", function() M.new_note() end,        desc = "New note" },
      { "<leader>za", function() M.new_note() end,        desc = "New templated note" },
      { "<leader>zp", function() M.new_poem() end,        desc = "New poem" },
      { "<leader>zb", function() M.show_backlinks() end,  desc = "Backlinks" },
      { "<leader>zt", function() M.show_tags() end,       desc = "Tag browser" },
      { "<leader>zI", function() M.insert_img_link() end, desc = "Insert image link" },
      { "<leader>zl", function() M.insert_link() end,     desc = "Insert [[link]]" },
    },
  },
}
