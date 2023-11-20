%% Clear everything out

clc

fprintf('%s - Clearing everything out\n', datetime)

close all
clearvars

%% Set constants

fprintf('%s - Setting constants\n', datetime)

APPLE_WATCH_STR = 'Apple Watch';
SLEEP_STR = 'HKCategoryTypeIdentifierSleepAnalysis';
BASAL_ENERGY_STR = 'HKQuantityTypeIdentifierBasalEnergyBurned';
ACTIVE_ENERGY_STR = 'HKQuantityTypeIdentifierActiveEnergyBurned';
DEEP_SLEEP_STR = 'HKCategoryValueSleepAnalysisAsleepDeep';
CORE_SLEEP_STR = 'HKCategoryValueSleepAnalysisAsleepCore';
REM_SLEEP_STR = 'HKCategoryValueSleepAnalysisAsleepREM';
UNK_SLEEP_STR = 'HKCategoryValueSleepAnalysisAsleepUnspecified';
START_STR = 'startDate=';
END_STR = 'endDate=';
VALUE_STR = 'value=';

%% Get file from user

fprintf('%s - Getting filename from user\n', datetime)

[file,path] = uigetfile('export.xml');

if isequal(file,0)
   disp('User selected Cancel');
end

%% Read in energy data

fprintf('%s - Reading in Apple Health data from %s\n', datetime, fullfile(path,file))

start_active_energy_datetime = [];
end_active_energy_datetime = [];
active_calories = [];

start_basal_energy_datetime = [];
end_basal_energy_datetime = [];
basal_calories = [];

start_sleep_datetime = [];
end_sleep_datetime = [];
sleep_duration = [];

fid = fopen(fullfile(path,file),'r');

while ~feof(fid)
    line = fgetl(fid);

    containsAppleWatchString = contains(line,APPLE_WATCH_STR);

    if containsAppleWatchString

        containsBasalEnergyString = contains(line,BASAL_ENERGY_STR);
        containsActiveEnergyString = contains(line,ACTIVE_ENERGY_STR);
        containsSleepString = contains(line,SLEEP_STR);

        startDatePos = strfind(line,START_STR);
        endDatePos = strfind(line,END_STR);
        valuePos = strfind(line,VALUE_STR);

        if containsActiveEnergyString || containsBasalEnergyString
        
            start_energy_datetime = datetime(line(startDatePos + length(START_STR) + 1 : endDatePos - 3 - 6));
            end_energy_datetime =   datetime(line(endDatePos   + length(END_STR)   + 1 : valuePos   - 3 - 6));

            if contains(line,'/>')
                calories = str2double(line(valuePos + length(VALUE_STR) + 1 : end - 3));
            elseif contains(line,'>') % Bug in Apple's XML file not closing tag out
                calories = str2double(line(valuePos + length(VALUE_STR) + 1 : end - 2));
            else
                warning('Hit line that didn''t have any closing tag')
            end

            if containsBasalEnergyString
                start_basal_energy_datetime = [start_basal_energy_datetime; start_energy_datetime];
                end_basal_energy_datetime = [end_basal_energy_datetime; end_energy_datetime];
                basal_calories = [basal_calories; calories];
            elseif containsActiveEnergyString
                start_active_energy_datetime = [start_active_energy_datetime; start_energy_datetime];
                end_active_energy_datetime = [end_active_energy_datetime; end_energy_datetime];
                active_calories = [active_calories; calories];
            else
                warning('Hit line that didn''t have basal or active energy')
            end
        elseif containsSleepString
            containsDeepSleepString = contains(line,DEEP_SLEEP_STR);
            containsCoreSleepString = contains(line,CORE_SLEEP_STR);
            containsRemSleepString = contains(line,REM_SLEEP_STR);
            containsUnkSleepString = contains(line,UNK_SLEEP_STR);

            if containsDeepSleepString || containsCoreSleepString || containsRemSleepString || containsUnkSleepString
                start_sleep = datetime(line(startDatePos + length(START_STR) + 1 : endDatePos - 3 - 6));
                end_sleep =   datetime(line(endDatePos   + length(END_STR)   + 1 : valuePos   - 3 - 6));

                start_sleep_datetime = [start_sleep_datetime; start_sleep];
                end_sleep_datetime = [end_sleep_datetime; end_sleep];
                sleep_duration = [sleep_duration; seconds(end_sleep - start_sleep)];
            end
        end
    end
end

fclose(fid);

%% Plot energy data

fprintf('%s - Plotting energy data\n', datetime)

figure
plot(start_basal_energy_datetime, basal_calories, '.')
hold on
plot(start_active_energy_datetime, active_calories, '.')
grid on
ylabel('Calories (cal)')
legend('Basal','Active')

%% Write out pruned active energy data

fprintf('%s - Writing out pruned active energy data\n', datetime)

fid = fopen('AppleWatchActiveEnergy.csv','w');

fprintf(fid,'Start Date/Time,End Date/Time,Calories (cal)\n');

for ii = 1:length(active_calories)
    fprintf(fid,'%s,%s,%1.3f\n', start_active_energy_datetime(ii), end_active_energy_datetime(ii), active_calories(ii));
end

fclose(fid);

%% Write out pruned basal energy data

fprintf('%s - Writing out pruned basal energy data\n', datetime)

fid = fopen('AppleWatchBasalEnergy.csv','w');

fprintf(fid,'Start Date/Time,End Date/Time,Calories (cal)\n');

for ii = 1:length(basal_calories)
    fprintf(fid,'%s,%s,%1.3f\n', start_basal_energy_datetime(ii), end_basal_energy_datetime(ii), basal_calories(ii));
end

fclose(fid);

%% Write out pruned sleep data

fprintf('%s - Writing out pruned sleep data\n', datetime)

fid = fopen('AppleWatchSleep.csv','w');

fprintf(fid,'Start Date/Time,End Date/Time,Duration (secs)\n');

for ii = 1:length(sleep_duration)
    fprintf(fid,'%s,%s,%1.0f\n', start_sleep_datetime(ii), end_sleep_datetime(ii), sleep_duration(ii));
end

fclose(fid);

%% Done

fprintf('%s - C''est fini\n', datetime)