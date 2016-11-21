%% this function plot how a given component influence some channels.
% it returns a plot (red) with the component and a plot (blue) without that
% component.
% Input are:
% - EEG : the EEG struct
% - channelnum: the channel to plot
% - compnums: the component toplot


function fig=comps_infl(EEG, channelnum, compnums)


figure()

for k=1:length(channelnum)
    EEGdata=reshape(EEG.data, size(EEG.data,1), size(EEG.data,2)*size(EEG.data,3));
    EEG.icaact=(EEG.icaweights*EEG.icasphere)*EEGdata;
    comp_to_retain=setdiff(1:size(EEG.icaweights,1), compnums);
    EEGdata2= EEG.icawinv(:,comp_to_retain)*EEG.icaact(comp_to_retain,:);
    EEGdata2=reshape(EEGdata2, size(EEG.data,1), size(EEG.data,2),size(EEG.data,3));
    ERPpru=mean(EEGdata2(channelnum(k),:,:),3);
    ERP=mean(EEG.data(channelnum(k),:,:),3);
    subaxis(round((length(channelnum)/2)),2,k,'Spacing', 0.05, 'Padding', 0, 'Margin', 0.05, 'MarginTop', 0.1);
    plot(1:length(ERP), ERP,'r', 1:length(ERPpru),ERPpru,'b') %credo che sia fondamentale che subplot sia prima di plot nella stessa riga.
    
    baseline_points=round(EEG.xmin*10)*100 %quessta cosa strana di fare *10 dentro (e poi fuori) serve per approssimare x min a centesimi.
    step200=round(200*EEG.srate/1000)
    
    x_seq=200*EEG.srate/1000
    
    myticks=1:step200:length(ERP)
    mylabels=[EEG.xmin*1000:(200):(EEG.xmax*1000)]
    
    tickandlab=min([length(myticks) length(mylabels)] )
    % prendo il numero minimo calcolato tra tick e labls 
    % serve per evitare che riparta a scrivere le labels

    set(gca,'XLim', [0 length(ERP)])
    set(gca,'XTick', myticks(1:tickandlab))
    
    set(gca,'XTickLabel', mylabels(1:tickandlab)) 
    
    %axis([1,length(EEG.icaweights),min(miny),max(maxy)])
    title(EEG.chanlocs(channelnum(k)).labels, 'fontsize', 16)
end;
 % AGGIUNGI TITOLO GENERALE
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1, strcat('\bf PLOT WITH (RED) AND WITHOUT (BLUE) THE COMPONENTS: ', num2str(compnums)),...
        'HorizontalAlignment','center','VerticalAlignment', 'top')
    