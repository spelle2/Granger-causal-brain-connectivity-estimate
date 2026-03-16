function [granger_bi,granger_multi,granger_bi_multi,F_mvgc,p_val_b,p_val_m,p_val_bi_m]= modello(Wp,Wf, region1, region2, region3, region4, order,label, m_input,label2,value,da,fa)     
% calculate granger bivariate and multivariate
% WP excitatory synapses
% Wf inhib synapses
% region1,... rhythm the region is working in : theta,alpha,beta,gamma
% order order of the model
% label str for the region you wanna change the input noise
% m_input noise input to the pop
% label2 optional: various possible changes:
% 'length_signal','frequenza','delay','niente'
% value of the parameter you wanna change

window = 50;  
zeropadding = 1000; 

Npop = 4; % Number of ROIs
dt=0.0001;
f_eulero = 1/dt;
tend = 1 + 10;
t=(0:dt:tend);
N=length(t);



%% parameters definition
% different rhythms

e0 = 2.5; % Saturation value of the sigmoid
r = 0.56;  % Slope of the sigmoid(1/mV) 
s0 = 10;  % Center of the sigmoid
flag = 0;  % Parameter to set the working point in the central position

if (nargin>9) & (isequal(label2,'delay'))
    D=value*ones(1,Npop);
else
D=0.01*ones(1,Npop); % Delay between regions (10 ms)
end
G=[5.17 4.45 57.1];  % Synaptic gains

%  Beta Rhythm
% Connectivity constants
        C_vettore_val(1,1) = 54.; %Cep
        C_vettore_val(1,2) = 54.; %Cpe
        C_vettore_val(1,3) = 54.; %Csp
        C_vettore_val(1,4) = 67.5; %Cps  
        C_vettore_val(1,5) = 27.; %Cfs
        C_vettore_val(1,6) = 54.; %Cfp
        C_vettore_val(1,7) = 540.; %Cpf
        C_vettore_val(1,8) = 10.; %Cff
        a_vettore_val(1,:)=[68.5 30 300]; % Reciprocal of synaptic time constants (omega)       

        
%  Gamma Rhythm
% Connectivity constants
        C_vettore_val(2,1) = 54.; %Cep
        C_vettore_val(2,2) = 54.; %Cpe
        C_vettore_val(2,3) = 54.; %Csp
        C_vettore_val(2,4) = 67.5; %Cps   
        C_vettore_val(2,5) = 27.; %Cfs
        C_vettore_val(2,6) = 108.; %Cfp
        C_vettore_val(2,7) = 300.; %Cpf
        C_vettore_val(2,8) = 10.; %Cff
        a_vettore_val(2,:)=[125 30 400]; % Reciprocal of synaptic time constants (omega)  

        
%  Theta Rhythm 
% Connectivity constants
        C_vettore_val(3,1) = 54.; %Cep
        C_vettore_val(3,2) = 54.; %Cpe
        C_vettore_val(3,3) = 54.; %Csp
        C_vettore_val(3,4) = 67.5; %Cps   
        C_vettore_val(3,5) = 15.; %Cfs
        C_vettore_val(3,6) = 27.; %Cfp
        C_vettore_val(3,7) = 300.; %Cpf
        C_vettore_val(3,8) = 10.; %Cff
        a_vettore_val(3,:)=[75 30 300]; % Reciprocal of synaptic time constants (omega)  
        

%  Alpha Rhythm
% Connectivity constants
        C_vettore_val(4,1) = 54.; %Cep
        C_vettore_val(4,2) = 54.; %Cpe
        C_vettore_val(4,3) = 54.; %Csp
        C_vettore_val(4,4) = 450; %Cps   
        C_vettore_val(4,5) = 10.; %Cfs
        C_vettore_val(4,6) = 35.; %Cfp
        C_vettore_val(4,7) = 300.; %Cpf   
        C_vettore_val(4,8) = 25.; %Cff
        a_vettore_val(4,:)=[66 42 300]; % Reciprocal of synaptic time constants (omega) 
% mean value of the input noise to each ROI (through excitatory interneurons)
m = zeros(4,1);

