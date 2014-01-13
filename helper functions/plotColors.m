
% Clean out zeros
sumRclean = sumR(find(sumR>0));
sumGclean = sumG(find(sumG>0));
sumBclean = sumB(find(sumB>0));

filenames = files(find(sumR>0));
for i = 1:length(filenames)
    a = strsplit(filenames{i},'_');
    yy{i} = (a{2});
    mm{i} = (a{3});
    dd{i} = (a{4});
    hh{i} = (a{5});
    mn{i} = (a{6});
   curdat{i} = datestr(datenum(strcat(dd(i),mm(i),yy(i),hh(i),mn(i)),'ddmmyyyyHHMM'));
end


plot(sumRclean,'r.-');
hold on
plot(sumGclean,'g.-');
plot(sumBclean,'b.-');

title('Total number of Red, Green and Blue pixels in each image | BVZ0018 | 5-min intervals')
return
plot(sumR,'r.-');
hold on
plot(sumG,'g.-');
plot(sumB,'b.-');
