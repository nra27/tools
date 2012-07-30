%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Patch Creator                      %
%                         v1.0                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Author: sss44, nra27              %
%                   Last mod: 26/3/2011                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Input: block structure (b)       %
%                     Output: block structure (b)       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            ______
            _\ _~-\___
    =  = ==(____AA____D
                \_____\___________________,-~~~~~~~`-.._
                /     o O o o o o O O o o o o o o O o  |\_
                `~-.__        ___..----..  Whittle Air     )
                      `---~~\___________/------------`````
                      =  ===(_________D



Notes: Patch data for patches 1 and 2 set here.
       Requires cavity_calibration.m
       Order of patch points:
               1-----2
               |     |
               |     |
               4-----3

%} 

%%
function [b]=create_patch(b)
%% NUMBER OF BLOCKS
N=length(b);
%% INITIALIZE STUFF
b(1).NUM_PATCH=2*ones(N,1);
IS_SET=zeros(N,4);
%% CALIBRATE PIXEL DATA
b=cavity_calibration(b);

%% WRITE BLOCK COORDINATES
for i=1:N
   
% CARD 14-22
%            X                            RT                                       R
b(i).XI1J1K1 = b(i).x(4);   b(i).RTI1J1K1 = b(i).r(4)*0;                     b(i).RI1J1K1 = b(i).r(4);
b(i).XI1JMK1 = b(i).x(1);   b(i).RTI1JMK1 = b(i).r(1)*0;                     b(i).RI1JMK1 = b(i).r(1);
b(i).XI1JMKM = b(i).x(1);   b(i).RTI1JMKM = b(i).r(1)*2*pi/b(1).sector;      b(i).RI1JMKM = b(i).r(1);
b(i).XI1J1KM = b(i).x(4);   b(i).RTI1J1KM = b(i).r(4)*2*pi/b(1).sector;      b(i).RI1J1KM = b(i).r(4);

b(i).XIMJ1K1 = b(i).x(3);   b(i).RTIMJ1K1 = b(i).r(3)*0;                     b(i).RIMJ1K1 = b(i).r(3);
b(i).XIMJMK1 = b(i).x(2);   b(i).RTIMJMK1 = b(i).r(2)*0;                     b(i).RIMJMK1 = b(i).r(2);
b(i).XIMJMKM = b(i).x(2);   b(i).RTIMJMKM = b(i).r(2)*2*pi/b(1).sector;      b(i).RIMJMKM = b(i).r(2);
b(i).XIMJ1KM = b(i).x(3);   b(i).RTIMJ1KM = b(i).r(3)*2*pi/b(1).sector;      b(i).RIMJ1KM = b(i).r(3);


end
%% CREATE PATCHES 1 AND 2 FOR ALL THE BLOCKS

for i = 1:N,
% CARD 10
b(i).INTYPE = 1; b(i).NSMOOTH  = 0; b(i).NMATCH  = 1; b(i).IFISMTH = 0; b(i).IFJSMTH = 0; b(i).IFKSMTH = 0; b(i).IFCUSP = 0; b(i).NBLADES = 1;
% CARD 11
b(i).NI = 10; b(i).NJ = 10; b(i).NK = 10;
% CARD 47
b(i).NPATCH = 2;
% CARD 42
b(i).SCALE = 1; b(i).XMOVE = 0; b(i).RMOVE = 0; b(i).RTMOVE = 0;
% CARD 43-45
b(i).FIRAT = 1; b(i).FIMAX = 1; b(i).FIEND = 1; b(i).FJRAT = 1; b(i).FJMAX = 1; b(i).FJEND = 1; b(i).FKRAT = 1; b(i).FKMAX = 1; b(i).FKEND = 1;
%
% Data for the 2 automatic meridional periodics
%
% CARD 48B
b(i).PATCHTITLE(1) = {'PERIODIC - FRONT'}; b(i).PATCHTITLE(2) = {'PERIODIC - REAR'};
% CARD 49
b(i).PATCHTYPE(1) = 'P'; b(i).PATCHTYPE(2) = 'P';
% CARD 50
b(i).MATCH_TYPE = 0; b(i).NMATCH_ON = 0; b(i).NMATCH_OFF = 0; b(i).IFPSMOOTH = 0; b(i).FRACSHIFT = 1;   % INDEX ALL
% CARD 51 - PATCH 1
b(i).IPATCHS(1) = 1; b(i).IPATCHE(1) = b(i).NI; b(i).JPATCHS(1) = 1; b(i).JPATCHE(1) = b(i).NJ; b(i).KPATCHS(1) = b(i).NK; b(i).KPATCHE(1) = b(i).NK;
% CARD 51 - PATCH 2
b(i).IPATCHS(2) = 1; b(i).IPATCHE(2) = b(i).NI; b(i).JPATCHS(2) = 1; b(i).JPATCHE(2) = b(i).NJ; b(i).KPATCHS(2) = 1; b(i).KPATCHE(2) = 1;%^%^%^#$^%$^$ FIX!!!!!!
% CARD 57
b(i).NEXTI =  '+I'; b(i).NEXTJ = '+J'; b(i).NEXTK = '+K'; b(i).NPASSAGE_SHIFT = 0; b(i).INT_TYPE = 0; b(i).NPINTERP = 0;

