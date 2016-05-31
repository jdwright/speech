function [out,outp] = filter_sync(filters,source,per_samps,fs,bw,ampq)
% filter synchronously with glottal periods
% each period has a single filter
samp_rate = 22050;
num_samp = length(source);

%fc = f_contour(num_samp,fs);

%plot(fc');

% quantize formants for filters, down to zero index possibly
%fc(1,:) = (fc(1,:)-200)/10;
%fc(2,:) = (fc(2,:)-1000)/20;
%fc(3,:) = (fc(3,:)-2000)/20;

%fc = round(fc);

%fti = [ 101*51 51 1 ] * fc + 1; % indices into filter matrix

out = zeros(1,num_samp);

%bw = [ 40 50 70 100 200 ];

if 1 == 1
    ft = make_filter(fs,bw);
    out = filtfilt(ft(1:45),ft(46:90),source);
else
    sampn = 1;
    for per_samp = per_samps
        vec = sampn:sampn+per_samp-1;
        midp = sampn+round(per_samp/2);
    %    ft = filters(fti(midp),:); % select from filter matrix
        ft = make_filter(fs,bw); % create filter on the fly
        out(vec) = filter(ft(1:45),ft(46:90),source(vec));
        sampn = sampn + per_samp;
    end
end

ns = .01;
%out = out + random('norm',0,ns,1,length(out));
%out = [random('norm',0,ns,1,5000) out random('norm',0,ns,1,5000)];
out = out / max([ max(out) abs(min(out)) ]) * ampq;
%out = out .* gausswin(length(out))';
outp = audioplayer(out,samp_rate);
end
