function[Edump,Eb]=Charge(Pwt,P_pv_t,Pload,Eb,t,eff_c,Ebat_max,Edump)
Pch =  (Pwt + P_pv_t) - (Pload / eff_c);  %calculating the charge power (the over power from wind and Pv)
Ech = Pch * 1 ;                           %charge energy calculation(the same as the power value because we work hourly)
if  Ech <= Ebat_max - Eb(t)               %testing if the over energy less than or equal the empity part of the battery 
    Eb(t+1) = Eb(t) + Ech;                %if yes charge the battery with all energy u have
    Edump(t)=0;                           %in this condition there is no waste energy 
else                                      %there was a condition that we will not need testing if there will be waste energy and that is impossible to happen because we already tested it at first
    Eb(t+1) = Ebat_max ;                  %telling the program if the energy greater than the empity part charge to maximum value only
    Edump(t) = Ech - ( Ebat_max - Eb(t)); %in this condtion there is waste energy and we will calculate its value
end
end