b(i).NEXTBLOCK(1) = i; b(i).NEXTBLOCK(2) = i;
b(i).NEXTPATCH(1) = 2; b(i).NEXTPATCH(2) = 1;

end


%% MATCH BLOCKS AND CREATE REQUIRED PATCHES
% initialize jj
for i=1:N 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A NORTH FACE MATCHES WITH A SOUTH, EAST OR WEST FACE
    if IS_SET(i,1)~=1
        % pts 1,2
        for ii=1:N
            %%%%%%%%%%%%%%%%            
            if b(i).x(1)==b(ii).x(4) && b(i).x(2)==b(ii).x(3) && b(i).r(1)==b(ii).r(4) && b(i).r(2)==b(ii).r(3)  % CHECK SOUTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_north(b, 3, IS_SET, i, ii);
                [b, IS_SET]=match_south(b, 1, IS_SET, ii, i);                
                
                break
            end
            %%%%%%%%%%%%%%%%            
            if b(i).x(1)==b(ii).x(3) && b(i).x(2)==b(ii).x(2) && b(i).r(1)==b(ii).r(3) && b(i).r(2)==b(ii).r(2)  % CHECK EAST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_north(b, 2, IS_SET, i, ii);
                [b, IS_SET]=match_east(b, 1, IS_SET, ii, i);                
             
                break
            end
            %%%%%%%%%%%%%%%%           
            if b(i).x(1)==b(ii).x(1) && b(i).x(2)==b(ii).x(4) && b(i).r(1)==b(ii).r(1) && b(i).r(2)==b(ii).r(4)  % CHECK WEST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_north(b, 4, IS_SET, i, ii);
                [b, IS_SET]=match_west(b, 1, IS_SET, ii, i);                              
                
                break
            end
            %%%%%%%%%%%%%%%%            
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% AN EAST FACE MATCHES WITH A NORTH, SOUTH OR WEST FACE
    if IS_SET(i,2)~=1
        % pts 2,3
        for ii=1:N
            %%%%%%%%%%%%%%%%            
            if b(i).x(2)==b(ii).x(2) && b(i).x(3)==b(ii).x(1) && b(i).r(2)==b(ii).r(2) && b(i).r(3)==b(ii).r(1) % CHECK NORTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_east(b, 1, IS_SET, i, ii);
                [b, IS_SET]=match_north(b, 2, IS_SET, ii, i);
                
                break
            end
            %%%%%%%%%%%%%%%%
            if b(i).x(2)==b(ii).x(4) && b(i).x(3)==b(ii).x(3) && b(i).r(2)==b(ii).r(4) && b(i).r(3)==b(ii).r(3) % CHECK SOUTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_east(b, 3, IS_SET, i, ii);
                [b, IS_SET]=match_south(b, 2, IS_SET, ii, i);               
                
                break
            end
            %%%%%%%%%%%%%%%% 
            if b(i).x(2)==b(ii).x(1) && b(i).x(3)==b(ii).x(4) && b(i).r(2)==b(ii).r(1) && b(i).r(3)==b(ii).r(4) % CHECK WEST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_east(b, 4, IS_SET, i, ii);
                [b, IS_SET]=match_west(b, 2, IS_SET, ii, i);                
                
                break
            end
            %%%%%%%%%%%%%%%%             
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A SOUTH FACE MATCHES WITH A NORTH, EAST OR WEST FACE
    if IS_SET(i,3)~=1
        % pts 3,4
        for ii=1:N
            %%%%%%%%%%%%%%%%
            if b(i).x(3)==b(ii).x(2) && b(i).x(4)==b(ii).x(1) && b(i).r(3)==b(ii).r(2) && b(i).r(4)==b(ii).r(1) % CHECK NORTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i); 
                
                [b, IS_SET]=match_south(b, 1, IS_SET, i, ii);
                [b, IS_SET]=match_north(b, 3, IS_SET, ii, i);               
                
                break
            end
            %%%%%%%%%%%%%%%%
            if b(i).x(3)==b(ii).x(3) && b(i).x(4)==b(ii).x(2) && b(i).r(3)==b(ii).r(3) && b(i).r(4)==b(ii).r(2) % CHECK EAST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i); 
                
                [b, IS_SET]=match_south(b, 2, IS_SET, i, ii);
                [b, IS_SET]=match_east(b, 3, IS_SET, ii, i);              
                
                break
            end
            %%%%%%%%%%%%%%%%
            if b(i).x(3)==b(ii).x(1) && b(i).x(4)==b(ii).x(4) && b(i).r(3)==b(ii).r(1) && b(i).r(4)==b(ii).r(4) % CHECK WEST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i); 
                
                [b, IS_SET]=match_south(b, 4, IS_SET, i, ii);
                [b, IS_SET]=match_west(b, 3, IS_SET, ii, i);               
                
                break
            end
            %%%%%%%%%%%%%%%%            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A WEST FACE MATCHES WITH AN NORTH, EAST OR SOUTH FACE
    if IS_SET(i,4)~=1
        % pts 4,1
        for ii=1:N
            %%%%%%%%%%%%%%%%             
            if b(i).x(4)==b(ii).x(2) && b(i).x(1)==b(ii).x(1) && b(i).r(4)==b(ii).r(2) && b(i).r(1)==b(ii).r(1) % CHECK NORTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_west(b, 1, IS_SET, i, ii);
                [b, IS_SET]=match_north(b, 4, IS_SET, ii, i);                
                
                break
            end
            %%%%%%%%%%%%%%%%             
            if b(i).x(4)==b(ii).x(3) && b(i).x(1)==b(ii).x(2) && b(i).r(4)==b(ii).r(3) && b(i).r(1)==b(ii).r(2) % CHECK EAST
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_west(b, 2, IS_SET, i, ii);
                [b, IS_SET]=match_east(b, 4, IS_SET, ii, i);                
                
                break
            end
            %%%%%%%%%%%%%%%% 
            if b(i).x(4)==b(ii).x(4) && b(i).x(1)==b(ii).x(3) && b(i).r(4)==b(ii).r(4) && b(i).r(1)==b(ii).r(3) % CHECK SOUTH
                b(1).NUM_PATCH(i)=b(1).NUM_PATCH(i)+1;
                b(1).NUM_PATCH(ii)=b(1).NUM_PATCH(ii)+1;
                
                b(i).NEXTBLOCK(b(1).NUM_PATCH(i)) = ii;
                b(i).NEXTPATCH(b(1).NUM_PATCH(i)) = b(1).NUM_PATCH(ii);

                b(ii).NEXTBLOCK(b(1).NUM_PATCH(ii)) = i;
                b(ii).NEXTPATCH(b(1).NUM_PATCH(ii)) = b(1).NUM_PATCH(i);
                
                [b, IS_SET]=match_west(b, 3, IS_SET, i, ii);
                [b, IS_SET]=match_south(b, 4, IS_SET, ii, i);                
                
                break
            end
            %%%%%%%%%%%%%%%%             
        end
    end
    %%
