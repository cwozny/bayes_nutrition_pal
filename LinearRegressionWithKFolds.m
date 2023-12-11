function [b,mae,rmse,mse] = LinearRegressionWithKFolds(x,y,K,features,targets)

    n = size(x,1);

    partition = randi(K,n,1);

    for k = 1:K
        train = partition ~= k;
        test = partition == k;

        x_train = x(train,:);
        y_train = y(train,:);

        x_test = x(test,:);
        y_test = y(test,:);

        b(k,:,:) = x_train\y_train;

        y_pred = x_test*squeeze(b(k,:,:));

        y_delta = y_pred - y_test;

        mae(k) = mean(vecnorm(y_delta,1,2));
        rmse(k) = mean(vecnorm(y_delta,2,2));
        mse(k) = mean(vecnorm(y_delta,2,2).^2);
    end

    for k = 1:K

        fprintf("K = %d\tMAE = %f\tRMSE = %f\tMSE = %f\n", k, mae(k), rmse(k), mse(k))

        fprintf("Inp/Out\t")

        for c = 1:length(targets)
            fprintf("\t%s", targets{c})
        end

        fprintf("\n")

        for r = 1:length(features)
            fprintf("%s\t", features{r})
            for c = 1:length(targets)
                fprintf("\t%1.7f", b(k,r,c))
            end
            fprintf("\n")
        end

        fprintf("\n")
    end

    med_b = squeeze(median(b));

    y_pred = x_test*med_b;

    y_delta = y_pred - y_test;

    med_mae = mean(vecnorm(y_delta,1,2));
    med_rmse = mean(vecnorm(y_delta,2,2));
    med_mse = mean(vecnorm(y_delta,2,2).^2);

    fprintf("MED\tMAE = %f\tRMSE = %f\tMSE = %f\n", med_mae, med_rmse, med_mse)
end