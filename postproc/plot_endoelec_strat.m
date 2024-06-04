function cc = plot_endoelec_strat(strat1_tot, strat2_tot, estrat,  scen,...
    lambdas, lambda_e, b, assum, model, T, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, Fi, Q_const, voteModel, sigma)
% Figure Name
    lbname = strcat(num2str(round(lambdas(1)*100)));
    lgname = strcat(num2str(round(lambdas(2)*100)));
    if strcmp('coghi',model)
        figname = strcat(sprintf('%s',model),'_', 'lb', lbname, 'lg', lgname, sprintf('_T%0.0f.pdf',T));

    else
        figname = strcat(sprintf('%s',model),'_',sprintf('%s',assum),'lb',  lbname, 'lg', lgname, sprintf('_T%0.0f.pdf',T));
    end
% Start Figure    
    fig=figure;
    ColorSet = bwcolor(length(lambda_e));
    S_C = linspace(0,1,20);
    D_C = [0 linspace(D_C_min, D_C_max, D)/C];
    strat1_tot = zeros(49,20, 10, length(lambda_e));
    strat2_tot = zeros(49,20, 10, length(lambda_e));
    strat1 = zeros(20,10,length(lambda_e));
    strat2 = zeros(20,10,length(lambda_e));
    for ii=1:length(lambda_e)
        subplot('Position', [ 0.15 .48 .5 .465])
        scenario = [lambda_e(ii) lambdas];
        index = find_index(scen,scenario)
        prefstrats = preferred_strategies(50, C, D_C_min, D_C_max, D, F, ...
            Q_const, lambdas, [0 1], 1, estrat);
        if strcmp('ar1',model)
        strat1(:,:,ii) = strat_ar1op( C, D_C_min, D_C_max, D, strat1_tot(:,:,:,:,index), prefstrats(:,:,:,2), estrat, ...
            F,  voteModel, [lambda_e(ii) b .5],T);
        strat2(:,:,ii) = strat_ar1op( C, D_C_min, D_C_max, D, strat2_tot(:,:,:,:,index), prefstrats(:,:,:,1), estrat, ...
            F,  voteModel, [lambda_e(ii) b .5],T);
        else 
            [strat1_tot(:,:,:,ii) strat2_tot(:,:,:,ii) VV1 VV2] = optimize_nolimit(50, 50, C, D_C_min, D_C_max, D, P_f_min, P_f_max, F, ...
                                                  Q_const, lambdas, [0 1], [.05 .05], 1, 4, 'coghi', ...
                                                  voteModel, [lambda_e(ii) .5], estrat, prefstrats, sigma, 2) ;  %D_C(strat1_tot(T,:,:,index));
            %strat2(:,:,ii) = %D_C(strat2_tot(T,:,:,index));
        end
        strat1(:,:,ii) = D_C(strat1_tot(T,:,:,ii));
        strat2(:,:,ii) = D_C(strat2_tot(T,:,:,ii));
        plot(S_C(1:20), strat1(:,5,ii), 'Color', ColorSet(ii,:))
        hold on
        plot(S_C(1:20), strat2(:,5,ii), 'Color', ColorSet(ii,:))
        plot(S_C(1:20), D_C(prefstrats(T,:,5,1)), 'k-.')
        plot(S_C(1:20), D_C(prefstrats(T,:,5,2)), 'k-.')
        plot(S_C(1:20), D_C(estrat(T,:,5)), 'k-.')
        xlabel('Renewable energy share (s)')
        ylabel('Investment (q)')
    end
    for ii=1:length(lambda_e)
        subplot('Position',[0.1 .05 .25 .33]) 

        s_e = S_C(1:20) + D_C(reshape(estrat(4,:,Fi), [1 20]));
        B_strat = S_C(1:20) + reshape(strat1(:,Fi,ii), [1 20]);
        G_strat = S_C(1:20) + reshape(strat2(:,Fi,ii), [1 20]);
        if strcmp('as2',assum)
            prob_incumb_B = election(voteModel, true, B_strat, s_e, ...
                s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
            prob_incumb_G = election(voteModel, true, G_strat, s_e, ...
                s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
            
        elseif strcmp('coghi', model)
            
                prob_incumb_B = election(voteModel, true, B_strat, G_strat, ...
                    s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
                prob_incumb_G = election(voteModel, true, G_strat, B_strat, ...
                    s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
        else
            
                B_other = S_C(1:20) + D_C(reshape(prefstrats(4,:,Fi,1), [1 20]));
                G_other = S_C(1:20) + D_C(reshape(prefstrats(4,:,Fi,2), [1 20]));
                prob_incumb_B = election(voteModel, true, B_strat, G_other, ...
                    s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
                prob_incumb_G = election(voteModel, true, G_strat, B_other, ...
                    s_e, [lambda_e(ii) b], D_C_min, D_C_max, C);
        end
        
        plot(S_C(1:20),prob_incumb_B, 'Color', ColorSet(ii,:))
        hold on
        xlabel('Renewable energy share (s)')
        ylabel('prob_B')
        subplot('Position',[0.5 .05 .25 .355])
        plot(S_C(1:20),prob_incumb_G, 'Color', ColorSet(ii,:))
        hold on
        xlabel('Renewable energy share (s)')
        ylabel('prob_G')
    end
    set(gcf,'NextPlot','add');
    axes;
    set(gca,'Visible','off');
    h=colorbar('EastOutside')
    caxis([min(lambda_e) max(lambda_e)])
    set(gcf, 'Colormap', ColorSet);
    title(h,'\lambda_e')
    tightfig(fig)
    print('-dpdf', strcat('results/RetrospectiveModel/retrospective/',figname))
   