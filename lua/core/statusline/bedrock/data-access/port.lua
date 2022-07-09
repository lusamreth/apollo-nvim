local DATA_PROVIDER = {}
DATA_PROVIDER['vcs'] = interface.build_interface({
    { 'get_workspace', { '->', 'string' } },
    { 'get_branch', { '->', 'string' } },
    { 'get_commit', { '->', 'string' } },
})

DATA_PROVIDER['file'] = interface.build_interface({
    { 'get_filename', { '->', 'string' } },
    { 'get_filesize', { '->', 'string' } },
    --{"get_fileos", t = {""}}
})

DATA_PROVIDER['nvim'] = interface.build_interface({
    {
        'get_line_position',
        {
            '->',
            'string',
        },
    },
    {
        'get_page_position',
        {
            '->',
            'string',
        },
    },
    { 'get_line_diagnostics', { '->', 'int' } },
    {
        'getmode',
        { '->', 'string' },
    },
})

-- fix this shit please
-- does not work
return DATA_PROVIDER
