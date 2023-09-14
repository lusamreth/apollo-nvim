local api = require('nvim-tree.api')

local _nv_set = function(...)
    vim.keymap.set('n', ...)
end

local function default_nvtree_keybinds(bufnr)
    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    -- BEGIN_DEFAULT_ON_ATTACH
    _nv_set('<C-]>', api.tree.change_root_to_node, opts('CD'))
    _nv_set('<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
    _nv_set('<C-k>', api.node.show_info_popup, opts('Info'))
    _nv_set('<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
    _nv_set('<C-t>', api.node.open.tab, opts('Open: New Tab'))
    _nv_set('<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    _nv_set('<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    _nv_set('<BS>', api.node.navigate.parent_close, opts('Close Directory'))
    _nv_set('<CR>', api.node.open.edit, opts('Open'))
    _nv_set('<Tab>', api.node.open.preview, opts('Open Preview'))
    _nv_set('>', api.node.navigate.sibling.next, opts('Next Sibling'))
    _nv_set('<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
    _nv_set('.', api.node.run.cmd, opts('Run Command'))
    _nv_set('-', api.tree.change_root_to_parent, opts('Up'))
    _nv_set('a', api.fs.create, opts('Create'))
    _nv_set('bd', api.marks.bulk.delete, opts('Delete Bookmarked'))
    _nv_set('bmv', api.marks.bulk.move, opts('Move Bookmarked'))
    _nv_set('B', api.tree.toggle_no_buffer_filter, opts('Toggle Filter: No Buffer'))
    _nv_set('c', api.fs.copy.node, opts('Copy'))
    _nv_set('C', api.tree.toggle_git_clean_filter, opts('Toggle Filter: Git Clean'))
    _nv_set('[c', api.node.navigate.git.prev, opts('Prev Git'))
    _nv_set(']c', api.node.navigate.git.next, opts('Next Git'))
    _nv_set('d', api.fs.remove, opts('Delete'))
    _nv_set('D', api.fs.trash, opts('Trash'))
    _nv_set('E', api.tree.expand_all, opts('Expand All'))
    _nv_set('e', api.fs.rename_basename, opts('Rename: Basename'))
    _nv_set(']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
    _nv_set('[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
    _nv_set('F', api.live_filter.clear, opts('Clean Filter'))
    _nv_set('f', api.live_filter.start, opts('Filter'))
    _nv_set('g?', api.tree.toggle_help, opts('Help'))
    _nv_set('gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
    _nv_set('H', api.tree.toggle_hidden_filter, opts('Toggle Filter: Dotfiles'))
    _nv_set('I', api.tree.toggle_gitignore_filter, opts('Toggle Filter: Git Ignore'))
    _nv_set('J', api.node.navigate.sibling.last, opts('Last Sibling'))
    _nv_set('K', api.node.navigate.sibling.first, opts('First Sibling'))
    _nv_set('m', api.marks.toggle, opts('Toggle Bookmark'))
    _nv_set('o', api.node.open.edit, opts('Open'))
    _nv_set('O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
    _nv_set('p', api.fs.paste, opts('Paste'))
    _nv_set('P', api.node.navigate.parent, opts('Parent Directory'))
    _nv_set('q', api.tree.close, opts('Close'))
    _nv_set('r', api.fs.rename, opts('Rename'))
    _nv_set('R', api.tree.reload, opts('Refresh'))
    _nv_set('s', api.node.run.system, opts('Run System'))
    _nv_set('S', api.tree.search_node, opts('Search'))
    _nv_set('U', api.tree.toggle_custom_filter, opts('Toggle Filter: Hidden'))
    _nv_set('W', api.tree.collapse_all, opts('Collapse'))
    _nv_set('x', api.fs.cut, opts('Cut'))
    _nv_set('y', api.fs.copy.filename, opts('Copy Name'))
    _nv_set('Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
    _nv_set('<2-LeftMouse>', api.node.open.edit, opts('Open'))
    _nv_set('<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
end
-- END_DEFAULT_ON_ATTACH
--
return {
    default_nvtree_keybinds = default_nvtree_keybinds,
}
