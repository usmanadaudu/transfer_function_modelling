
M = readmatrix('D:\Usman Daudu\Documents\Engr Micheal\water_potability');
N = rmmissing(M);

pot = N(:,end) == 1;        %Get idices of samples that are potable
potdata = N(pot,:);         %Get indices of samples that are not potable

notPot = N(:,end) == 0;     %Get samples that are potable
notPotdata = N(notPot,:);   %Get samples that re not potable

%Combine the first 50 potable samples and the first 50 samples that are not
%potable
dataset = [potdata(1:50,:); notPotdata(1:50,:)];

%Run the code 5 times with different arrangements
BestSys(5) = struct('tfunc',0);
for seed = 1:5

    %% Split Dataset into Training and Validation Sets
    
    training_size = 0.75;
    rng(seed)
    shuffle = randperm(size(dataset,1));
    
    train = dataset(shuffle(1:floor(training_size*length(dataset))),:);
    train(:,1:end-1) = normalize(train(:,1:end-1));
    
    val = dataset(shuffle(ceil(training_size*length(dataset)):end),:);
    val(:,1:end-1) = normalize(val(:,1:end-1));
    
    %% Search for Best Pole and Zeros to Estimate Transfer Function
    
    filename = "ControlFit" + num2str(seed) + ".txt";
    
    bestfit = 0;
    bestpole = -1;
    bestzero = -1;
    bestFPE = -1;
    bestMSE = -1;
    
    startpole = 1;
    endpole = 5;
    
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
    
    BestSys(i).tfunc = tfest(train(:,1:end-1),train(:,end),bestpole,bestzero);
    
    figure();
    compare(val(:,1:end-1),val(:,end),BestSys(i).tfunc)
end