end
    b(1).IS_SET=IS_SET;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %% DRAW FIGURE AFTER POINT MATCHING

        B = imread([b(1).imgpathname,b(1).imgfilename]);
        imagesc(B);
        axis equal
        hold on 
        set(gcf, 'Position', get(0,'Screensize')); % maximize figure

        N=length(b);
        for i=1:N
        % Pixels

        plot(b(i).px_x(1),b(i).px_r(1),'o')
        plot(b(i).px_x(2),b(i).px_r(2),'o')
        plot(b(i).px_x(3),b(i).px_r(3),'o')
        plot(b(i).px_x(4),b(i).px_r(4),'o')
            % NORTH FACE            
            if b(1).IS_SET(i,1)==1;
            plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)],'-r')
            else
            plot([b(i).px_x(1) b(i).px_x(2)] , [b(i).px_r(1),b(i).px_r(2)])
            end

            % EAST FACE
            if b(1).IS_SET(i,2)==1;
            plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)],'-r')
            else 
            plot([b(i).px_x(2) b(i).px_x(3)] , [b(i).px_r(2),b(i).px_r(3)])   
            end

            % SOUTH FACE
            if b(1).IS_SET(i,3)==1;
            plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)],'-r')
            else
            plot([b(i).px_x(3) b(i).px_x(4)] , [b(i).px_r(3),b(i).px_r(4)])
            end

            % WEST FACE
            if b(1).IS_SET(i,4)==1;
            plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)],'-r')
            else
            plot([b(i).px_x(4) b(i).px_x(1)] , [b(i).px_r(4),b(i).px_r(1)])
            end

        text(mean(b(i).px_x),mean(b(i).px_r),num2str(i),'fontsize',14,'color','red','fontweight','bold');


        if i==N
        title('Block layout and patches. Patches marked in red. Press any key to continue.','fontsize',14,'color','black','fontweight','bold')
        pause
        end
        end
        close all

%%
%
% Data for the additional patches
%


b(1).exists=1;

for i = 1:N,
  
   b(i).NPATCH=b(1).NUM_PATCH(i);
    
%
% Rotation data
%

% CARD 59
b(i).RPMBLOCK = 0; b(i).FMGRID = 0.4; b(i).XLLIM = 0.03; b(i).NSMALL_BLOCK = 3; b(i).NBIG_BLOCK = 9; b(i).ITRANS = 1; b(i). JTRANS = 1; b(i).KTRANS = 1; b(i).FREE_TURB = 0; b(i).XLLIM_FREE = 0.1; b(i).IF_NOSHEAR = 0; b(i).MIXL_TYPE = 3;

% CARD 60
b(i).RPMI1 = 0; b(i).RPMIM = 0; b(i).RPMJ1 = 0; b(i).RPMJM = 0; b(i).RPMK1 = 0; b(i).RPMKM = 0;

end

b(1).patch_match_is_run=1;

end