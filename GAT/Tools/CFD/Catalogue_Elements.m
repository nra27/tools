function [D,element_types,bnd_element_types,error_return] = Catalogue_Elements(ID,D);
%
% function [D,element_types,bnd_element_types,error_return] = Catalogue_Elements(ID,D)
%
% A function to return a string which contains the element types found in the mesh.
% Valid values in element_types are:
% t - tetrahedra
% s - square based piramid
% h - hexahedra
% p - triangular prism
% Valid values in bnd_element_types are:
% t - triangle
% q - quadrilateral

% Get children names
[D,number_of_children,error_return] = ADF_Number_of_Children(ID,D);
[D,number_of_children,children_names,error_return] = ADF_Children_Names(ID,1,number_of_children,D.ADF_Label_Length,D);

element_types = ' ';
bnd_element_types = ' ';

for i = 1:number_of_children
    if ~isempty(findstr(children_names{i},'hex-->node'))
        element_types(end+1) = 'h';
    elseif ~isempty(findstr(children_names{i},'tet-->node'))
        element_types(end+1) = 't';
    elseif ~isempty(findstr(children_names{i},'pri-->node'))
        element_types(end+1) = 'p';
    elseif ~isempty(findstr(children_names{i},'pyr-->node'))
        element_types(end+1) = 's';
    elseif ~isempty(findstr(children_names{i},'bnd_tri-->node'))
        bnd_element_types(end+1) = 't';
    elseif ~isempty(findstr(children_names{i},'bnd_quad-->node'))
        bnd_element_types(end+1) = 'q';
    end
end