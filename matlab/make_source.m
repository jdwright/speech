function [out,per_samp] = make_source(fund,time,sh,ns,ampq)
% time changes with output
samp_rate = 22050;

pc = pitch_contour(fund,time,2);
num_per = round(fund * time);
samples = time * samp_rate;

%plot(pc)

out = [ ];
wave = make_period(.3,.01);
wlen = length(wave);
per_samp = [ ];
%for pn = 1:num_per
while length(out) < samples
    psamp = round(samp_rate / pc(length(out)+1)); % samp_rate * 1/pitch 
    per_samp = [ per_samp psamp ];
    inc = wlen / psamp;
    % better if rounding done in make_period, probably
    out = [   out   wave( round(inc:inc:wlen) )   ];
end

out = out + random('norm',0,ns,1,length(out));
mx = max( [ max(out) abs(min(out)) ] );
out = out / mx * ampq;

end
