function search_t(data)
[r,c] = size(data);
rs = 2;
cs = 10;
a = r-rs;
b = 1+cs;
[m1,a1] = search_t_h(sum(data(:,b-cs:b+cs),2),rs);
[m2,a2] = search_t_h(sum(data(:,b+1-cs:b+1+cs),2),rs);
while a2 <= a1
    b = b + 1;
    m1 = m2;
    a1 = a2;
    [m2,a2] = search_t_h(sum(data(:,b+1-cs:b+1+cs),2),rs);
end
imagesc(data);
hold on
rectangle('Position',[ b-cs a1-rs cs*2+1 rs*2+1 ]);
hold off
