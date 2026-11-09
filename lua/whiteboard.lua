local M = {}

local state = { job = nil, profile = nil }

local opts = {
  browser = nil, -- e.g. "chromium"; auto-detected when nil
  url = "https://excalidraw.com",
  window_size = "1280,800", -- chromium-based browsers only
}

local CANDIDATES = {
  "chromium", "google-chrome-stable", "google-chrome",
  "brave", "brave-browser", "firefox",
}

local function find_browser()
  if opts.browser then
    return opts.browser
  end
  for _, b in ipairs(CANDIDATES) do
    if vim.fn.executable(b) == 1 then
      return b
    end
  end
end

local function build_cmd(browser, profile)
  if vim.fn.fnamemodify(browser, ":t"):find("firefox") then
    return { browser, "--new-instance", "--profile", profile, opts.url }
  end
  return {
    browser,
    "--user-data-dir=" .. profile,
    "--app=" .. opts.url,
    "--window-size=" .. opts.window_size,
    "--class=nvim-whiteboard", -- handy for window-manager rules
    "--no-first-run",
    "--no-default-browser-check",
  }
end

function M.open()
  if state.job then
    vim.notify("whiteboard is already open", vim.log.levels.INFO)
    return
  end

  local browser = find_browser()
  if not browser then
    vim.notify("whiteboard: no supported browser found; set opts.browser", vim.log.levels.ERROR)
    return
  end

  -- One profile per Neovim session, reused across opens so the drawing survives
  -- closing the window, and wiped on exit.
  if not state.profile then
    state.profile = vim.fn.tempname()
    vim.fn.mkdir(state.profile, "p")
  end

  local job = vim.fn.jobstart(build_cmd(browser, state.profile), {
    on_exit = function()
      state.job = nil
    end,
  })
  if job <= 0 then
    vim.notify("whiteboard: failed to launch " .. browser, vim.log.levels.ERROR)
    return
  end
  state.job = job
end

function M.close()
  if state.job then
    vim.fn.jobstop(state.job)
  end
end

local function cleanup()
  local job = state.job
  if job then
    vim.fn.jobstop(job)
    vim.fn.jobwait({ job }, 1500) -- let the browser release the profile
  end
  if state.profile then
    vim.fn.delete(state.profile, "rf")
    state.profile = nil
  end
end

function M.setup(user_opts)
  opts = vim.tbl_extend("force", opts, user_opts or {})

  vim.api.nvim_create_user_command("Whiteboard", M.open, { desc = "Open the session whiteboard (Excalidraw)" })
  vim.api.nvim_create_user_command("WhiteboardClose", M.close, { desc = "Close the whiteboard window" })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("WhiteboardCleanup", { clear = true }),
    callback = cleanup,
  })
end

return M
