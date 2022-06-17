extends Timer

var INPUT_BUFFER = 0.2

func check_input():
	return time_left < INPUT_BUFFER or time_left > wait_time - INPUT_BUFFER
