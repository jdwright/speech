# port of the same function in the matlab directory
sgram <- function(data, window_length, time_step, N, drange, fq_lim){
	samp_rate <- 16000
	window_length <- round(window_length * samp_rate)
	time_step <- round(time_step * samp_rate)
	Nover2 <- round(N / 2)
	if(fq_lim != 0){
		Nover2 <- round(fq_lim / (samp_rate / 2) * Nover2)
	}
	num_win <- floor((length(data) - window_length) / time_step)
	# switched dimensions
	out <- matrix(0, num_win, Nover2)
	win <- gausswin(window_length)
	buf1 <- matrix(0, 1, N)
	preemph <- 6 * log2( (1:Nover2) / Nover2 * (samp_rate / 2) / 1000 ) + 6
	preemph[ preemph < 0 ] <- 0
	for( x in seq( 1, time_step*(num_win-1)+1, time_step ) ){
	   buf2 <- buf1
	   buf2[1:window_length] <- data[x:x+window_length-1] * win
	   f <- fft(buf2)
	   y <- ceiling(x / time_step)
	   # switched dimensions
	   out[ y, 1:Nover2 ] <- 20 * log10( 2 * samp_rate / N * abs( f[1:Nover2] ) ) + preemph
	}
	mx <- max(out) - drange
	out <- out - mx
	out[ out < 0 ] <- 0
	return(out)
}