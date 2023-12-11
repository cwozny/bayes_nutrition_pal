clear all
close all
clc

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 20);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Var1", "Var2", "StartWeight", "StartGlucose", "StartKetones", "ActiveEnergy", "BasalEnergy", "Sleep", "NutritionEnergy", "TotalCarbs", "Protein", "TotalFats", "Sugar", "Fiber", "SugarAlcohols", "Bias", "EndWeight", "WeightDelta", "EndGlucose", "EndKetones"];
opts.SelectedVariableNames = ["StartWeight", "StartGlucose", "StartKetones", "ActiveEnergy", "BasalEnergy", "Sleep", "NutritionEnergy", "TotalCarbs", "Protein", "TotalFats", "Sugar", "Fiber", "SugarAlcohols", "Bias", "EndWeight", "WeightDelta", "EndGlucose", "EndKetones"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Var1", "Var2"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var2"], "EmptyFieldRule", "auto");

% Import the data
data = readtable("AggregatedData.csv", opts);

%% Clear temporary variables
clear opts