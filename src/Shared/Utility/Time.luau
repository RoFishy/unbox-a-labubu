return {
	GetNextIntervalTime = function(now: number, interval: number)
		return (now + (interval - (now % interval)))
	end,

	GetPreviousIntervalTime = function(now: number, interval: number)
		return now - (now % interval)
	end,

	IsOnInterval = function(time: number, interval: number)
		return time % interval == 0
	end,

	FormatMS = function(s: number): string
		return string.format("%.f:%02d", s / 60, s % 60)
	end,
}
