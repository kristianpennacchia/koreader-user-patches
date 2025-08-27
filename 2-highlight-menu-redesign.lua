local ReaderHighlight = require("apps/reader/modules/readerhighlight")
local ButtonDialog = require("ui/widget/buttondialog")
local UIManager = require("ui/uimanager")
local ffiUtil = require("ffi/util")
local _ = require("gettext")

function ReaderHighlight:onShowHighlightMenu(index)
	local selectButton = nil
	local highlightButton = nil
	local searchButton = nil
	local wikipediaButton = nil
	local wordReferenceButton = nil
	local dictionaryButton = nil
	local translateButton = nil
	local unknownButtons = {}

	for key, fn_button in ffiUtil.orderedPairs(self._highlight_buttons) do
		local button = fn_button(self, index)
		if not button.show_in_highlight_dialog_func or button.show_in_highlight_dialog_func() then
			if key:find("_select") then
				button.text = nil
				button.text_func = nil
				button.icon = index and "button.select-extend" or "button.select"
				selectButton = button
			elseif key:find("_highlight") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.highlight"
				highlightButton = button
			elseif key:find("_wikipedia") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.wikipedia"
				wikipediaButton = button
			elseif key:find("_dictionary") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.dictionary"
				dictionaryButton = button
			elseif key:find("_translate") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.translate"
				translateButton = button
			elseif key:find("_wordreference") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.wordreference"
				wordReferenceButton = button
			elseif key:find("_search") then
				button.text = nil
				button.text_func = nil
				button.icon = "button.search"
				searchButton = button
			else
				table.insert(unknownButtons, button)
			end
		end
	end

	local highlight_buttons = {{}}

	-- Add custom rows.
	highlight_buttons[1] = {
		selectButton,
		highlightButton,
		wikipediaButton,
		wordReferenceButton,
		dictionaryButton,
		translateButton,
		searchButton,
	}

	-- Split unknownButtons into smaller rows.
	local maxRowLength = 2
	if #unknownButtons > 0 then
		for i = 1, #unknownButtons, maxRowLength do
			local row = {}
			for j = i, math.min(i + maxRowLength - 1, #unknownButtons) do
				row[#row + 1] = unknownButtons[j]
			end
			highlight_buttons[#highlight_buttons + 1] = row
		end
	end

	self.highlight_dialog = ButtonDialog:new{
		buttons = highlight_buttons,
		anchor = function()
			return self:_getDialogAnchor(self.highlight_dialog, index)
		end,
		tap_close_callback = function()
			if self.hold_pos then
				self:clear()
			end
		end,
	}

	-- NOTE: Disable merging for this update,
	--       or the buggy Sage kernel may alpha-blend it into the page (with a bogus alpha value, to boot)...
	UIManager:show(self.highlight_dialog, "[ui]")
end