%decide which region to take
        switch region1
    case 'alpha'
        % ROI: Alpha Rhythm
        C(1,:)=C_vettore_val(4,:);
        a(1,:)=a_vettore_val(4,:); % Reciprocal of synaptic time constants (omega)
        m(1)=250;
    case 'beta'
        % ROI 1: Beta Rhythm
        C(1,:) = C_vettore_val(1,:);
        a(1,:)=a_vettore_val(1,:); % Reciprocal of synaptic time constants (omega)       
        m(1)=400;
    case 'gamma'
        % ROI: Gamma Rhythm
         C(1,:) = C_vettore_val(2,:);
         a(1,:)=a_vettore_val(2,:); % Reciprocal of synaptic time constants (omega)
         m(1)=400;

    case 'theta'
         C(1,:) = C_vettore_val(3,:);
         a(1,:)=a_vettore_val(3,:); % Reciprocal of synaptic time constants (omega) 
         m(1)=400;
    end


        switch region2
    case 'alpha'
        % ROI: Alpha Rhythm
        C(2,:)=C_vettore_val(4,:);
        a(2,:)=a_vettore_val(4,:); % Reciprocal of synaptic time constants (omega)
        m(2)=250;
    case 'beta'
        % ROI 1: Beta Rhythm
        C(2,:) = C_vettore_val(1,:);
        a(2,:)=a_vettore_val(1,:); % Reciprocal of synaptic time constants (omega)       
        m(2)=400;
    case 'gamma'
        % ROI: Gamma Rhythm
         C(2,:) = C_vettore_val(2,:);
         a(2,:)=a_vettore_val(2,:); % Reciprocal of synaptic time constants (omega)  
        m(2)=400;
     case 'theta'
         C(2,:) = C_vettore_val(3,:);
         a(2,:)=a_vettore_val(3,:); % Reciprocal of synaptic time constants (omega) 
         m(2)=400;
     end


        switch region3
    case 'alpha'
        % ROI: Alpha Rhythm
        C(3,:)=C_vettore_val(4,:);
        a(3,:)=a_vettore_val(4,:); % Reciprocal of synaptic time constants (omega)
        m(1)=250;
    case 'beta'
        % ROI 1: Beta Rhythm
        C(3,:) = C_vettore_val(1,:);
        a(3,:)=a_vettore_val(1,:); % Reciprocal of synaptic time constants (omega)       
        m(3)=400;
    case 'gamma'
        % ROI: Gamma Rhythm
         C(3,:) = C_vettore_val(2,:);
         a(3,:)=a_vettore_val(2,:); % Reciprocal of synaptic time constants (omega)  
        m(3)=400;
            case 'theta'
         C(3,:) = C_vettore_val(3,:);
         a(3,:)=a_vettore_val(3,:); % Reciprocal of synaptic time constants (omega) 
        m(3)=400;
        end


        switch region4
    case 'alpha'
        % ROI: Alpha Rhythm
        C(4,:)=C_vettore_val(4,:);
        a(4,:)=a_vettore_val(4,:); % Reciprocal of synaptic time constants (omega)
        m(4)=250;
    case 'beta'
        % ROI 1: Beta Rhythm
        C(4,:) = C_vettore_val(1,:);
        a(4,:)=a_vettore_val(1,:); % Reciprocal of synaptic time constants (omega)       
        m(4)=400;
    case 'gamma'
        % ROI: Gamma Rhythm
         C(4,:) = C_vettore_val(2,:);
         a(4,:)=a_vettore_val(2,:); % Reciprocal of synaptic time constants (omega)  
        m(4)=400;
            case 'theta'
         C(4,:) = C_vettore_val(3,:);
         a(4,:)=a_vettore_val(3,:); % Reciprocal of synaptic time constants (omega) 
         m(4)=400;
        end
if nargin>7
    varia=str2num(label);
    m(varia)=m_input;
end

%%

start = 10000; 
step_red = 100;   % step reduction from 10000 to 100 Hz
fs = f_eulero/step_red;

% change freq of sampling if required
if (nargin>9) & (isequal(label2,'frequenza')) 
    step_red=start/value;
    fs=value;
end
%% simulate trial
Ntrial = 20;
Matrix_eeg_C = zeros(Npop,(N-1-start)/step_red,Ntrial);  % exclusion of the first second due to a possible transitory
tt=zeros(1,(N-1-start)/step_red);
for trial = 1: Ntrial
    
% defining equations of a single ROI
yp=zeros(Npop,N);
xp=zeros(Npop,N);
vp=zeros(Npop,1);
zp=zeros(Npop,N);
ye=zeros(Npop,N);
xe=zeros(Npop,N);
xinput=zeros(Npop,N);
yinput = zeros(Npop,N);
ve=zeros(Npop,1);
ze=zeros(Npop,N);
ys=zeros(Npop,N);
xs=zeros(Npop,N);
vs=zeros(Npop,1);
zs=zeros(Npop,N);
yf=zeros(Npop,N);
xf=zeros(Npop,N);
zf=zeros(Npop,N);
vf=zeros(Npop,1);
xl=zeros(Npop,N);
yl=zeros(Npop,N);

kmax=round(max(D)/dt);

% different seed for noise generation at each trial
rng(10+trial) 

