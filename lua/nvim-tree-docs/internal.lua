local _0_0 = nil
do
  local name_0_ = "nvim-tree-docs.internal"
  local loaded_0_ = package.loaded[name_0_]
  local module_0_ = nil
  if ("table" == type(loaded_0_)) then
    module_0_ = loaded_0_
  else
    module_0_ = {}
  end
  module_0_["aniseed/module"] = name_0_
  module_0_["aniseed/locals"] = (module_0_["aniseed/locals"] or {})
  module_0_["aniseed/local-fns"] = (module_0_["aniseed/local-fns"] or {})
  package.loaded[name_0_] = module_0_
  _0_0 = module_0_
end
local function _2_(...)
  local ok_3f_0_, val_0_ = nil, nil
  local function _2_()
    return {require("nvim-tree-docs.collector"), require("aniseed.core"), require("nvim-tree-docs.template"), require("nvim-tree-docs.utils")}
  end
  ok_3f_0_, val_0_ = pcall(_2_)
  if ok_3f_0_ then
    _0_0["aniseed/local-fns"] = {require = {collectors = "nvim-tree-docs.collector", core = "aniseed.core", templates = "nvim-tree-docs.template", utils = "nvim-tree-docs.utils"}}
    return val_0_
  else
    return print(val_0_)
  end
end
local _1_ = _2_(...)
local collectors = _1_[1]
local core = _1_[2]
local templates = _1_[3]
local utils = _1_[4]
local _2amodule_2a = _0_0
local _2amodule_name_2a = "nvim-tree-docs.internal"
do local _ = ({nil, _0_0, {{}, nil, nil, nil}})[2] end
local configs = require("nvim-treesitter.configs")
local queries = require("nvim-treesitter.query")
local ts_utils = require("nvim-treesitter.ts_utils")
local language_specs = nil
do
  local v_0_ = {javascript = "jsdoc", lua = "lua", typescript = "jsdoc"}
  _0_0["aniseed/locals"]["language-specs"] = v_0_
  language_specs = v_0_
end
local doc_cache = nil
do
  local v_0_ = {}
  _0_0["aniseed/locals"]["doc-cache"] = v_0_
  doc_cache = v_0_
