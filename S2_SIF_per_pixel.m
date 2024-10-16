
[lon,lat,area] = loadworldmesh(0.5);
idir = '/Users/shuangma/RESEARCH/DATA/SIF_TROPOMI/2018_2024_05deg_PFT/Shuang_SIF_1/';
% sif_variable_longname = 'retrieved SIF@740 (743-758nm)';
sif_variable_name = 'SIF_Corr_743';
lcp_variable_name = 'LC_PERC_2020';
nsounding_variable_name = 'n';
pft_name = 'grassland';
% A = NaN(320,1);
A = [];

for iyear = 2019:2024
    filename = ['TROPOMI.ESA.SIF.' num2str(iyear) '.8day.0.50deg.' pft_name '.nc'];
    sif_data = permute(ncread([idir filename], sif_variable_name), [2 1 3]);
%     lc_perc = permute(ncread([idir filename], lcp_variable_name), [2 1 3]);
%     nsounding = permute(ncread([idir filename], nsounding_variable_name), [2 1 3]);

%     plotglobal(nanmean(sif_data,3));
    % plotglobal(nanmean(lc_perc,3));
%     plotglobal(nanmean(nsounding,3));

    % find the pixel nrow ncol
    a = nanmean(nsounding,3);
    a(252,120) = 10000; % the grassland pixel with most soundings in california
%     plotglobal(a)

    % plot time series of the pixel sif value
%     plot(squeeze(sif_data(252,120,:)))
    new_data = squeeze(sif_data(252,120,:))';
    A = [A new_data];
    
end

plot(1:length(A),A);xticks(0:46:max(length(A)));