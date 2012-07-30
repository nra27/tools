%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Tblockdset.dat Writer                  %
%                         v1.1                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: nra27                     %
%                   Last mod: 23/3/2011, sss44          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: -                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                                ____
                                               /  / |
                                              /  /  |
                 |      /========____________/  /__ |
                 |_____/____|___|                    >
                <|          |         G-ATPX ____====-
                 |\         |        ____----
                 | \________|____----
                   ^          ^
                   O          O



version hist:
v 1.1:
- removed patch matching - this is done in the create_patch.m file
- 
%}

function tblockdset_ts_write(b)



% CARD 6
NBLOCKIN = length(b);

block_list = 1:NBLOCKIN;

% 
% PER BLOCK DATA (must be set for each)
%



%
% ------------------- OPEN FILE AND WRITE THE PREAMBLE ---------------------
%

% Open the file 
fid = fopen('tblockdset.dat','wt');

% CARD 1
TITLE = 'TITLE';
fprintf(fid,'%s \n',TITLE)

% CARD 2
CP = 1005; GAM = 1.4;
fprintf(fid,'%4.1f  %4.1f \n',CP, GAM)

% CARD 3
CFL = 0.2;
fprintf(fid,'%3.2f \n',CFL)

% CARD 4
NSTEPS = 500; NCHANGE = 500; NSTEPUP = 5; IFRESTART = 0; IFCHECK = 1; IF_DTS = 0;
fprintf(fid,'%3.0f %3.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f \n',NSTEPS,NCHANGE,NSTEPUP,IFRESTART,IFCHECK,IF_DTS)

% CARD 5
DAMP = 5; SFAC = 0.005; FACSEC = 0.8; SUPERFAC = 0.25; TEMP = 1;
fprintf(fid,'%2.0f %2.3f %2.1f %2.2f %1.0f \n',DAMP, SFAC, FACSEC, SUPERFAC,TEMP)

%
% Solver data
%

% CARD 62
ILOS = 9; NLOS = 5; NSETVIS = 1; REYNO = 200000; RFMIX = 0; YPLUSW = 0; RFVIS = 0.2; PRANDTL = 1;

% CARD 6
fprintf(fid,'%1.0f %1.0f \n',NBLOCKIN, NBLOCKIN)

%
% ------------------- WRITE THE BLOCK AND PATCH DATA ---------------------
%

