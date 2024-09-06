local skip_labels = {
	["Complete name"] = true,
	["CompleteName_Last"] = true,
	["Unique ID"] = true,
	["File size"] = true,
	["Format/Info"] = true,
	["Codec ID/Info"] = true,
	["MD5 of the unencoded content"] = true,
}

local M = {}

function M:peek()
	local image_height = 0

	if self:preload() == 1 then
		local cache = ya.file_cache(self)
		if cache and fs.cha(cache).length > 0 then
			image_height = ya.image_show(cache, self.area).h
		end
	end

	local cmd = "mediainfo"
	local output, code = Command(cmd)
		:args({ tostring(self.file.url) })
		:stdout(Command.PIPED)
		:output()

	local lines = {}

	if output then
		local i = 0
		for str in output.stdout:gmatch("[^\n]*") do
			local label, value = str:match("(.*[^ ])  +: (.*)")
			local line

			if label then
				if not skip_labels[label] then
					line = ui.Line({
						ui.Span(label .. ": "):bold(),
						ui.Span(value),
					})
				end
			elseif str ~= "General" then
				line = ui.Line({ ui.Span(str):underline() })
			end

			if line then
				if i >= self.skip then
					table.insert(lines, line)
				end

				local max_width = math.max(1, self.area.w - 3)
				i = i + math.max(1, math.ceil(line:width() / max_width))
			end
		end
	else
		local error = string.format("Spawn `%s` command returns %s", cmd, code)
		table.insert(lines, ui.Line(error))
	end

	ya.preview_widgets(self, {
		ui.Paragraph(
			ui.Rect({
				x = self.area.x,
				y = self.area.y + image_height,
				w = self.area.w,
				h = self.area.h - image_height,
			}),
			lines
		):wrap(ui.Paragraph.WRAP),
	})
end

function M:seek(units)
	local h = cx.active.current.hovered
	if h and h.url == self.file.url then
		local step = math.floor(units * self.area.h / 10)
		ya.manager_emit("peek", {
			math.max(0, cx.active.preview.skip + step),
			only_if = self.file.url,
		})
	end
end

function M:preload()
	local cache = ya.file_cache(self)
	if not cache or fs.cha(cache) then
		return 1
	end

	local cmd = "ffmpegthumbnailer"
	local child, code = Command(cmd):args({
		"-q", "6",
		"-c", "jpeg",
		"-i", tostring(self.file.url),
		"-o", tostring(cache),
		"-t", "5",
		"-s", tostring(PREVIEW.max_width),
	}):spawn()

	if not child then
		ya.err(string.format("spawn `%s` command returns %s", cmd, code))
		return 0
	end

	local status = child:wait()
	return status and status.success and 1 or 2
end

return M
