%% Clear everything out

clc

fprintf('%s - Clearing everything out\n', datetime)

close all
clearvars

%% Read in weight data

fprintf('%s - Reading in weight data\n', datetime)

weight_datetime = [];
weight = [];
bmi = [];
fat = [];

fid = fopen("FitbitAriaMeasurements.csv","r");

line = fgetl(fid); % skip header line

while ~feof(fid)
    line = fgetl(fid);
    tokens = split(line,',');
    weight_datetime = [weight_datetime; datetime(tokens{1})];
    weight = [weight; str2double(tokens{2})];
    bmi = [bmi; str2double(tokens{3})];
    fat = [fat; str2double(tokens{4})];
end

fclose(fid);

%% Read in blood glucose/ketone data

fprintf('%s - Reading in blood glucose/ketone data\n', datetime)

glucose_datetime = [];
ketones_datetime = [];
glucose = [];
ketones = [];

fid = fopen("KetoMojoReadings.csv","r");

line = fgetl(fid); % skip header line

while ~feof(fid)
    line = fgetl(fid);
    tokens = split(line,',');

    if strcmp(tokens{1},"ketone")
        ketones_datetime = [ketones_datetime; datetime([tokens{4} ' ' tokens{5}])];
        ketones = [ketones; str2double(tokens{2})];
    elseif strcmp(tokens{1},"glucose")
        glucose_datetime = [glucose_datetime; datetime([tokens{4} ' ' tokens{5}])];
        glucose = [glucose; str2double(tokens{2})];
    else
        'hey'
    end
end

fclose(fid);

%% Read in basal energy data

fprintf('%s - Reading in basal energy data\n', datetime)

basal_start_datetime = [];
basal_end_datetime = [];
basal_calories = [];

fid = fopen("AppleWatchBasalEnergy.csv","r");

line = fgetl(fid); % skip header line

while ~feof(fid)
    line = fgetl(fid);
    tokens = split(line,',');
    basal_start_datetime = [basal_start_datetime; datetime(tokens{1})];
    basal_end_datetime = [basal_end_datetime; datetime(tokens{2})];
    basal_calories = [basal_calories; str2double(tokens{3})];
end

fclose(fid);

%% Read in active energy data

fprintf('%s - Reading in active energy data\n', datetime)

active_start_datetime = [];
active_end_datetime = [];
active_calories = [];

fid = fopen("AppleWatchActiveEnergy.csv","r");

line = fgetl(fid); % skip header line

while ~feof(fid)
    line = fgetl(fid);
    tokens = split(line,',');
    active_start_datetime = [active_start_datetime; datetime(tokens{1})];
    active_end_datetime = [active_end_datetime; datetime(tokens{2})];
    active_calories = [active_calories; str2double(tokens{3})];
end

fclose(fid);

%% Plot data

fprintf('%s - Plotting data\n', datetime)

hFig=figure;

hAx=subplot(6,1,1);
plot(weight_datetime,weight,'.')
grid on
ylabel('Weight (lbs)')

hAx(2)=subplot(6,1,2);
plot(weight_datetime,fat,'.')
grid on
ylabel('Fat (lbs)')

hAx(3)=subplot(6,1,3);
plot(glucose_datetime,glucose,'.')
grid on
ylabel('Glucose (mg/dL)')

hAx(4)=subplot(6,1,4);
plot(ketones_datetime,ketones,'.')
grid on
ylabel('Ketones (mmol/L)')

hAx(5)=subplot(6,1,5);
plot(basal_start_datetime,basal_calories,'.')
grid on
ylabel('Basal Energy (cal)')

hAx(6)=subplot(6,1,6);
plot(active_start_datetime,active_calories,'.')
grid on
ylabel('Active Energy (cal)')

linkaxes(hAx,'x')

xlim([datetime(2023,2,7) datetime(2023,11,17)])

saveas(hFig,'weight_glucose_ketone_data','png')

hFig=figure;
histogram(glucose,60:1:130)
xlim([60 130])
grid on
xlabel('Glucose (mg/dL)')
title(sprintf('\\mu = %1.1f mg/dL, \\sigma = %1.1f mg/dL', mean(glucose), std(glucose)))

saveas(hFig,'glucose_histogram','png')

hFig=figure;
histogram(ketones,0:0.1:5)
xlim([0 5])
grid on
xlabel('Ketones (mmol/L)')
title(sprintf('\\mu = %1.1f mg/dL, \\sigma = %1.1f mg/dL', mean(ketones), std(ketones)))

saveas(hFig,'ketone_histogram','png')