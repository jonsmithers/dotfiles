local M = {}

M.FILE_PICKERS = {
  snacks = 'snacks',
  mini = 'mini',
}
M.FILE_PICKER = M.FILE_PICKERS.snacks

M.GIT_STATUSES = {
  fugitive = 'fugitive',
  diffview = 'diffview',
}
M.GIT_STATUS = M.GIT_STATUSES.diffview

return M
