%% Clear everything out

clc

fprintf('%s - Clearing everything out\n', datetime)

close all
clearvars

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["StartPeriod", "EndPeriod", "Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20"];
opts.SelectedVariableNames = ["StartPeriod", "EndPeriod"];
opts.VariableTypes = ["datetime", "datetime", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var3", "Var4", "Var5", "Var6", "Var7", "Var8", "Var9", "Var10", "Var11", "Var12", "Var13", "Var14", "Var15", "Var16", "Var17", "Var18", "Var19", "Var20"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "StartPeriod", "InputFormat", "dd-MMM-yyyy HH:mm:ss");
opts = setvaropts(opts, "EndPeriod", "InputFormat", "dd-MMM-yyyy HH:mm:ss");

% Import the data
PeriodData = readtable("AggregatedData.csv", opts);
PeriodData = PeriodData{:,:}; % turn in to datetime matrix

%% Clear temporary variables
clear opts

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "Var2", "StartWeightlbs", "StartFastingGlucosemgdL", "StartFastingKetonesmmolL", "ActiveEnergycal", "BasalEnergycal", "Sleepsec", "NutritionEnergycal", "TotalCarbsg", "Proteing", "TotalFatsg", "Sugarg", "Fiberg", "SugarAlcoholsg", "Bias", "EndWeightlbs", "WeightDifferencelbs", "EndFastingGlucosemgdL", "EndFastingKetonesmmolL"];
opts.SelectedVariableNames = ["StartWeightlbs", "StartFastingGlucosemgdL", "StartFastingKetonesmmolL", "ActiveEnergycal", "BasalEnergycal", "Sleepsec", "NutritionEnergycal", "TotalCarbsg", "Proteing", "TotalFatsg", "Sugarg", "Fiberg", "SugarAlcoholsg", "Bias", "EndWeightlbs", "WeightDifferencelbs", "EndFastingGlucosemgdL", "EndFastingKetonesmmolL"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var2"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2"], "EmptyFieldRule", "auto");

% Import the data
AggregatedData = readtable("AggregatedData.csv", opts);

%% Convert to output type
AggregatedData = table2array(AggregatedData);

%% Clear temporary variables
clear opts

%% Compute a linear regression model and cross-validate with k-folds

features = {"StartWt";     %  1 
            "Glucose";     %  2
            "Ketones";     %  3
            "ActEnrg";     %  4
            "BslEnrg";     %  5
            "Sleep  ";     %  6
            "NutrCal";     %  7
            "TotCarb";     %  8
            "Protein";     %  9
            "TotFats";     % 10
            "Sugar  ";     % 11
            "Fiber  ";     % 12
            "SugAlc ";     % 13
            "Bias   ";     % 14
            "EndWeight ";  % 15
            "WeightDiff";  % 16
            "Glucose   ";  % 17
            "Ketones   "}; % 18

K = 10;
N = length(AggregatedData);

%% Linear regression with unnormalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=ABSOLUTE\tNORMALIZATION=FALSE\tBIAS=FALSE ****\n\n")

inp = [1:5 7:13];
outp = [15 17:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with unnormalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=DELTA\tNORMALIZATION=FALSE\tBIAS=FALSE ****\n\n")

inp = [2:5 7:13];
outp = [16:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with unnormalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=BOTH\tNORMALIZATION=FALSE\tBIAS=FALSE ****\n\n")

inp = [1:5 7:13];
outp = [15:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with unnormalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=ABSOLUTE\tNORMALIZATION=FALSE\tBIAS=TRUE ****\n\n")

inp = [1:5 7:14];
outp = [15 17:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with unnormalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=DELTA\tNORMALIZATION=FALSE\tBIAS=TRUE ****\n\n")

inp = [2:5 7:14];
outp = [16:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with unnormalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=BOTH\tNORMALIZATION=FALSE\tBIAS=TRUE ****\n\n")

inp = [1:5 7:14];
outp = [15:18];

x = AggregatedData(:,inp);
y = AggregatedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Normalize data

% features
NormalizedData(:,1) = AggregatedData(:,1) / 230; % starting weight
NormalizedData(:,2) = AggregatedData(:,2) / 110; % blood glucose
NormalizedData(:,3) = AggregatedData(:,3) / 5; % ketones
NormalizedData(:,4) = AggregatedData(:,4) / 2000; % active energy
NormalizedData(:,5) = AggregatedData(:,5) / 2500; % basal energy
NormalizedData(:,6) = AggregatedData(:,6) / 35000; % sleep
NormalizedData(:,7) = AggregatedData(:,7) / 6500; % calories
NormalizedData(:,8) = AggregatedData(:,8) / 400; % total carbs 
NormalizedData(:,9) = AggregatedData(:,9) / 350; % protein
NormalizedData(:,10) = AggregatedData(:,10) / 450; % total fats
NormalizedData(:,11) = AggregatedData(:,11) / 175; % sugar
NormalizedData(:,12) = AggregatedData(:,12) / 125; % fiber
NormalizedData(:,13) = AggregatedData(:,13) / 125; % sugar alcohols
NormalizedData(:,14) = AggregatedData(:,14); % bias term doesn't need to be normalized

% targets
NormalizedData(:,15) = AggregatedData(:,15) / 230; % end weight
NormalizedData(:,16) = AggregatedData(:,16) / 10; % weight difference
NormalizedData(:,17) = AggregatedData(:,17) / 110; % blood glucose
NormalizedData(:,18) = AggregatedData(:,18) / 5; % ketones

%% Linear regression with normalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=ABSOLUTE\tNORMALIZATION=TRUE\tBIAS=FALSE ****\n\n")

inp = [1:5 7:13];
outp = [15 17:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with normalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=DELTA\tNORMALIZATION=TRUE\tBIAS=FALSE ****\n\n")

inp = [2:5 7:13];
outp = [16:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with normalized data and no bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=BOTH\tNORMALIZATION=TRUE\tBIAS=FALSE ****\n\n")

inp = [1:5 7:13];
outp = [15:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with normalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=ABSOLUTE\tNORMALIZATION=TRUE\tBIAS=TRUE ****\n\n")

inp = [1:5 7:14];
outp = [15 17:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with normalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=DELTA\tNORMALIZATION=TRUE\tBIAS=TRUE ****\n\n")

inp = [2:5 7:14];
outp = [16:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);

%% Linear regression with normalized data and bias term

fprintf("**** LINEAR REGRESSION\tTARGET WEIGHT=BOTH\tNORMALIZATION=TRUE\tBIAS=TRUE ****\n\n")

inp = [1:5 7:14];
outp = [15:18];

x = NormalizedData(:,inp);
y = NormalizedData(:,outp);

[b,mae,rmse,mse] = LinearRegressionWithKFolds(x, y, K, features(inp), features(outp), false);