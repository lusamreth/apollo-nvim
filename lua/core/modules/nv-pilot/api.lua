local job = require('plenary.job')

Api = {
    OPENAI_API_KEY = 'pk-INJhHJmyfChkKKFxpustWlkUyYPfJDPoFztopNvzLCgvSbCw',
}
local curl = require('plenary.curl')
function Api.make_call(url, params, cb)
    local function curl_post(url)
        local gpt_payload = {
            model = 'gpt-3.5-turbo',
            max_tokens = 300,
            messages = {
                {
                    role = 'system',
                    content = 'a very helpful assistant',
                },
                {
                    role = 'user',
                    content = 'hellohashhaksda',
                },
            },
        }
        local jsonified = vim.fn.json_encode(gpt_payload)

        TMP_MSG_FILENAME = os.tmpname()
        local f = io.open(TMP_MSG_FILENAME, 'w+')
        if f == nil then
            -- vim.notify("Cannot open temporary message file: " .. TMP_MSG_FILENAME, vim.log.levels.ERROR)
            print('Cannot open temporary message file: ' .. TMP_MSG_FILENAME, vim.log.levels.ERROR)
            return
        end

        f:write(jsonified)
        -- f:write(vim.fn.json_encode(params))
        f:close()
        -- local done = false
        local done = true
        local raw_body = nil
        local res = curl.post(url, {
            headers = {
                content_type = 'application/json',
                authorization = 'Bearer ' .. Api.OPENAI_API_KEY,
            },
            body = TMP_MSG_FILENAME,
            -- callback = function(response)
            --     local res = response.body
            --     done = true
            --     raw_body = res

            --     -- Api.handle_response(response or vim.fn.json_encode({}), 0, cb)
            -- end,
        })
        if done then
            local res = vim.fn.json_decode(res.body)
            -- local res = res.body
            -- print('RESS')
            -- vim.pretty_print(res)
            -- vim.pretty_print(res.choices)
            if res.choices then
                print('found choices', res.choices)
                for i, res_content in pairs(res.choices) do
                    cb(res_content.message.content)
                    -- cb(res_content.message.role)
                end
            end
        end
        vim.pretty_print(res)
        vim.pretty_print(jsonified)
        return res.body
    end
    return curl_post(url)
end

function Api.make_call_z(url, params, cb)
    TMP_MSG_FILENAME = os.tmpname()
    local f = io.open(TMP_MSG_FILENAME, 'w+')

    if f == nil then
        -- vim.notify("Cannot open temporary message file: " .. TMP_MSG_FILENAME, vim.log.levels.ERROR)
        print('Cannot open temporary message file: ' .. TMP_MSG_FILENAME, vim.log.levels.ERROR)
        return
    end

    local gpt_template = {
        model = 'gpt-3.5-turbo',
        max_tokens = 3000,
        messages = { {
            role = 'user',
            content = 'params.message',
        } },
    }
    -- f:write(vim.fn.json_encode(params))
    jsonified = vim.fn.json_encode(gpt_template)
    f:write(jsonified)
    -- f:write(vim.fn.json_encode(params))
    f:close()
    Api.job = job:new({
        command = 'curl',
        args = {
            args = {
                '--location',
                url,
                '-H',
                'Content-Type: application/json',
                '-H',
                'Authorization: Bearer ' .. Api.OPENAI_API_KEY,
                '-d',
                '@' .. TMP_MSG_FILENAME,
            },
            -- "{\
            --     'model': 'gpt-3.5-turbo',\
            --     'max_tokens': 3000,\
            --     'messages':[{\
            --         'role': 'system',\
            --         'content': 'You are an helpful assistant.'\
            --     },\
            --     {\
            --         'role': 'user',\
            --         'content': 'hello.'\
            --     }\
            --     ]\
            -- }",
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            print('LOGGGING APIII', response)
            vim.pretty_print(response)
            Api.handle_response(response or vim.fn.json_encode({}), exit_code, cb)
        end),
    }):start()
end

Api.handle_response = vim.schedule_wrap(function(response, exit_code, cb)
    os.remove(TMP_MSG_FILENAME)
    if exit_code ~= 0 then
        vim.notify('An Error Occurred ...', vim.log.levels.ERROR)
        cb('ERROR: API Error')
    end

    local result = table.concat(response:result(), '\n')
    local json = vim.fn.json_decode(result)
    if json == nil then
        cb('No Response.')
    elseif json.error then
        cb('// API ERROR: ' .. json.error.message)
    else
        local message = json.choices[1].message
        if message ~= nil then
            local response_text = json.choices[1].message.content
            if type(response_text) == 'string' and response_text ~= '' then
                cb(response_text, json.usage)
            else
                cb('...')
            end
        else
            local response_text = json.choices[1].text
            if type(response_text) == 'string' and response_text ~= '' then
                cb(response_text, json.usage)
            else
                cb('...')
            end
        end
    end
end)

return Api
