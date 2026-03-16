%% FIGURA
val_m=[0:200:3400];

str='γ->θ'
Wp  = [0 80 0 0   
      80 0 0 0   
      0 0 0 0   
      0 0 0 0]; 
  
Wi = [0 0 0 0  
      0 0 0 0  
      0 0 0 0   
      0 0 0 0]; 


ordine=[15];

granger_bi=[];
granger_multi=[];
for i =1:length(val_m)
        m_inp=val_m(i);
        [granger_bi(:,:,:,i),granger_multi(:,:,:,i)] = modello(Wp,Wi,'theta','gamma','theta','alpha', ordine,'2',m_inp);

end

    granger_bi_m=squeeze(mean(granger_bi,3));
    granger_m_m=squeeze(mean(granger_multi,3));
    granger_bi_std=squeeze(std(granger_bi,0,3));
    granger_m_std=squeeze(std(granger_multi,0,3));
h=figure('WindowState','maximized')
subplot(2,2,1)
errorbar(val_m,squeeze(granger_bi_m(1,2,:)),squeeze(granger_bi_std(1,2,:)),'b--o','LineWidth',3),hold on;
errorbar(val_m,squeeze(granger_m_m(1,2,:)),squeeze(granger_m_std(1,2,:)),'r--x','LineWidth',3)
errorbar(val_m,squeeze(granger_bi_m(2,1,:)),squeeze(granger_bi_std(2,1,:)),'--o','LineWidth',3,'Color',	'#EDB120'),hold on;
errorbar(val_m,squeeze(granger_m_m(2,1,:)),squeeze(granger_m_std(2,1,:)),'--x','LineWidth',3,'Color','#77AC30')
xlabel('m_p','FontSize',15),ylabel(strcat('G-causality'),'FontSize',15),legend('BS_γ__θ','MVGC_γ__θ','BS_θ__γ','MVGC_θ__γ','Location','northeast','FontSize',12)
title('Different input mean','FontSize',18,'FontWeight','bold')