for i = 1:NBLOCKIN,
    
    % Block preamble
    fprintf(fid,'%s \n','C ===========================')
    fprintf(fid,'%s %0.0f %s \n','BLOCK',block_list(i),'- BLOCK TITLE')
    fprintf(fid,'%s \n','C ===========================')
    fprintf(fid,'%1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %1.0f %2.0f \n',b(i).INTYPE, b(i).NSMOOTH, b(i).NMATCH, b(i).IFISMTH, b(i).IFJSMTH, b(i).IFKSMTH, b(i).IFCUSP,b(i).NBLADES)
    fprintf(fid,'%2.0f %2.0f %2.0f \n',b(i).NI,b(i).NJ,b(i).NK)
    
    % 8 Block corners
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XI1J1K1,b(i).RTI1J1K1,b(i).RI1J1K1)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XI1JMK1,b(i).RTI1JMK1,b(i).RI1JMK1)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XI1JMKM,b(i).RTI1JMKM,b(i).RI1JMKM)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XI1J1KM,b(i).RTI1J1KM,b(i).RI1J1KM)
    
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XIMJ1K1,b(i).RTIMJ1K1,b(i).RIMJ1K1)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XIMJMK1,b(i).RTIMJMK1,b(i).RIMJMK1)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XIMJMKM,b(i).RTIMJMKM,b(i).RIMJMKM)
    fprintf(fid,'%10.8f %10.8f %10.8f \n',b(i).XIMJ1KM,b(i).RTIMJ1KM,b(i).RIMJ1KM)
    
    % Rotate and move
    fprintf(fid,'%s \n','C = Scale and move ')
    fprintf(fid,'%2.1f %2.1f %2.1f %2.1f \n',b(i).SCALE, b(i).XMOVE, b(i).RMOVE, b(i).RTMOVE)
    
    % Grid spacing
    fprintf(fid,'%s \n','C = Grid spacing')
    fprintf(fid,'%2.2f %2.2f %2.2f \n', b(i).FIRAT, b(i).FIMAX, b(i).FIEND)
    fprintf(fid,'%2.2f %2.2f %2.2f \n', b(i).FJRAT, b(i).FJMAX, b(i).FJEND)
    fprintf(fid,'%2.2f %2.2f %2.2f \n', b(i).FKRAT, b(i).FKMAX, b(i).FKEND)
    
    fprintf(fid,'%s \n','C ===========================')
    fprintf(fid,'%1.0f % s \n',b(i).NPATCH,'PATCH(ES)')
    
    %
    % Automatically write the 2 meridional periodics
    %
    for j = 1:b(i).NPATCH,
        % CARD 48 A-C
        fprintf(fid,'%s \n','C ===========================')
        fprintf(fid,'%s%1.0f%s%1.0f%s %s \n','(' , block_list(i), ',', j, ') -', b(i).PATCHTITLE{j})
        fprintf(fid,'%s \n','C ===========================')
        
        % CARD 49
        fprintf(fid,'%s \n', b(i).PATCHTYPE(j))
        
        % CARD 50
        fprintf(fid,'%2.0f %2.0f %2.0f %2.0f %2.0f \n',b(i).MATCH_TYPE,b(i).NMATCH_ON,b(i).NMATCH_OFF,b(i).IFPSMOOTH,b(i).FRACSHIFT)
                   
       % CARD 51
       fprintf(fid,'%2.0f %2.0f %2.0f %2.0f %2.0f %2.0f \n',b(i).IPATCHS(j), b(i).IPATCHE(j), b(i).JPATCHS(j), b(i).JPATCHE(j), b(i).KPATCHS(j), b(i).KPATCHE(j)) %%%%%%%!!!!!!!!!! FIX!!!!
            
        if b(i).PATCHTYPE(j) == 'P'
            
  
            % CARD 57
            %fprintf(fid,'%2.0f %2.0f %s %s %s %2.0f %2.0f %2.0f %2.0f \n',b(i).NEXTBLOCK, b(i).NEXTPATCH, b(i).NEXTI, b(i).NEXTJ, b(i).NEXTK, b(i).NBLADES, b(i).NPASSAGE_SHIFT, b(i).INT_TYPE, b(i).NPINTERP)
            fprintf(fid,'%2.0f %2.0f %s %s %s \n',b(i).NEXTBLOCK(j), b(i).NEXTPATCH(j), b(i).NEXTI, b(i).NEXTJ, b(i).NEXTK)
            
        elseif b(i).PATCHTYPE(j) == 'I'
            
            % CARD 53
            fprintf(fid,'%2.0f %2.0f %2.0f \n',b(i).NPIN, b(i).IFRELIN, b(i).RFIN) 
            
            % CARD 56
            fprintf(fid,'%5.2f %5.2f %5.2f %5.2f %5.2f %5.2f\n',b(i).FRAC, b(i).POIN, b(i).TOIN, b(i).YAW, b(i).PITCH) 
            
        elseif b(i).PATCHTYPE(j) == 'E'
            
            % CARD 55
            fprintf(fid,'%2.0f %2.0f %2.0f %2.0f \n',b(i).NPOUT, b(i).I_EXBCS, b(i).IPOUT, 0.1) 
            
            % CARD 56
            fprintf(fid,'%5.2f %5.2f \n',b(i).FRAC_E, b(i).POUT) 

        end
            
    end
    
    % CARD 58
    fprintf(fid,'%s \n','C ===========================')
    
    % CARD 59
    fprintf(fid,'%2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f \n',b(i).RPMBLOCK, b(i).FMGRID, b(i).XLLIM, b(i).NSMALL_BLOCK, b(i).NBIG_BLOCK,b(i).ITRANS,b(i).JTRANS, b(i).KTRANS, b(i).FREE_TURB, b(i).XLLIM_FREE, b(i).IF_NOSHEAR,b(i).MIXL_TYPE)
    
    % CARD 60
    fprintf(fid,'%2.0f %2.0f %2.0f %2.0f %2.0f %2.0f \n',b(i).RPMI1, b(i).RPMIM, b(i).RPMJ1, b(i).RPMJM, b(i).RPMK1, b(i).RPMKM)
    
    % CARD 61A
    fprintf(fid,'%s \n','C ===========================')
    
end

%
% Write the loss model data and then the initial guess 
%

% CARD 61
fprintf(fid,'%s \n','C ===========================')

% CARD 62
fprintf(fid,'%2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f %2.0f \n',ILOS, NLOS, NSETVIS, REYNO, RFMIX, YPLUSW, RFVIS, PRANDTL)

% CARD 66
fprintf(fid,'%s \n','C ===========================')

for i = 1:NBLOCKIN,
    
    % CARD 67
    fprintf(fid,'%s \n','K')
    
    % CARD 68
    fprintf(fid,'%3.0f %5.0f %5.0f \n',100,1100000,500)
    
    % CARD 69
    fprintf(fid,'%3.0f %5.0f %5.0f \n',100,1100000,500)

end


end    
    