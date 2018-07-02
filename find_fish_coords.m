%% Upload binary masks to fit spline to fish 
% This code searches for masks as single tifs in the directory maskdir
% Input whether fish is swimming in + or - y direction

% NOTE: image coordinates have the origin at the top left: 
% the +y axis goes down and the +x axis goes right
% in matlab this is called "matrix" axes mode
% type 'help axis' to see how to toggle between matrix and cartesian mode

% Spline is structured so fish is swimming in +x direction (see comments)

clear all;

% Input directory with masked tif images in maskdir: currently no 
% functionality to process only certain masks so all tifs
% in folder will be uploaded and processed
maskdir = '/Users/andrealehn/Desktop/UROP/Rosalie/Special/'; 
direction = 'negative'; % Put in negative or positive for swimming direction

%% Code from here on shouldn't need to be changed 
% set and initialize some values
ind_t = 0; ind_h = 0;
n = 100; % number of points on spline to evaluate and save

% create mask structure
cd(maskdir)
masks = dir('*.tif');
sz = size(masks);
numfiles = sz(1); %numfiles is the number of .tifs found

% add binary images to masks structure
for i=1:numfiles
masks(i).binary = imread(masks(i).name); %read the images from their names
spline(i).mask_name = masks(i).name;
end

% Fit spline to binary mask and extract relevant points
for i = 1:numfiles
    msk = masks(i).binary;
    msk = imbinarize(msk);
    [rows,cols] = find(msk); 
    x = []; y = []; % re-initialize this for every mask
    
    % The for loop below creates columns x and y for spline fitting
    % The points (x,y) are at the center of the fish body 
    % One point is generated for each row (vertical location)
    for j = min(rows):max(rows) 
        inds = find(rows == j); % find indices where row is same
        y = [y; j]; % save vertical location as current row
        x_temp = mean(cols(inds)); %find average of column (x) values where row is the same 
        x_temp=round(x_temp); %round to nearest whole number column
        x = [x; x_temp];  % save average horizontal value     
    end
    % the 'fit' function fits a curve to the points generated above
    sp = fit(y,x,'smoothingspline'); %Fit to x and y in this order
    
    if (direction == 'negative')
    % This assumes fish is swimming in -y direction
    [head_y,ind_h] = min(y); %head vertical location, min y (img coords)
    head_x = x(ind_h); % x location corresponding to head position
    [tail_y, ind_t] = max(y); %tail vertical location, max y (img coords) 
    tail_x = x(ind_t); % x location corersponding to tail position
    end
    
    if (direction == 'positive')
    % This assumes fish is swimming in +y direction
    [head_y,ind_h] = max(y); %head vertical location, max y (img coords)
    head_x = x(ind_h); % x location corresponding to head position
    [tail_y, ind_t] = min(y); %tail vertical location, min y (img coords) 
    tail_x = x(ind_t); % x location corersponding to tail position
    end
    
    % Save x and y points used to determine spline (from mask)
    % Scatter plot of (x,y) over mask image should plot points on body
    % Note that this is NOT the spline--just points to create spline
    spline(i).fish_x = x;
    spline(i).fish_y = y;
    
    % Save spline locations x and y
    % Spline will plot in x-y with fish swimming from left to right (+x) 
    horizontal_data = linspace(tail_y, head_y, n); %set tail position to min x
    %horizontal_data = sort(horizontal_data, 'ascend');
    sp_y = feval(sp,horizontal_data); %evaluate spline over select points
    
    % change indices ?
    
    spline(i).spline_x = (-horizontal_data)'; %fish swimming in +x 
    spline(i).spline_y = sp_y;
    
    % Save head and tail locations in spline structure
    % Note that these are spline position corresponding to head and tail
    spline(i).head_x = -head_y;
    spline(i).head_y = feval(sp,head_y);
    spline(i).tail_x = -tail_y;
    spline(i).tail_y = feval(sp,tail_y);
end

% Plotting x and y points as scatter on mask to test
% figure;
% imshow(msk);
% hold on;
% scatter(x,y);

%Save spline structure as spline.mat
save('spline.mat','spline', '-v7.3')

% NOTE: you can now plot head and tail locations from each mask as well as
% spline points using the spline structure. Here is an example of how to
% plot the head location from the first mask generated:
%
% plot (spline(1).head_x, spline(1).head_y)
%
% You could plot multiple splines using a for loop 
