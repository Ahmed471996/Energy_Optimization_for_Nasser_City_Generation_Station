function [G] = GHG (Pt_wt,Pt_pv,Pt_d)
global Pt_b
G_wt=0.00735;                            %Kg per KWh
G_pv=0.005;
G_b=0.028;
G_d=0.88;
G= G_wt*Pt_wt + G_pv*Pt_pv + G_b*Pt_b +G_d*Pt_d ;       %Kg per year      
end