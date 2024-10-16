
[lon,lat,area] = loadworldmesh(0.5);
idir = '/Users/shuangma/RESEARCH/DATA/SIF_TROPOMI/2018_2024_05deg_PFT/';
odir = '/Users/shuangma/RESEARCH/WORKFLOW/A1_EXTREME_DATA_ANALYSIS/S3_output/';
sif_variable_name = 'SIF_Corr_743';
time_variable_name= 'time';
% lcp_variable_name = 'LC_PERC_2020';
% nsounding_variable_name = 'n';
pft_name = 'grassland';
sif_multiyr = NaN(360,720,46,7);
time_multiyr= [];
count = 0;

for iyear = 2018:2024
    count = count + 1;
    filename = ['TROPOMI.ESA.SIF.' num2str(iyear) '.8day.0.50deg.' pft_name '.nc'];
    sif_data = permute(ncread([idir filename], sif_variable_name), [2 1 3]);
    time_data = ncread([idir filename], time_variable_name);
    if iyear==2018
        NAM = NaN(360,720,46-size(sif_data,3));
        sif_data = cat(3,NAM,sif_data);
        NAA = NaN(46-size(time_data,1),1);
        time_data=cat(1,NAA,time_data);
    elseif iyear==2024
        NAM = NaN(360,720,46-size(sif_data,3));
        sif_data = cat(3,sif_data,NAM);
        NAA = NaN(46-size(time_data,1),1);
        time_data=cat(1,time_data,NAA);
    end
        sif_multiyr(:,:,:,count) = sif_data;
        time_multiyr = cat(1,time_multiyr,time_data);
end
% get sif_anomaly from 7 years of data
sif_multiyr_mean = squeeze(nanmean(sif_multiyr,4));
sif_anomaly_4D = sif_multiyr - sif_multiyr_mean;

multiyr_upper_boundary = max(sif_multiyr(:));
anomaly_upper_boundary = max(sif_anomaly_4D(:)); % 
plotglobal(sif_multiyr_mean(:,:,3));
caxis([0, max(sif_multiyr_mean(:))]);

%% % create the anomaly gif
% Step 1: reshape 4D to 3D
sif_anomaly = reshape(sif_anomaly_4D,360,720,[]);
timestamp = time_multiyr;
% Example array of numbers representing days since 1970-01-01
days_since_epoch = timestamp;  % Replace with your actual array
% Create a reference date for the Unix epoch start (1970-01-01)
epoch_start = datetime(1970, 1, 1);
% Convert days since epoch to calendar dates
calendarDates = epoch_start + days(days_since_epoch);
% Display the calendar dates
disp(calendarDates);

% Specify the output GIF file name
gif_filename = [odir [pft_name 'SIF_anomaly_map.gif'];

    q999 = quantile(sif_anomaly(:),0.999);
    q001 = quantile(sif_anomaly(:),0.001);
% Step 2: Create a Loop to Plot Each Frame
figure; % Create a new figure for the animation
for t = 16:306
    % Plot the data for the current time step
    plotglobal(sif_anomaly(:,:,t));
    set(gcf, 'Color', 'w');
    colormap(redbluecolormap);
    % Add titles and labels
    title(['SIF anomaly at ' datestr(calendarDates(t))]);
    xlabel('Longitude');
    ylabel('Latitude');
    colorbar; % Show a color bar
    

    caxis([q001,q999]);


    % Step 3: Capture Each Frame
    % Capture the plot as an image
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);

    % Step 4: Save the Frames to a GIF File
    % Write to the GIF file
    if t == 16
        % First frame, create the GIF file
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 0.5);
    else
        % Subsequent frames, append to the GIF file
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
    end
end

disp('GIF animation created successfully.');

