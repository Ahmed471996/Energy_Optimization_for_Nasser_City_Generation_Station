function[Eb,qt,Pt] = Discharge(Pwt,P_pv_t,t,Pload,Eb,eff_c,Ebat_min,qt,Pt) %recieving the value of the Pv and wind power hourly
 global Hr_D LPSP_num Pt_b
Pdch = (Pload / eff_c) - (Pwt + P_pv_t);     %calculating the discharge power (make up the gap power between the load power and generated power)
     Edch = Pdch * 1 ;                         %discharge energy calculation(the same as the power value because we work hourly)
     if (Eb(t) - Ebat_min >= Edch)             %testing if the energy in the battery greater than the required energy for making up the power   
         Eb(t+1) = Eb(t) - Edch;               %if yes discharge the energy from the battery
         Pt(t)=0;                              %we make the Eb as array because we want to draw the relation to know the change of energy of the battery over the year
         qt(t)=0; 
         Pt_b=Pt_b+(Eb(t)-Eb(t+1));
     else
          Hr_D=Hr_D+1;
          Eb(t+1) = Ebat_min ;                %if not make the new battery energy the minimum possible value and use the diesel generator power to make up for the required power
          Pt_b=Pt_b+(Eb(t)-Eb(t+1));
          Pr=15;                              %the rated power of the diesel generator in kw 
          Pt(t)=Edch-(Eb(t)-Ebat_min);        %output %the power of the generator to make up for the load power in kw(note that this formula with line 10 means that we will make the battery will dischare the rest energy)
          if Pt(t)>750
                Pt(t)=750;
          end
          a=0.246;                            %constant from Optimization of micro-grid system using MOPSO
          b=0.08415;                          %constant from Optimization of micro-grid system using MOPSO
          qt(t)=a*Pt(t)+b*Pr;                 %calculate the fuel consmption in L/hour
          LPSP_num=LPSP_num+((Pload/eff_c)-(Pwt+P_pv_t+Pt(t)+(Eb(t)-Ebat_min)));
     end
end