end
local get_spec_for_lang = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_spec_for_lang0(lang)
      local spec = language_specs[lang]
      if not spec then
        error(string.format("No language spec configured for %s", lang))
      end
      return spec
    end
    v_0_0 = get_spec_for_lang0
    _0_0["get-spec-for-lang"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-spec-for-lang"] = v_0_
  get_spec_for_lang = v_0_
end
local get_spec_for_buf = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_spec_for_buf0(bufnr_3f)
      local bufnr = (bufnr_3f or vim.api.nvim_get_current_buf())
      return get_spec_for_lang(vim.api.nvim_buf_get_option(bufnr, "ft"))
    end
    v_0_0 = get_spec_for_buf0
    _0_0["get-spec-for-buf"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-spec-for-buf"] = v_0_
  get_spec_for_buf = v_0_
end
local generate_docs = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function generate_docs0(data_list, bufnr_3f, lang_3f)
      local bufnr = utils["get-bufnr"](bufnr_3f)
      local lang = (lang_3f or vim.api.nvim_buf_get_option(bufnr, "ft"))
      local spec = templates["get-spec"](lang, get_spec_for_lang(lang))
      local edits = {}
      local marks = {}
      for _, doc_data in ipairs(data_list) do
        print(vim.inspect(doc_data))
        local node_sr, node_sc = utils["get-start-position"](doc_data)
        local node_er, node_ec = utils["get-end-position"](doc_data)
        local content_lines = utils["get-buf-content"](node_sr, node_sc, node_er, node_ec, bufnr)
        local context = nil
        local _4_
        do
          local _3_0 = spec
          if _3_0 then
            local _5_0 = _3_0.templates
            if _5_0 then
              _4_ = _5_0[doc_data.kind]
            else
              _4_ = _5_0
            end
          else
            _4_ = _3_0
          end
        end
        context = templates["execute-template"](doc_data, _4_, {["start-col"] = node_sc, ["start-line"] = node_sr, bufnr = bufnr, content = content_lines})
        local lines = templates["context-to-lines"](context, node_sc)
        table.insert(edits, {newText = table.concat(lines, "\n"), range = {["end"] = {character = node_ec, line = node_er}, start = {character = node_sc, line = node_sr}}})
        vim.list_extend(marks, context.marks)
      end
      return vim.lsp.util.apply_text_edits(edits, bufnr)
    end
    v_0_0 = generate_docs0
    _0_0["generate-docs"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["generate-docs"] = v_0_
  generate_docs = v_0_
end
local collect_docs = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function collect_docs0(bufnr_3f)
      local bufnr = utils["get-bufnr"](bufnr_3f)
      local _4_
      do
        local _3_0 = doc_cache
        if _3_0 then
          local _5_0 = _3_0[bufnr]
          if _5_0 then
            _4_ = _5_0.tick
          else
            _4_ = _5_0
          end
        else
          _4_ = _3_0
        end
      end
      if (_4_ == vim.api.nvim_buf_get_changedtick(bufnr)) then
        return doc_cache[bufnr].docs
      else
        local collector = collectors["new-collector"]()
        local doc_matches = queries.collect_group_results(bufnr, "docs")
        for _, item in ipairs(doc_matches) do
          for kind, _match in pairs(item) do
            collectors["add-match"](collector, kind, _match)
          end
        end
        doc_cache[bufnr] = {docs = collector, tick = vim.api.nvim_buf_get_changedtick(bufnr)}
        return collector
      end
    end
    v_0_0 = collect_docs0
    _0_0["collect-docs"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["collect-docs"] = v_0_
  collect_docs = v_0_
end
local get_doc_data_for_node = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_doc_data_for_node0(node, bufnr_3f)
      local current = nil
      local last_start = nil
      local last_end = nil
      local doc_data = collect_docs(bufnr_3f)
      local _, _0, node_start = node:start()
      for iter_item in collectors["iterate-collector"](doc_data) do
        local is_more_specific = true
        local _3_ = iter_item
        local doc_def = _3_["entry"]
        local _1, _2, start = utils["get-start-position"](doc_def)
        local _3, _4, _end = utils["get-end-position"](doc_def)
        local is_in_range = ((node_start >= start) and (node_start < _end))
        if (last_start and last_end) then
          is_more_specific = ((start >= last_start) and (_end <= last_end))
        end
        if (is_in_range and is_more_specific) then
          last_start = start
          last_end = _end
          current = doc_def
        end
      end
      return current
    end
    v_0_0 = get_doc_data_for_node0
    _0_0["get-doc-data-for-node"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-doc-data-for-node"] = v_0_
  get_doc_data_for_node = v_0_
end
local doc_node = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_node0(node, bufnr_3f, lang_3f)
      if node then
        local doc_data = get_doc_data_for_node(node, bufnr_3f)
        return generate_docs({doc_data}, bufnr_3f, lang_3f)
      end
    end
    v_0_0 = doc_node0
    _0_0["doc-node"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-node"] = v_0_
  doc_node = v_0_
end
local doc_node_at_cursor = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_node_at_cursor0()
      return doc_node(ts_utils.get_node_at_cursor())
    end
    v_0_0 = doc_node_at_cursor0
    _0_0["doc-node-at-cursor"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-node-at-cursor"] = v_0_
  doc_node_at_cursor = v_0_
end
local get_docs_in_range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_docs_in_range0(start_line, end_line, bufnr_3f)
      local doc_data = collect_docs(bufnr_3f)
      local result = {}
      for item in collectors["iterate-collector"](doc_data) do
        local _3_ = item
        local _def = _3_["entry"]
        local start_r = utils["get-start-position"](_def)
        local end_r = utils["get-end-position"](_def)
        if ((start_r >= start_line) and (end_r <= end_line)) then
          table.insert(result, _def)
        end
      end
      return result
    end
    v_0_0 = get_docs_in_range0
    _0_0["get-docs-in-range"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-docs-in-range"] = v_0_
  get_docs_in_range = v_0_
end
local get_docs_from_selection = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function get_docs_from_selection0()
      local _, start, _0, _1 = unpack(vim.fn.getpos("'<"))
      local _2, _end, _3, _4 = unpack(vim.fn.getpos("'>"))
      return get_docs_in_range((start - 1), (_end - 1))
    end
    v_0_0 = get_docs_from_selection0
    _0_0["get-docs-from-selection"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["get-docs-from-selection"] = v_0_
  get_docs_from_selection = v_0_
end
local doc_all_in_range = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function doc_all_in_range0()
      return generate_docs(get_docs_from_selection())
    end
    v_0_0 = doc_all_in_range0
    _0_0["doc-all-in-range"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc-all-in-range"] = v_0_
  doc_all_in_range = v_0_
end
local attach = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function attach0(bufnr_3f)
      local bufnr = utils["get-bufnr"](bufnr_3f)
      local config = configs.get_module("tree_docs")
      for _fn, mapping in pairs(config.keymaps) do
        local mode = "n"
        if (_fn == "doc_all_in_range") then
          mode = "v"
        end
        if mapping then
          vim.api.nvim_buf_set_keymap(bufnr, mode, mapping, string.format(":lua require 'nvim-tree-docs.internal'.%s()<CR>", _fn), {silent = true})
        end
      end
      return nil
    end
    v_0_0 = attach0
    _0_0["attach"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["attach"] = v_0_
  attach = v_0_
end
local detach = nil
do
  local v_0_ = nil
  do
    local v_0_0 = nil
    local function detach0(bufnr_3f)
      local bufnr = utils["get-bufnr"](bufnr_3f)
      local config = configs.get_module("tree_docs")
      for _fn, mapping in pairs(config.keymaps) do
        local mode = "n"
        if (_fn == "doc_all_in_range") then
          mode = "v"
        end
        if mapping then
          vim.api.nvim_buf_del_keymap(bufnr, mode, mapping)
        end
      end
      return nil
    end
    v_0_0 = detach0
    _0_0["detach"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["detach"] = v_0_
  detach = v_0_
end
local doc_node_at_cursor0 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = doc_node_at_cursor
    _0_0["doc_node_at_cursor"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc_node_at_cursor"] = v_0_
  doc_node_at_cursor0 = v_0_
end
local doc_node0 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = doc_node
    _0_0["doc_node"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc_node"] = v_0_
  doc_node0 = v_0_
end
local doc_all_in_range0 = nil
do
  local v_0_ = nil
  do
    local v_0_0 = doc_all_in_range
    _0_0["doc_all_in_range"] = v_0_0
    v_0_ = v_0_0
  end
  _0_0["aniseed/locals"]["doc_all_in_range"] = v_0_
  doc_all_in_range0 = v_0_
end
return nil