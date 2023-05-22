
M = readmatrix('D:\Usman Daudu\Documents\Engr Micheal\water_potability');
N = rmmissing(M);

filename = "ControlFit.txt";

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
        sys = tfest(N(:,1:end-1),N(:,end),i);

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
        sys = tfest(N(:,5:end-1),N(:,end),bestpole,j);

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