%% Clear everything out

clc

fprintf('%s - Clearing everything out\n', datetime)

close all
clearvars

%% See if we've already parsed the data

dataLoaded = false;

if exist('parsed_data.mat','file')

    fprintf('%s - Loading already parsed data\n', datetime)

    load parsed_data.mat
    dataLoaded = true;
end

%% Read in weight data

if ~dataLoaded

    fprintf('%s - Reading in weight data\n', datetime)

    weight_datetime = [];
    weight = [];
    bmi = [];
    fat = [];

    fid = fopen('FitbitAriaMeasurements.csv','r');

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

end

%% Read in blood glucose/ketone data

if ~dataLoaded

    fprintf('%s - Reading in blood glucose/ketone data\n', datetime)

    glucose_datetime = [];
    ketones_datetime = [];
    glucose = [];
    ketones = [];

    fid = fopen('KetoMojoReadings.csv','r');

    line = fgetl(fid); % skip header line

    while ~feof(fid)
        line = fgetl(fid);
        tokens = split(line,',');

        if strcmp(tokens{1},'ketone')
            ketones_datetime = [ketones_datetime; datetime([tokens{4} ' ' tokens{5}])];
            ketones = [ketones; str2double(tokens{2})];
        elseif strcmp(tokens{1},'glucose')
            glucose_datetime = [glucose_datetime; datetime([tokens{4} ' ' tokens{5}])];
            glucose = [glucose; str2double(tokens{2})];
        else
            'hey'
        end
    end

    fclose(fid);

end

%% Read in basal energy data

if ~dataLoaded

    fprintf('%s - Reading in basal energy data\n', datetime)

    basal_start_datetime = [];
    basal_end_datetime = [];
    basal_calories = [];

    fid = fopen('AppleWatchBasalEnergy.csv','r');

    line = fgetl(fid); % skip header line

    while ~feof(fid)
        line = fgetl(fid);
        tokens = split(line,',');
        basal_start_datetime = [basal_start_datetime; datetime(tokens{1})];
        basal_end_datetime = [basal_end_datetime; datetime(tokens{2})];
        basal_calories = [basal_calories; str2double(tokens{3})];
    end

    fclose(fid);

end

%% Read in active energy data

if ~dataLoaded

    fprintf('%s - Reading in active energy data\n', datetime)

    active_start_datetime = [];
    active_end_datetime = [];
    active_calories = [];

    fid = fopen('AppleWatchActiveEnergy.csv','r');

    line = fgetl(fid); % skip header line

    while ~feof(fid)
        line = fgetl(fid);
        tokens = split(line,',');
        active_start_datetime = [active_start_datetime; datetime(tokens{1})];
        active_end_datetime = [active_end_datetime; datetime(tokens{2})];
        active_calories = [active_calories; str2double(tokens{3})];
    end

    fclose(fid);

end

%% Read in nutrition data

if ~dataLoaded

    fprintf('%s - Reading in nutrition data\n', datetime)

    nutrition_datetime = [];
    nutrition_calories = [];
    nutrition_total_carbs = [];
    nutrition_protein = [];
    nutrition_total_fats = [];
    nutrition_sugar = [];
    nutrition_fiber = [];
    nutrition_sugar_alcohol = [];

    fid = fopen('FoodNomsPrunedData.csv','r');

    line = fgetl(fid); % skip header line

    while ~feof(fid)
        line = fgetl(fid);
        tokens = split(line,',');
        nutrition_datetime = [nutrition_datetime; datetime(tokens{1})];
        nutrition_calories = [nutrition_calories; str2double(tokens{2})];
        nutrition_total_carbs = [nutrition_total_carbs; str2double(tokens{3})];
        nutrition_protein = [nutrition_protein; str2double(tokens{4})];
        nutrition_total_fats = [nutrition_total_fats; str2double(tokens{5})];
        nutrition_sugar = [nutrition_sugar; str2double(tokens{6})];
        nutrition_fiber = [nutrition_fiber; str2double(tokens{7})];
        nutrition_sugar_alcohol = [nutrition_sugar_alcohol; str2double(tokens{8})];
    end

    fclose(fid);

    nutrition_calories(isnan(nutrition_calories)) = 0;
    nutrition_total_carbs(isnan(nutrition_total_carbs)) = 0;
    nutrition_protein(isnan(nutrition_protein)) = 0;
    nutrition_total_fats(isnan(nutrition_total_fats)) = 0;
    nutrition_sugar(isnan(nutrition_sugar)) = 0;
    nutrition_fiber(isnan(nutrition_fiber)) = 0;
    nutrition_sugar_alcohol(isnan(nutrition_sugar_alcohol)) = 0;

end

%% Save intermediate .mat files

if ~dataLoaded

    save('parsed_data.mat','weight_datetime','weight','bmi','fat', ...
         'glucose_datetime','ketones_datetime','glucose','ketones', ...
         'basal_start_datetime','basal_end_datetime','basal_calories', ...
         'active_start_datetime','active_end_datetime','active_calories', ...
         'nutrition_datetime','nutrition_calories','nutrition_total_carbs','nutrition_protein','nutrition_total_fats', ...
         'nutrition_sugar','nutrition_fiber','nutrition_sugar_alcohol');

end

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

minDay = dateshift(min(glucose_datetime),'start','days');
maxDay = dateshift(max(glucose_datetime),'end','days');

xlim([minDay maxDay]);

saveas(hFig,'all_data','png')

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

%% Create feature vectors

fid = fopen('AggregatedData.csv','w');