sigma_p = sqrt(5/dt); % Standard deviation of the input noise to excitatory neurons
sigma_f = sqrt(5/dt); % Standard deviation of the input noise to inhibitory neurons
np = randn(Npop,N)*sigma_p; % Generation of the input noise to excitatory neurons
nf = randn(Npop,N)*sigma_f; % Generation of the input noise to inhibitory neurons

for k=1:N-1
   up1=np(:,k)+m; % input of exogenous contributions to excitatory neurons
   uf1=nf(:,k);  % input of exogenous contributions to inhibitory neurons

  up2 = zeros(Npop,1);
  uf2 = zeros(Npop,1);

    if(k>kmax)
        for i=1:Npop
            up2(i)=up2(i)+Wp(i,:)*zp(:,round(k-D(i)/dt));
            uf2(i)=uf2(i)+Wf(i,:)*zp(:,round(k-D(i)/dt));
        end
    end
 

    up = up1 + up2;
    uf = uf1 + uf2;
   
    % post-synaptic membrane potentials
    vp(:)=C(:,2).*ye(:,k)-C(:,4).*ys(:,k)-C(:,7).*yf(:,k);
    ve(:)=C(:,1).*yp(:,k);
    vs(:)=C(:,3).*yp(:,k);
    vf(:)=C(:,6).*yp(:,k)-C(:,5).*ys(:,k)-C(:,8).*yf(:,k)+yl(:,k);
    
    % average spike density
    zp(:,k)=2*e0./(1+exp(-r*(vp(:)-s0)))-flag*e0;
    ze(:,k)=2*e0./(1+exp(-r*(ve(:)-s0)))-flag*e0;
    zs(:,k)=2*e0./(1+exp(-r*(vs(:)-s0)))-flag*e0;
    zf(:,k)=2*e0./(1+exp(-r*(vf(:)-s0)))-flag*e0;
    
    
    % post synaptic potential for pyramidal neurons
    xp(:,k+1)=xp(:,k)+(G(1)*a(:,1).*zp(:,k)-2*a(:,1).*xp(:,k)-a(:,1).*a(:,1).*yp(:,k))*dt;  
    yp(:,k+1)=yp(:,k)+xp(:,k)*dt; 
    
    % post synaptic potential for excitatory interneurons
    xe(:,k+1)=xe(:,k)+(G(1)*a(:,1).*(ze(:,k)+up(:)./C(:,2))-2*a(:,1).*xe(:,k)-a(:,1).*a(:,1).*ye(:,k))*dt;  
    ye(:,k+1)=ye(:,k)+xe(:,k)*dt; 

    xinput(:,k+1)=xinput(:,k)+(G(1)*a(:,1).*up2(:)-2*a(:,1).*xinput(:,k)-a(:,1).*a(:,1).*yinput(:,k))*dt;  % con due popolazioni Xinput ha solo un contributo
    yinput(:,k+1)=yinput(:,k)+xinput(:,k)*dt;    %yinput contiene la variabile desiderata per le popolazioini 1 e 2
    
    % post synaptic potential for slow inhibitory interneurons
    xs(:,k+1)=xs(:,k)+(G(2)*a(:,2).*zs(:,k)-2*a(:,2).*xs(:,k)-a(:,2).*a(:,2).*ys(:,k))*dt;   
    ys(:,k+1)=ys(:,k)+xs(:,k)*dt; 
    
    % post synaptic potential for fast inhibitory interneurons
    xl(:,k+1)=xl(:,k)+(G(1)*a(:,1).*uf(:)-2*a(:,1).*xl(:,k)-a(:,1).*a(:,1).*yl(:,k))*dt;  
    yl(:,k+1)=yl(:,k)+xl(:,k)*dt; 
    xf(:,k+1)=xf(:,k)+(G(3)*a(:,3).*zf(:,k)-2*a(:,3).*xf(:,k)-a(:,3).*a(:,3).*yf(:,k))*dt;   
    yf(:,k+1)=yf(:,k)+xf(:,k)*dt; 

end

% low pass filter at 50 Hz before resampling at 100 Hz
Omp = 50/(f_eulero/2);
Oms = 60/(f_eulero/2);
Rp = 1;
Rs = 40;
[Nfilter, Omn] = ellipord(Omp, Oms, Rp, Rs);
[B,A] = ellip(Nfilter,Rp,Rs,Omn);

% different filter if the fs change
if (nargin>9) & (isequal(label2,'frequenza'))
Omp = (fs/2)/(f_eulero/2);
Oms = (fs/2+10)/(f_eulero/2);
Rp = 1;
Rs = 40;
[Nfilter, Omn] = ellipord(Omp, Oms, Rp, Rs);
[B,A] = ellip(Nfilter,Rp,Rs,Omn);
end


