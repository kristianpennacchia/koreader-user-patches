local ReaderHighlight = require("apps/reader/modules/readerhighlight")

ReaderHighlight.onShowHighlightMenu = function(self, index)
	if not self.selected_text or self.hold_pos == nil then
		return
	end

	index = self:saveHighlight(true)
	self:clear()
	self:showHighlightNoteOrDialog(index)
end