fprintf(fid, 'Start Period,End Period,Start Weight (lbs),Start Fasting Glucose (mg/dL),Start Fasting Ketones (mmol/L),Active Energy (cal),Basal Energy (cal),Nutrition Energy (cal),Total Carbs (g),Protein (g),Total Fats (g),End Weight (lbs),Weight Difference (lbs),End Fasting Glucose (mg/dL),End Fasting Ketones (mmol/L)\n');

for ii = 2:length(weight_datetime)

    startPeriod = weight_datetime(ii-1);
    endPeriod = weight_datetime(ii);

    if duration(endPeriod - startPeriod) < hours(29)

        hasAllData = true;

        startPeriodWeight = weight(ii-1);
        endPeriodWeight = weight(ii);

        activeCalIdx = startPeriod <= active_start_datetime & active_start_datetime <= endPeriod;

        if sum(activeCalIdx) == 0
            hasAllData = false;
            warning('No active calorie data for %s to %s', startPeriod, endPeriod)
            activeCals = nan;
        else
            activeCals = sum(active_calories(activeCalIdx));
        end

        basalCalIdx = startPeriod <= basal_start_datetime & basal_start_datetime <= endPeriod;

        if sum(basalCalIdx) == 0
            hasAllData = false;
            warning('No basal calorie data for %s to %s', startPeriod, endPeriod)
            basalCals = nan;
        else
            basalCals = sum(basal_calories(basalCalIdx));
        end

        nutritionIdx = startPeriod <= nutrition_datetime & nutrition_datetime <= endPeriod;

        if sum(nutritionIdx) == 0
            hasAllData = false;
            warning('No nutrition data for %s to %s', startPeriod, endPeriod)
            nutritionCals = nan;
            nutritionTotalCarbs = nan;
            nutritionProtein = nan;
            nutritionTotalFats = nan;
        else
            nutritionCals = sum(nutrition_calories(nutritionIdx));
            nutritionTotalCarbs = sum(nutrition_total_carbs(nutritionIdx));
            nutritionProtein = sum(nutrition_protein(nutritionIdx));
            nutritionTotalFats = sum(nutrition_total_fats(nutritionIdx));
        end

        startGlucoseIdx = startPeriod - hours(4) <= glucose_datetime & glucose_datetime <= startPeriod + hours(4);
        endGlucoseIdx = endPeriod - hours(4) <= glucose_datetime & glucose_datetime <= endPeriod + hours(4);

        if sum(startGlucoseIdx) == 0
            hasAllData = false;
            warning('No starting glucose data for %s to %s', startPeriod, endPeriod)
            startFastingGlucose = nan;
        else
            startFastingGlucose = glucose(startGlucoseIdx);
        end

        if sum(endGlucoseIdx) == 0
            hasAllData = false;
            warning('No ending glucose data for %s to %s', startPeriod, endPeriod)
            endFastingGlucose = nan;
        else
            endFastingGlucose = glucose(endGlucoseIdx);
        end

        startKetonesIdx = startPeriod - hours(4) <= ketones_datetime & ketones_datetime <= startPeriod + hours(4);
        endKetonesIdx = endPeriod - hours(4) <= ketones_datetime & ketones_datetime <= endPeriod + hours(4);

        if sum(startKetonesIdx) == 0
            hasAllData = false;
            warning('No starting ketone data for %s to %s', startPeriod, endPeriod)
            startFastingKetones = nan;
        else
            startFastingKetones = ketones(startKetonesIdx);
        end

        if sum(endKetonesIdx) == 0
            hasAllData = false;
            warning('No ending ketone data for %s to %s', startPeriod, endPeriod)
            endFastingKetones = nan;
        else
            endFastingKetones = ketones(endKetonesIdx);
        end

        if hasAllData
            fprintf(fid,'%s,%s,%1.2f,%1.0f,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f,%1.2f,%1.2f,%1.0f,%1.1f\n', ...
                startPeriod, endPeriod, ...
                startPeriodWeight, startFastingGlucose, startFastingKetones, ...
                activeCals, basalCals, nutritionCals, ...
                nutritionTotalCarbs, nutritionProtein, nutritionTotalFats, ...
                endPeriodWeight, (endPeriodWeight-startPeriodWeight), endFastingGlucose, endFastingKetones);
        end
    end
end

fclose(fid);

%% Plot data

fprintf('%s - Plotting data\n', datetime)

hFig=figure;

hAx=subplot(7,1,1);
plot(startPeriod,startWeight,'.')
grid on
ylabel('Weight (lbs)')

hAx(2)=subplot(7,1,2);
plot(startPeriod,basalCals,'.')
grid on
ylabel('Basal Energy (cal)')

hAx(3)=subplot(7,1,3);
plot(startPeriod,activeCals,'.')
grid on
ylabel('Active Energy (cal)')

hAx(4)=subplot(7,1,4);
plot(startPeriod,nutritionCals,'.')
grid on
ylabel('Nutritional Energy (cal)')

hAx(5)=subplot(7,1,5);
plot(startPeriod,nutritionTotalCarbs,'.')
grid on
ylabel('Total Carbs (g)')

hAx(6)=subplot(7,1,6);
plot(startPeriod,nutritionProtein,'.')
grid on
ylabel('Protein (g)')

hAx(7)=subplot(7,1,7);
plot(startPeriod,nutritionTotalFats,'.')
grid on
ylabel('Total Fats (g)')

linkaxes(hAx,'x')

minDay = dateshift(min(glucose_datetime),'start','days');
maxDay = dateshift(max(glucose_datetime),'end','days');

xlim([minDay maxDay]);
