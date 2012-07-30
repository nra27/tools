function adf_2_msh(adf,msh);
%
% adf_2_msh(adf,mesh)
% A script to translate a given hydra adf file
% to a fluent msh file

% Read hydra mesh
mesh = Read_Hydra_Grid(adf);

% Write fluent mesh
Write_Fluent(msh,mesh);