eeg_tot=diag(C(:,2))*ye-diag(C(:,4))*ys-diag(C(:,7))*yf;
for j = 1:Npop
eeg_tot(j,:) = filtfilt(B,A,eeg_tot(j,:));
yinput(j,:)= filtfilt(B,A,yinput(j,:));
yinput_in(j,:) = filtfilt(B,A, yl(j,:));
end
global eeg current_postsynaptic granger_dataset12 granger_dataset21 current_postsynaptic_in
eeg = eeg_tot(:,start:step_red:end);
current_postsynaptic = yinput(:,start:step_red:end);
current_postsynaptic_in=yinput_in(:,start:step_red:end);
zp_ridotto = zp(:,start:step_red:end);
t_res=t(start:step_red:end);
% Matrix extraction for corr, delayed corr, coh, lagged coh, phase sync and TE estimation
Matrix_eeg_C(:,:,trial) = eeg(:,1:end-1); % matrix dimension= n°ROI x Nsamples x nTrials
end
tt=t_res(1:end-1);

% Matrix extraction for temporal and spectral Granger Causality estimation
Data = []; % trails concatenated in column
for j = 1:Ntrial
Data = [Data Matrix_eeg_C(:,:,j)]; % matrix dimension= n°ROI x (Nsamples x nTrials)
end



%cut the signal into different length if requires
if (nargin>9) & (isequal(label2,'length_signal'))
    eeg=Matrix_eeg_C(:,1:(value*fs),:);
else
    eeg=Matrix_eeg_C;
end
for i=1:Ntrial
global eeg_no_norm
eeg_no_norm=eeg;
eeg=zscore(eeg,0,'all');
end
granger_dataset21=zscore(granger_dataset21,0,'all');
granger_dataset12=zscore(granger_dataset12,0,'all');
%% GRANGER bivariate
for i=1:Ntrial
inputs.nTrials=1;
inputs.freqResolution=0.1;
inputs.freq=0:0.1:250;
inputs.standardize=1;
inputs.flagFPE=false; %true
%order=15;
[granger_bi(:,:,i),p_val_b(:,:,i)] = granger_time_connectivity(squeeze(eeg(:,:,i)), order, inputs);

alpha=0.05;
mhtc='FDRD';
tstat     = 'F';
% Significance-test p-values, correcting for multiple hypotheses.
sig_S(:,:,i) = significance(squeeze(p_val_b(:,:,i)),alpha,mhtc);

dataset12 = [current_postsynaptic(2,:); zp_ridotto(1,:)];
dataset21 = [zp_ridotto(2,:); current_postsynaptic(1,:) ];

end


%% GRANGER multiavariate
regmode   = 'LWR';
tstat     = 'F';
alpha     = 0.05;
mhtc      = 'FDRD'; 

for i=1:Ntrial
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(squeeze(eeg(:,:,i)),order);
[A,SIG] = tsdata_to_var(squeeze(eeg(:,:,i)),order);
assert(~isbad(A),'VAR estimation failed - bailing out');
% check the VAR model for stability and symmetric
% positive-definite residuals covariance matrixassert(~info.error,'VAR error(s) found - bailing out');
info = var_info(A,SIG);
assert(~info.error,'VAR error(s) found - bailing out');

% Compute MVGc
[granger_multi(:,:,i),p_val_m(:,:,i)] = var_to_pwcgc(A,SIG,squeeze(eeg(:,:,i)),regmode,tstat);
% Check for failed GC calculation
assert(~isbad(granger_multi,false),'GC calculation failed - bailing out');
% Significance-test p-values, correcting for multiple hypotheses.
sig(:,:,i) = significance(squeeze(p_val_m(:,:,i)),alpha,mhtc);
end


%% GRANGER bi-multi

regmode   = 'LWR';
tstat     = 'F';
alpha     = 0.05;
mhtc      = 'FDRD'; 

for i=1:Ntrial
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(squeeze(eeg([2,1],:,i)),order);
[A,SIG] = tsdata_to_var(squeeze(eeg([2,1],:,i)),order);
assert(~isbad(A),'VAR estimation failed - bailing out');
% check the VAR model for stability and symmetric
% positive-definite residuals covariance matrixassert(~info.error,'VAR error(s) found - bailing out');
info = var_info(A,SIG);
assert(~info.error,'VAR error(s) found - bailing out');

% Compute MVGc
[granger_bi_multi(:,:,i),p_val_bi_m(:,:,i)] = var_to_pwcgc(A,SIG,squeeze(eeg([2,1],:,i)),regmode,tstat);
% Check for failed GC calculation
assert(~isbad(granger_multi,false),'GC calculation failed - bailing out');

end