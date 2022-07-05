function [TNPC,COE,LPSP,p,b,Nd,G,Pt_d,Pt_pv,Pt_wt]=MainProgramm(Npv , Nwt , Nb)
global Hr_D LPSP_num Pt_b                   %Hr_D is the working hours of diesel, LPSP_num is the numerator of LPSP, Pt_b is the battery contribution to energy 
Hr_D=0;  LPSP_num=0;   Pt_b=0;              % intializing Hr_D and LPSP_num and Pt_b;
loadprofile;                                %the load needed power per hour From Load Data
Pload=Pload*1000;                           %converting load profile values from MW to KW
Eload=Pload *1;                             %the load needed energy From Load Data
Energy=sum(Eload);                          %yearly load
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Wind turbine power program 
alpha=0.1;                                  %friction coefficient from (Spera, 1994).
Vreference;                                 %the reference speed per hour in 1 year path from Vreference path
href=10;                                    %the reference height
hWT=225;                                    %the height of wind turbine from google earth
Vci=3.1;                                    %the cut in speed for whisper 200   
Vr=13;                                      %the rated speed for whisper 200
Vco=18;                                    %the cut out speed for whisper 200 
Pr_wt=1;                                   %the rated power in kw for whisper 200 
V= Vref*(hWT/href).^alpha;                 %height correction for wind speed from Optimization of micro-grid system using MOPSO by Hanieh Borhanazad , Saad Mekhilef , Velappa Gounder Ganapathy ,Mostafa Modiri-Delshad , Ali Mirtaheri 
Pwt=zeros(1,8760);                         %the wind power initialize to zero before iteration (creating an array)
%the total power extracted by wind turbine in 1 year 
for t=1:length(V)                          %time iteration in hours
if V(t) < Vci || V(t) > Vco                %testing if the speed greater than cut out or less than cut in speed
        Pwt(t) = 0;                        %if yes the output power will be zero
else if V(t) > Vr && V(t) < Vco            %testing if the speed between cut in and rated speed
        Pwt(t) = Nwt*Pr_wt;                       %if yes the power will be the rated value of the turbine
    else                                   %if no calcuate the power in kw 
        Pwt(t)= Nwt*((0.10819*(V(t).^5)-4.6001*(V(t).^4)+72.416*(V(t).^3)-516.62*(V(t).^2)+1739.7*V(t)-2209.4)/1000); %using matlab curve fitting for whisper 200 power curve
        if Pwt(t)< 0                       %testing if the calculated wind power is less than zero 
           Pwt(t)=0;                       %if yes make the power value zero 
        end
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Pv power program
T_ref = 25;                                                       %the reference temperature 
S_ref = 1000;                                                     %reference value of solar irradiance
SolarPvdata;                                                      %the solar radiation and ambient temperature from solarPvdata path 
NOCT = 45;                                                        %normal operating cell temperature
P_pv_ref = 0.255;                                                 %rated output power of PV module
Kt = -3.7*10^(-3);                                                %temperature derating factor
Tc_t = zeros(1,8760);                                             %the temperature per hour initialize to zero before iteration (creating an array)
P_pv_t = zeros(1,8760);                                           %the Pv power per hour initialize to zero before iteration(creating an array)
%the total Pv power in 1 year
for t = 1 : length(S_t)                                           %time iteration in hours
    Tc_t(t) = T_amb(t) + ((NOCT - 20)/800)*S_t(t);                %calculating cell surface temperature
    P_pv_t(t) = Npv*P_pv_ref * (S_t(t)/S_ref)*(1+Kt*(Tc_t(t)-T_ref)); %the pv output power in KW
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the battery program
%E_load=365780;                                  %(E_load is the load demand per day)
S_bat = 0.15;                                    %the nominal battery bank capacity (KAh)
%AD = 3;                                         %autonomy days
DOD = 0.5;                                       %the depth of discharge 
eff_bat = 0.91;                                  %the battery efficiency
eff_c = 0.9;                                     %the converter efficiency
P_c=max(Eload)/eff_c;                            %Converter size
V_bat = 12;                                      %Voltage of the battery                                  
%E_bat =(E_load * AD)/(DOD*eff_bat*eff_c);       %capacity of battereis(Kwh)
%Nb = E_bat/(V_bat*S_bat);                        %number of batteries
%Nb = ceil (Nb);
Ebat_max =S_bat*Nb*V_bat*eff_bat;                        %the maximum battery capacity
Ebat_min =(1-DOD)*Ebat_max;                      %the minimum battery capacity
qt = zeros(1,8760);                              %the fuel consumption array 
Pt = zeros(1,8760);                              %the power of the generator array
Eb = zeros(1,8760);                              %the energy of the battery array
Edump = zeros (1,8760);                          %energy wasted in damp load
Eb(1) = Ebat_max;                                %the battery energy at first assume it is fully charged
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start checking for discharge or charge
Nd=50;                                                      %Number of diesel units
for t=1:8760                                                %time iteration in hours 
    Pg=(Pwt(t)+P_pv_t(t));                                   %the total generated power 
    Pgap = (Pload(t) / eff_c) - Pg;
         if  Pgap > 0                                        %if the load power greater than the generated power         
             [Eb,qt,Pt]=Discharge(Pwt(t),P_pv_t(t),t,Pload(t),Eb,eff_c,Ebat_min,qt,Pt);  %calling the function discharge 
         else                                                %if the generated power greater than the load power  
             [Edump,Eb]=Charge(Pwt(t),P_pv_t(t),Pload(t),Eb,t,eff_c,Ebat_max,Edump);     %calling the function charge(the inputs are )             
         end
end
Pt_wt = sum(Pwt);
Pt_pv = sum(P_pv_t);
Pt_d= sum(Pt);
LPSP=LPSP_num/(Energy/eff_c);
[TNPC,COE]=Cost(Npv,Nwt,qt,Energy,Ebat_max,P_c);
[G] = GHG (Pt_wt,Pt_pv,Pt_d);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data needed for pie chart plot
total_dump=sum(Edump);
F=Energy+total_dump;
A=100*Pt_wt/F;
B=100*Pt_pv/F;
C=100*Pt_d/F;
D=100*Pt_b/F;
p=[A,B,C,D];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Data needed for bar plot
Pb_wt=zeros(1,24);
Pb_pv=zeros(1,24);
Pb_d=zeros(1,24);
Pb_batteries=zeros(1,24);
Pb_dump=zeros(1,24);
Pb_load=zeros(1,24);
for i=5328:5351
    k=i-5327;
    Pb_wt(k)=Pwt(i);
    Pb_pv(k)=P_pv_t(i);
    Pb_d(k)=Pt(i);
    Pb_dump(k)=-1*Edump(i);
    Pb_load(k)=-1*Pload(i)/eff_c;
    Pb_batteries(k)=Eb(i)-Eb(i+1);
end
b= [Pb_load ; Pb_wt ; Pb_pv ; Pb_batteries ; Pb_d ; Pb_dump];
b=b';
end