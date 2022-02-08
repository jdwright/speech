function sgram(data, window_length, time_step, N, drange, fq_lim)
    samp_rate = 16000
    window_length = Int(round(window_length*samp_rate))
    time_step = Int(round(time_step*samp_rate))
    Nover2 = Int(round(N / 2))
    if fq_lim != 0
        Nover2 = Int(round(fq_lim / (samp_rate/2) * Nover2))
    end
    num_win = Int(floor((length(data) - window_length) / time_step))
    out = zeros(Nover2, num_win)
    win = gaussian(window_length, .5)
    buf1 = zeros(1, N)
    preemph = 6 .* log2.((1:Nover2) ./ Nover2 .* (samp_rate/2) ./1000) .+ 6
    preemph[preemph.<0] .= 0
    for x in 1:time_step:time_step*(num_win-1)+1
        buf2 = buf1
        buf2[1:window_length] = data[x:x+window_length-1] .* win
        f = fft(buf2)
        y = Int(ceil(x/time_step))
        out[Nover2:-1:1, y] = 20 .* log10.(2 .* samp_rate ./ N .* abs.(f[1:Nover2])) .+ preemph
    end
    mx = maximum(out[:]) .- drange
    out = out .- mx
        out[out.<0] .= 0
        out = out ./ maximum(out)
        # return [maximum(out), minimum(out)]

    out = 1 .- out
    return Gray.(out)
end

println("done")
println("done")

