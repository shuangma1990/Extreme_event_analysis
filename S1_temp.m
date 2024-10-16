% step1 read .nc data
idir = '/Users/shuangma/RESEARCH/DATA/ERA5_single_level/';
yrstring = ["2018","2019","2020","2021","2022","2023","2024"];
monthstring = ["01","02","03","04","05","06","07","08","09","10","11","12"];
[lon025,lat025,A025]=loadworldmesh(0.25);

for iyr = 1:length(yrstring)
    for imonth=1:12
        filename = [char(yrstring(iyr)) char(monthstring(imonth)) '.nc'];
        % info = ncinfo([idir filename]);
        vardata = ncread([idir filename],'t2m');
%         plotglobal(vardata(:,:,1));
        a = flipud(permute((vardata-273.15),[2 1 3]));
        b = a(:,[721:1440,1:720],:);
        % plotglobal(nanmean(b, 3));
        hourly_data = b;
        [daily_data] = hourly2daily(hourly_data);
        % plotglobal(nanmean(daily_data, 3));
        % plotglobal(nanmean(hourly_data, 3));
        daily_data(721,:,:) = []; % I don't know where the 721 row came from
        daily_data_1deg = mapsfun_coarsen_resolution(daily_data,A025,4);
        % plotglobal(nanmean(daily_data_1deg, 3));
    end
end

function [daily_data] = hourly2daily(hourly_data)
    daily_data=zeros(size(hourly_data,1),size(hourly_data,2),size(hourly_data,3)/24);
%     take average every 24 hours
    for m=1:24;daily_data=daily_data+hourly_data(:,:,m:24:end)/24;end
end

