local M = {}
local projects = {}
local buffers = {}
local stopping = false
local helper = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h:h')
    .. '/scripts/tex-viewer.py'

local function canonical(path)
    path = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
    return vim.uv.fs_realpath(path) or path
end

local function release(buf)
    local pdf = buffers[buf]
    buffers[buf] = nil
    local project = pdf and projects[pdf]
    if not project then return end
    project.buffers[buf] = nil
    if next(project.buffers) then return end
    projects[pdf] = nil
    if project.job then
        -- EOF releases this editor's lease; another editor may still need the PDF.
        pcall(vim.fn.chanclose, project.job, 'stdin')
    end
end

local function open(project)
    if project.job or project.dismissed or vim.fn.filereadable(project.pdf) == 0 then return end
    local errors = {}
    local job
    job = vim.fn.jobstart({ '/usr/bin/python3', helper, project.pdf, vim.v.servername,
        vim.v.progpath, tostring(vim.fn.getpid()) }, {
        stdout_buffered = false,
        on_stdout = function(_, lines)
            for _, line in ipairs(lines) do
                if line:sub(1, 8) == 'WARNING:' then
                    vim.notify(line:sub(9), vim.log.levels.WARN, { title = 'TeX viewer' })
                end
            end
        end,
        stderr_buffered = true,
        on_stderr = function(_, lines) errors = lines end,
        on_exit = function(_, code)
            if project.job == job then
                project.job = nil
                project.dismissed = true
            end
            if code ~= 0 and not stopping and projects[project.pdf] == project then
                vim.notify(table.concat(errors, '\n'), vim.log.levels.ERROR, { title = 'TeX viewer' })
            end
        end,
    })
    if job > 0 then
        project.job = job
    else
        project.dismissed = true
        vim.notify('Could not start ' .. helper, vim.log.levels.ERROR)
    end
end

local function attach(buf, reopen)
    if stopping or not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf)
        or not vim.bo[buf].buflisted then return end
    if vim.bo[buf].filetype ~= 'tex' or not vim.b[buf].vimtex then
        release(buf)
        return
    end
    local pdf, main
    vim.api.nvim_buf_call(buf, function()
        pdf = vim.fn.eval('b:vimtex.compiler.get_file("pdf")')
        main = vim.b.vimtex.tex
    end)
    if not pdf or pdf == '' then
        -- VimTeX only returns output files that already exist. Bootstrap the
        -- first PDF, then attach its viewer on VimtexEventCompileSuccess.
        if vim.fn.filereadable(main) == 1 then
            vim.api.nvim_buf_call(buf, function()
                local running = vim.fn.eval('b:vimtex.compiler.is_running()')
                if not running or running == 0 then vim.cmd.VimtexCompile() end
            end)
        end
        return
    end
    pdf = canonical(pdf)
    if buffers[buf] ~= pdf then release(buf) end
    local project = projects[pdf]
    if not project then
        project = { pdf = pdf, buffers = {} }
        projects[pdf] = project
    end
    buffers[buf] = pdf
    project.buffers[buf] = true
    if reopen then project.dismissed = false end
    open(project)

    -- Start once per project, after its main file exists. New files start on save.
    if not project.compiling and vim.fn.filereadable(main) == 1 then
        project.compiling = true
        vim.api.nvim_buf_call(buf, function()
            local running = vim.fn.eval('b:vimtex.compiler.is_running()')
            if not running or running == 0 then
                vim.cmd.VimtexCompile()
            end
        end)
    end
    return project
end

function M.view()
    local project = attach(vim.api.nvim_get_current_buf(), true)
    if not project or not project.job then return end
    vim.fn.chansend(project.job, vim.json.encode({
        file = vim.api.nvim_buf_get_name(0),
        line = vim.fn.line('.'),
        column = vim.fn.col('.'),
    }) .. '\n')
end

function M.setup()
    local group = vim.api.nvim_create_augroup('TexViewer', { clear = true })
    vim.api.nvim_create_autocmd('User', {
        group = group,
        pattern = { 'VimtexEventInitPost', 'VimtexEventCompileSuccess' },
        callback = function()
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function() attach(buf, false) end)
        end,
    })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'FileType' }, {
        group = group,
        callback = function(event)
            vim.schedule(function() attach(event.buf, event.event == 'BufEnter') end)
        end,
    })
    vim.api.nvim_create_autocmd({ 'BufUnload', 'BufDelete', 'BufWipeout' }, {
        group = group,
        callback = function(event) release(event.buf) end,
    })
    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = group,
        callback = function()
            stopping = true
            local jobs = {}
            for _, project in pairs(projects) do
                if project.job then
                    table.insert(jobs, project.job)
                    pcall(vim.fn.chanclose, project.job, 'stdin')
                end
            end
            -- Give helpers time to release their leases before Neovim kills jobs.
            if #jobs > 0 then vim.fn.jobwait(jobs, 2000) end
        end,
    })
end

return M
