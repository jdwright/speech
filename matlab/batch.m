function batch()
y = opensph('s_m110_bxqg.sph');
y = y(5000:11000);
y = y(1100:5000);
sp = sgram(y,.005,.001,1024,30,1500);
c = sp_max(sp,5,10);
x = search(c,1,10) + 1;
[r,c] = size(sp);
y = (r-x)/512*8000;
fid = fopen('out.txt','wt');
fprintf(fid,'s_m110_bxqg.sph %d\n',y);
fclose(fid);

