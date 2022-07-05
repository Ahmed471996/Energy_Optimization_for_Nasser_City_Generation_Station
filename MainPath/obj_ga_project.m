function cost=obj_ga_project(x)

global Npv Nwt Nb % identfiy your variables as global    

persistent call

if isempty(call)
     disp('Initialization  ...');
     call=1;  
end
Npv=(x(1)); 
Nwt=(x(2));
Nb=(x(3));

[TNPC,COE,LPSP,p,b,Nd,G,Pt_d,Pt_pv,Pt_wt]=MainProgramm(Npv , Nwt , Nb);
nerr =  (COE);

%nerr =  0.01*norm (GHG)+ 1000*norm(price_electricity);
%nerr =  norm (GHG);

cost1=nerr;
%cost1=cost(1)+cost(2);
if cost1>1e6,
    
    cost = 1e6; % penlaizing bad solution
else
    cost =cost1;% optimize overshoot, rise time, etc, control effort, pole location, etc.
end



return
