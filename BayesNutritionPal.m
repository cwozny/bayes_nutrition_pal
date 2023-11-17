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

%% Plot data

hFig=figure;

hAx=subplot(4,1,1);
plot(weight_datetime,weight,'.')
grid on
ylabel('Weight (lbs)')

hAx(2)=subplot(4,1,2);
plot(weight_datetime,fat,'.')
grid on
ylabel('Fat (lbs)')

hAx(3)=subplot(4,1,3);
plot(glucose_datetime,glucose,'.')
grid on
ylabel('Glucose (mg/dL)')

hAx(4)=subplot(4,1,4);
plot(ketones_datetime,ketones,'.')
grid on
ylabel('Ketones (mmol/L)')

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