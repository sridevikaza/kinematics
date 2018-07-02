clear all;
% Input directory to splines 
splinedir = '/Users/andrealehn/Desktop/UROP/Rosalie/Special/';
pix_per_phys = 3.9; %pixels per mm from calibration 

%% Upload and convert to appropriate coordinates

% NOT READY YET AML 7/1/18
% Call the function spline_to_phys to convert from image to physical coords
% [sp, head_x, head_y, tail_x, tail_y, numimgs]=spline_to_phys(splinedir, pix_per_phys);

cd(splinedir);
%upload spline structure saved as spline.mat by find_fish_coords.m
load('spline.mat');
num_imgs = length(spline);

% Convert from pixels to mm to plot
head_x = []; head_y = [];
tail_x = []; tail_y = [];
temp_x = 0; temp_y = 0;
x = []; y = [];

for i = 1:num_imgs
    head_x(i) = spline(i).head_x/pix_per_phys;
    head_y(i) = spline(i).head_y/pix_per_phys;
    tail_x(i) = spline(i).tail_x/pix_per_phys;
    tail_y(i) = spline(i).tail_y/pix_per_phys;
    temp_x = spline(i).spline_x; temp_y = spline(i).spline_y;
    x = temp_x/pix_per_phys; y = temp_y/pix_per_phys;
    sp(i).x = x; sp(i).y = y;
end

figure;
hold on;
% You can insert a for loop here to plot multiple splines
% i.e. for i =1:10:num_imgs 
for i=1:num_imgs
plot(sp(i).x, sp(i).y);
scatter(head_x(i), head_y(i));
hold on;
scatter(tail_x(i), tail_y(i));
end
