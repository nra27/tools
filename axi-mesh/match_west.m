%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      MATCH WEST                       %
%                         v1.1                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44                     %
%                   Last mod: 23/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                             WHICH_FACE?               %
%                             IS_SET?                   %
%                             current block number (i)  %
%                             matching block number (ii)%
%                     Output: block structure (b)       %
%                             IS_SET?                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                           __/\__
                          `==/\==`
                ____________/__\____________
               /____________________________\
                 __||__||__/.--.\__||__||__
                /__|___|___( >< )___|___|__\
                          _/`--`\_
                         (/------\)

version hist:
ver 1.1 - corrected patch indexing.

%} 

%%
function [b, IS_SET]=match_west(b, WHICH_FACE, IS_SET, i, ii)
%%

if WHICH_FACE==1
   FACE='NORTH'; 
elseif WHICH_FACE==2
   FACE='EAST';    
elseif WHICH_FACE==3
   FACE='SOUTH';    
elseif WHICH_FACE==4
   FACE='WEST';    
end

                IS_SET(i,4)=1;
                b(i).PATCHTITLE(b(1).NUM_PATCH(i)) = {['PERIODIC - WEST - MATCHES WITH ',FACE,' ON BLOCK ', num2str(ii)]};
                b(i).PATCHTYPE(b(1).NUM_PATCH(i)) = 'P';
                b(i).IPATCHS(b(1).NUM_PATCH(i)) = 1; 
                b(i).IPATCHE(b(1).NUM_PATCH(i)) = 1; 
                b(i).JPATCHS(b(1).NUM_PATCH(i)) = 1; 
                b(i).JPATCHE(b(1).NUM_PATCH(i)) = b(i).NJ; 
                b(i).KPATCHS(b(1).NUM_PATCH(i)) = 1; 
                b(i).KPATCHE(b(1).NUM_PATCH(i)) = b(i).NK; 


end