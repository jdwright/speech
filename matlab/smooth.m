function out = smooth(data,n)
lth = length(data);
out = zeros(1,lth);
m = floor(n/2);
for a = 1+m:lth-m
    out(a) = mean(data(a-m:a+m));
end
