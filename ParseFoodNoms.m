%% Clear everything out

clc

fprintf('%s - Clearing everything out\n', datetime)

close all
clearvars

%% Get file from user

fprintf('%s - Getting filename from user\n', datetime)

[file,path] = uigetfile('FoodNoms Food Log.csv');

if isequal(file,0)
   disp('User selected Cancel');
end

%% Read in food data

fprintf('%s - Reading in food data from %s\n', datetime, fullfile(path,file))

food_datetime = [];
food_calories = [];
total_carbs = [];
protein = [];
total_fat = [];
sugar = [];
fiber = [];
sugar_alcohols = [];

fid = fopen(fullfile(path,file),'r');

line = fgetl(fid); % skip header line

while ~feof(fid)
    line = fgetl(fid);
    tokens = strrep(split(line,'","'),"""",'');

    dateStr = strrep(tokens{1},"""",'');
    timeStr = strrep(tokens{2},"""",'');
    timeStr = strrep(timeStr,char(8239),' ');
    
    food_datetime = [food_datetime; datetime(char(dateStr + ' ' + timeStr))];
    food_calories = [food_calories; str2double(tokens{9})];
    total_carbs = [total_carbs; str2double(tokens{10})];
    protein = [protein; str2double(tokens{11})];
    total_fat = [total_fat; str2double(tokens{12})];
    sugar = [sugar; str2double(tokens{16})];
    fiber = [fiber; str2double(tokens{17})];
    sugar_alcohols = [sugar_alcohols; str2double(tokens{18})];
end

fclose(fid);

%% Plot energy data

fprintf('%s - Plotting energy data\n', datetime)

figure
plot(food_datetime, food_calories, '.')
grid on

figure
plot(food_datetime, total_carbs, '.')
hold on
plot(food_datetime, protein, '.')
plot(food_datetime, total_fat, '.')
plot(food_datetime, sugar, '.')
plot(food_datetime, fiber, '.')
plot(food_datetime, sugar_alcohols, '.')
grid on
legend('Total Carbs','Protein','Total Fat','Sugar','Fiber','Sugar Alcohols')

%% Write out pruned data

fprintf('%s - Writing out pruned data\n', datetime)

fid = fopen('FoodNomsPrunedData.csv','w');

fprintf(fid,'Date/Time,Calories (cal),Total Carbs (g),Protein (g),Total Fat (g),Sugar (g),Fiber(g),Sugar Alcohols (g)\n');

for ii = 1:length(food_datetime)
    fprintf(fid,'%s,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f,%1.1f\n', food_datetime(ii), food_calories(ii), total_carbs(ii), protein(ii), total_fat(ii), sugar(ii), fiber(ii), sugar_alcohols(ii));
end

fclose(fid);

%% Done

fprintf('%s - C''est fini\n', datetime)