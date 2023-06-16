%% Import Dataset and Filter Out Samples with Missing Values

M = readmatrix('D:\Usman Daudu\Documents\Engr Micheal\water_potability');
N = rmmissing(M);

%% Split Dataset into Training and Validation Sets

training_size = 0.75;
rng(123)
shuffle = randperm(size(N,1));

train = N(shuffle(1:floor(training_size*length(N))),:);
train(:,1:end-1) = normalize(train(:,1:end-1));

val = N(shuffle(ceil(training_size*length(N)):end),:);
val(:,1:end-1) = normalize(val(:,1:end-1));

%% Search for Best Pole and Zeros to Estimate Transfer Function

filename = "ControlFit.txt";

bestfit = 0;
bestpole = -1;
bestzero = -1;
bestFPE = -1;
bestMSE = -1;

startpole = 1;
endpole = 15;

fid = fopen(filename,"w");
if fid ~= -1
    fprintf(fid,"GETTING THE BEST NO. OF POLE\n");
    fprintf(fid,"----------------------------\n\n");

    fprintf(fid,"Pole  Fit    FPE     MSE  \n");

    for i = startpole:endpole
        sys = tfest(train(:,1:end-1),train(:,end),i);

        if sys.Report.Fit.FitPercent > bestfit
            bestpole = i;
            bestfit = sys.Report.Fit.FitPercent;
            bestFPE = sys.Report.Fit.FPE;
            bestMSE = sys.Report.Fit.MSE;
        end

        if sys.Report.Fit.FitPercent < 10
            fprintf(fid," %2d   %1.2f %1.5f %1.5f\n",i,...
                sys.Report.Fit.FitPercent,sys.Report.Fit.FPE,...
                sys.Report.Fit.MSE);
        else
            fprintf(fid," %2d  %02.2f %1.5f %1.5f\n",i,...
                sys.Report.Fit.FitPercent,sys.Report.Fit.FPE,...
                sys.Report.Fit.MSE);
        end
    end

    fprintf(fid,"\nThe best pole is %d\n\n\n",bestpole);

    fprintf(fid,"GETTING THE BEST NO. OF ZERO FOR BEST POLE\n");
    fprintf(fid,"------------------------------------------\n\n");

    fprintf(fid,"Pole Zero  Fit    FPE     MSE  \n");

    for j = 0:bestpole
        sys = tfest(train(:,1:end-1),train(:,end),bestpole,j);

        if sys.Report.Fit.FitPercent >= bestfit
            bestzero = j;
            bestfit = sys.Report.Fit.FitPercent;
            bestFPE = sys.Report.Fit.FPE;
            bestMSE = sys.Report.Fit.MSE;
        end

        if sys.Report.Fit.FitPercent < 10
            fprintf(fid," %2d   %2d   %1.2f %1.5f %1.5f\n",bestpole,j,...
                sys.Report.Fit.FitPercent,sys.Report.Fit.FPE,...
                sys.Report.Fit.MSE);
        else
            fprintf(fid," %2d   %2d  %2.2f %1.5f %1.5f\n",bestpole,j,...
                sys.Report.Fit.FitPercent,sys.Report.Fit.FPE,...
                sys.Report.Fit.MSE);
        end
    end

    fprintf(fid,"\nThe best zero for best pole is %d\n\n\n",bestzero);

    fprintf(fid,"\nThe best pole is %d and the best zero for this pole"+...
        " is %d. The resulting system has %2.2f fit to parameters "+...
        "with FPE of %1.5f and MSE of %1.5f.\n\n\n",bestpole,bestzero,...
        bestfit,bestFPE,bestMSE);

    fileclose = fclose(fid);

    fopen(filename);
end

%% Model Validation

BestSys = tfest(train(:,1:end-1),train(:,end),bestpole,bestzero);

figure();
compare(val(:,1:end-1),val(:,end),BestSys)
