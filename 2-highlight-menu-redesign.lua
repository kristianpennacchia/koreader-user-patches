local ReaderHighlight = require("apps/reader/modules/readerhighlight")
local _ = require("gettext")
local C_ = _.pgettext
local UIManager = require("ui/uimanager")
local util = require("util")
local Event = require("ui/event")
local Notification = require("ui/widget/notification")
local logger = require("logger")
local Device = require("device")

local WidgetContainer = require("ui/widget/container/widgetcontainer")

-- Store the original function to call it later if needed
local orig_init = ReaderHighlight.init

function ReaderHighlight:init()
    orig_init(self)

    local WordReference = require("wordreference")
    WordReference.show_highlight_dialog_button = false

    --- rearrange these as you like
	-- "item" structure like explained in "01_select"

    self._highlight_buttons = {
        ["01_select"] = function(this, index)
            return {
                icon = index and _("button.select-extend") or _("button.select"),
                enabled = not (index and this.ui.annotation.annotations[index].text_edited),
                callback = function()
                    this:startSelection(index)
                    this:onClose()
                    if not Device:isTouchDevice() then
                        self:onStartHighlightIndicator()
                    end
                end,
            }
        end,
        ["02_highlight"] = function(this)
            return {
                icon = _("button.highlight"),
                enabled = this.hold_pos ~= nil,
                callback = function()
                    this:saveHighlight(true)
                    this:onClose()
                end,
            }
        end,
        ["03_wikipedia"] = function(this)
            return {
                icon = _("button.wikipedia"),
                callback = function()
                    UIManager:scheduleIn(0.1, function()
                        this:lookupWikipedia()
                        -- We don't call this:onClose(), we need the highlight
                        -- to still be there, as we may Highlight it from the
                        -- dict lookup widget.
                    end)
                end,
            }
        end,
        ["04_wordreference"] = function(this)
            return {
                icon = _("button.wordreference"),
                callback = function()
                    UIManager:scheduleIn(0.1, function()
                        WordReference:lookup_and_show(this.selected_text.text)
                        -- We don't call this:onClose(), we need the highlight
                        -- to still be there, as we may Highlight it from the
                        -- dict lookup widget.
                    end)
                end,
            }
        end,
        ["05_dictionary"] = function(this, index)
            return {
                icon = _("button.dictionary"),
                callback = function()
                    this:lookupDict(index)
                    -- We don't call this:onClose(), same reason as above
                end,
            }
        end,
        ["06_translate"] = function(this, index)
            return {
                icon = _("button.translate"),
                callback = function()
                    this:translate(index)
                    -- We don't call this:onClose(), so one can still see
                    -- the highlighted text when moving the translated
                    -- text window, and also if NetworkMgr:promptWifiOn()
                    -- is needed, so the user can just tap again on this
                    -- button and does not need to select the text again.
                end,
            }
        end,
        ["07_search"] = function(this)
            return {
                icon = _("button.search"),
                callback = function()
                    this:onHighlightSearch()
                    -- We don't call this:onClose(), crengine will highlight
                    -- search matches on the current page, and self:clear()
                    -- would redraw and remove crengine native highlights
                end,
            }
        end,
    }
end
