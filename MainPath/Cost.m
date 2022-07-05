function [TNPC,COE]=Cost(Npv,Nwt,qt,Energy,Ebat_max,P_c)
%Cint:initial cost in $/KW
%Com:operation and maintenance cost in $/KW/year
%Crep:replacement cost in $/KW
%N:system lifetime 
global Hr_D
Pr_wt=1; Pr_pv=0.255;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=20;
int=0.1675;                                %interest rate
inf=0.08665;                                %inflation rate
CRF=(int*((1+int)^N))/(((1+int)^N)-1);     %capital recovery factor
x=(1+inf)/(1+int);                         %just to make writing of PWF and RF easier
PWF=x*((1-x^N)/(1-x));                     %present worth of maintenance factor
RF=x^N;                                    %replacement factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%wind cost
Ci_wt=2000;                       %intial cost 
Cint_wt=Ci_wt*Nwt*Pr_wt;          %total intial cost(Nwt is the number of turbine units)
Com_wt=60*Nwt*Pr_wt;              %opration and maintance cost
Crep_wt=0;                        %replacement cost(assume we will not have to replace it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pv cost
Ci_pv=405;                        %intial cost 
Cint_pv=Ci_pv*Npv*Pr_pv;          %total intial cost
Com_pv=0.01*Cint_pv;            %value of maintanance in $/Kw/year
Crep_pv=0;                        %replacement cost(assume we will not have to replace it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%diesel cost
total_fuel = sum (qt);
Nd=50;
Pr_d=15;
Ci_d=1000;                                                             %intial cost of diesel
GSP=5000;                                                              %generator set price
ASC =(Hr_D*GSP)/250;                                                 %annual service cost of the generator
Cint_d=Ci_d*Nd*Pr_d;                                                   %total intial cost(Nd is the number of generator units)
LRSC=ASC*((1+inf)/(int-inf))*(1-((1+inf)/(1+int))^N);                  %maintance cost
Com_d=total_fuel*0.8717*PWF+LRSC;                                          %opration and maintance cost(0.8717 is the fuel price per L)                     
Crep_d=0;                                                              %replacement cost(assume we will not have to replace it)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%battery cost
Ci_b=135;                                     %intial cost of battery
Cint_b=Ci_b*Ebat_max;                         %total intial cost
Com_b=0;                                      %opration and maintance cost
Crep_b=Cint_b*(x^10);                         %replacement cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Converter cost
Ci_c=1300/15;                                  %initial cost of converter
Cint_c=Ci_c*P_c;                               %total initial cost
Com_c=(5/15)*P_c;                              %operation and maintance cost
Cr_c=1000/15;                                  %initial replacment cost
Crep_c=Cr_c*P_c*(x^10);                        %total replacment cost
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%annual cost of each component
annual_cost_wind= Cint_wt+Com_wt*PWF+Crep_wt*RF;
annual_cost_pv= Cint_pv+Com_pv*PWF+Crep_pv*RF;
annual_cost_diesel= Cint_d+Com_d*PWF+Crep_d*RF;
annual_cost_batteries= Cint_b+Com_b*PWF+Crep_b*RF;
annual_cost_converter= Cint_c+Com_c*PWF+Crep_c*RF;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%total annual cost
annual_cost= CRF*(annual_cost_wind + annual_cost_pv + annual_cost_diesel + annual_cost_batteries + annual_cost_converter);
TNPC= annual_cost/CRF;
COE=annual_cost/Energy;      %cost of energy
end