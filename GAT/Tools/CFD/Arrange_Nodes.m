function order = Arrange_Nodes(nodes,edges,element);
%
% order = Arrange_Nodes(nodes,edges,element)
% A function to arrange the nodes for a given element into
% the patern that interpolate_element needs.
% 
% nodes is an array of node numbers and node coordinates [n,x,y,z]
% edges is an array of node numbers [n1 n2]
% element is the type of element being worked on

% Find number of edges
[n_edges,m_edges] = size(edges);
clear m_edges;

switch element
case {'quad'}
    % Build element-->edges array
    blocks = floor(n_edges/1000000);
    offset = rem(n_edges,1000000);
    
    d_edges = 0;
    if blocks > 0
        for count = 1:blocks
            check = zeros(1000000,8);
            for n_nodes = 1:4
                check(:,n_nodes) = edges([1:1000000]+(count-1)*1000000,1) == nodes(n_nodes,1);
                check(:,n_nodes+4) = edges([1:1000000]+(count-1)*1000000,2) == nodes(n_nodes,1);
            end
            check = sum(check,2);
            f_edges = find(check == 2)';
            if ~isempty(f_edges)
                f_edges = f_edges+(count-1)*1000000;
                edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
                d_edges = d_edges+length(f_edges);
            end
        end
    end
    check = zeros(offset,8);
    for n_nodes = 1:4
        check(:,n_nodes) = edges([1:offset]+blocks*1000000,1) == nodes(n_nodes,1);
        check(:,n_nodes+4) = edges([1:offset]+blocks*1000000,2) == nodes(n_nodes,1);
    end
    check = sum(check,2);
    f_edges = find(check == 2)';
    if ~isempty(f_edges)
        f_edges = f_edges+blocks*1000000;
        edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
        d_edges = d_edges+length(f_edges);
    end
    
    edges = edges(edge,:);
    clear edge
    
    % For the quad, node 1 will be the node with the smallest distance from the origin
    order = zeros(1,4);
    % Re-label nodes in edges
    new_edges = edges*0;
    for node = 1:4
        new_edges(find(edges == nodes(node,1))) = node;
    end
    edges = new_edges;
    
    % Cartesian distances are
    d2 = nodes(:,2).^2+nodes(:,3).^2+nodes(:,4).^2;
    [min_d2,i_d2] = min(d2);
    order(1) = i_d2;
    
    % Calculate the edge lengths
    for edge = 1:4
        edge_lengths(edge) = sqrt((nodes(edges(edge,1),2)-nodes(edges(edge,2),2))^2 ...
            +(nodes(edges(edge,1),3)-nodes(edges(edge,2),3))^2+(nodes(edges(edge,1),4)-nodes(edges(edge,2),4))^2);
    end
    
    % Node 2 will be the node on the shortest edge from Node 1. 
    point_edges = find(edges == order(1));
    point_edges = rem(point_edges,4);
    point_edges = point_edges.*(point_edges ~= 0)+4*(point_edges == 0);
    [min_edge_length,min_edge] = min(edge_lengths(point_edges));
    order(2) = edges(point_edges(min_edge),find(edges(point_edges(min_edge),:) ~= order(1)));
    
    % Node 3 will be the node connected to Node 2 that isn't Node 1!
    point_edges = find(edges == order(2));
    point_edges = rem(point_edges,4);
    point_edges = point_edges.*(point_edges ~= 0)+4*(point_edges == 0);
    order(3) = edges(point_edges(1),find(edges(point_edges(1),:) ~= order(2)));
    if order(3) == order(1)
        order(3) = edges(point_edges(2),find(edges(point_edges(2),:) ~= order(2)));
    end
    
    % Node 4 is the node which is connected to Node 3 and isn't Node 2
    point_edges = find(edges == order(3));
    point_edges = rem(point_edges,4);
    point_edges = point_edges.*(point_edges ~= 0)+4*(point_edges == 0);
    order(4) = edges(point_edges(1),find(edges(point_edges(1),:) ~= order(3)));
    if order(4) == order(2)
        order(4) = edges(point_edges(2),find(edges(point_edges(2),:) ~= order(3)));
    end
    
case {'piramid'}
    % For the square based pirmaid, we put the 'point' at 5 and
    % then the other elements are 1-4.        
    
    % Build element-->edges array
    blocks = floor(n_edges/1000000);
    offset = rem(n_edges,1000000);
    
    d_edges = 0;
    if blocks > 0
        for count = 1:blocks
            check = zeros(1000000,10);
            for n_nodes = 1:5
                check(:,n_nodes) = edges([1:1000000]+(count-1)*1000000,1) == nodes(n_nodes,1);
                check(:,n_nodes+5) = edges([1:1000000]+(count-1)*1000000,2) == nodes(n_nodes,1);
            end
            check = sum(check,2);
            f_edges = find(check == 2)';
            if ~isempty(f_edges)
                f_edges = f_edges+(count-1)*1000000;
                edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
                d_edges = d_edges+length(f_edges);
            end
        end
    end
    check = zeros(offset,10);
    for n_nodes = 1:5
        check(:,n_nodes) = edges([1:offset]+blocks*1000000,1) == nodes(n_nodes,1);
        check(:,n_nodes+5) = edges([1:offset]+blocks*1000000,2) == nodes(n_nodes,1);
    end
    check = sum(check,2);
    f_edges = find(check == 2)';
    if ~isempty(f_edges)
        f_edges = f_edges+blocks*1000000;
        edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
        d_edges = d_edges+length(f_edges);
    end
    
    edges = edges(edge,:);
    clear edge
    
    order = zeros(1,5);
    
    % Find which node has 4 edges and re-label
    for node = 1:5
        edge_count(node) = sum(sum(edges == nodes(node)));
        edges = node*(edges == nodes(node)) + edges.*(edges ~= nodes(node));
    end
    
    order(5) = find(edge_count == 4);
    
    % Calculate the edge lengths
    for edge = 1:8
        edge_lengths(edge) = sqrt((nodes(edges(edge,1),2)-nodes(edges(edge,2),2))^2 ...
            +(nodes(edges(edge,1),3)-nodes(edges(edge,2),3))^2+(nodes(edges(edge,1),4)-nodes(edges(edge,2),4))^2);
    end
    
    % For the edges with node 5, find the longest.  This will become node 1
    point_edges = find(edges == order(5));
    point_edges = rem(point_edges,8);
    point_edges = point_edges.*(point_edges ~= 0)+8*(point_edges == 0);
    [max_edge_length,max_edge] = max(edge_lengths(point_edges));
    order(1) = edges(point_edges(max_edge),find(edges(point_edges(max_edge),:) ~= order(5)));
    edge_length(point_edges) = 0;
    
    % For the this node, find the longest edge.  This will become node 2
    point_edges = find(edges == order(1));
    point_edges = rem(point_edges,8);
    point_edges = point_edges.*(point_edges ~= 0)+8*(point_edges == 0);
    [max_edge_length,max_edge] = max(edge_lengths(point_edges));
    order(2) = edges(point_edges(max_edge),find(edges(point_edges(max_edge),:) ~= order(1)));
    edge_length(point_edges) = 0;
    
    % For the this node, find the longest edge.  This will become node 3
    point_edges = find(edges == order(2));
    point_edges = rem(point_edges,8);
    point_edges = point_edges.*(point_edges ~= 0)+8*(point_edges == 0);
    [max_edge_length,max_edge] = max(edge_lengths(point_edges));
    order(3) = edges(point_edges(max_edge),find(edges(point_edges(max_edge),:) ~= order(2)));
    edge_length(point_edges) = 0;
    
    % For the this node, find the longest edge.  This will become node 4
    point_edges = find(edges == order(3));
    point_edges = rem(point_edges,8);
    point_edges = point_edges.*(point_edges ~= 0)+8*(point_edges == 0);
    [max_edge_length,max_edge] = max(edge_lengths(point_edges));
    order(4) = edges(point_edges(max_edge),find(edges(point_edges(max_edge),:) ~= order(3)));
    edge_length(point_edges) = 0;
    
case {'hex'}
    % Build element-->edges array
    blocks = floor(n_edges/1000000);
    offset = rem(n_edges,1000000);
    
    d_edges = 0;
    if blocks > 0
        for count = 1:blocks
            check = zeros(1000000,16);
            for n_nodes = 1:8
                check(:,n_nodes) = edges([1:1000000]+(count-1)*1000000,1) == nodes(n_nodes,1);
                check(:,n_nodes+8) = edges([1:1000000]+(count-1)*1000000,2) == nodes(n_nodes,1);
            end
            check = sum(check,2);
            f_edges = find(check == 2)';
            if ~isempty(f_edges)
                f_edges = f_edges+(count-1)*1000000;
                edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
                d_edges = d_edges+length(f_edges);
            end
        end
    end
    check = zeros(offset,16);
    for n_nodes = 1:8
        check(:,n_nodes) = edges([1:offset]+blocks*1000000,1) == nodes(n_nodes,1);
        check(:,n_nodes+8) = edges([1:offset]+blocks*1000000,2) == nodes(n_nodes,1);
    end
    check = sum(check,2);
    f_edges = find(check == 2)';
    if ~isempty(f_edges)
        f_edges = f_edges+blocks*1000000;
        edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
        d_edges = d_edges+length(f_edges);
    end
    
    edges = edges(edge,:);
    clear edge
    
    
    % For the hex, node 1 will be the node with the smallest distance from the origin
    order = zeros(1,8);
    % Re-label nodes in edges
    new_edges = edges*0;
    for node = 1:8
        new_edges(find(edges == nodes(node,1))) = node;
    end
    edges = new_edges;
    
    % Cartesian distances are
    d2 = nodes(:,2).^2+nodes(:,3).^2+nodes(:,4).^2;
    [min_d2,i_d2] = min(d2);
    order(1) = i_d2;
    
    % Calculate the edge lengths
    for edge = 1:12
        edge_lengths(edge) = sqrt((nodes(edges(edge,1),2)-nodes(edges(edge,2),2))^2 ...
            +(nodes(edges(edge,1),3)-nodes(edges(edge,2),3))^2+(nodes(edges(edge,1),4)-nodes(edges(edge,2),4))^2);
    end
    
    % Node 2 will be the node on the shortest edge from Node 1. 
    point_edges = find(edges == order(1));
    point_edges = rem(point_edges,12);
    point_edges = point_edges.*(point_edges ~= 0)+12*(point_edges == 0);
    [min_edge_length,min_edge] = min(edge_lengths(point_edges));
    order(2) = edges(point_edges(min_edge),find(edges(point_edges(min_edge),:) ~= order(1)));
    
    % Node 3 will be the node on the shortest edge from Node 2 that isn't node 1!
    point_edges = find(edges == order(2));
    point_edges = rem(point_edges,12);
    point_edges = point_edges.*(point_edges ~= 0)+12*(point_edges == 0);
    [min_edge_length,min_edge] = min(edge_lengths(point_edges));
    order(3) = edges(point_edges(min_edge),find(edges(point_edges(min_edge),:) ~= order(2)));
    if order(3) == order(1)
        [max_edge_length,max_edge] = max(edge_lengths(point_edges));
        edge_lengths(point_edges(min_edge)) = max_edge_length*10;
        [min_edge_length,min_edge] = min(edge_lengths(point_edges));
        order(3) = edges(point_edges(min_edge),find(edges(point_edges(min_edge),:) ~= order(2)));
    end
    
    % Node 4 is the node which is connected to nodes 1 and 3 and which isn't node 2
    point_edges_1 = find(edges == order(3));
    point_edges_1 = rem(point_edges_1,12);
    point_edges_1 = point_edges_1.*(point_edges_1 ~= 0)+12*(point_edges_1 == 0);
    
    point_edges_2 = find(edges == order(1));
    point_edges_2 = rem(point_edges_2,12);
    point_edges_2 = point_edges_2.*(point_edges_2 ~= 0)+12*(point_edges_2 == 0);
    
    for test_edge = 1:3
        test_node_1(test_edge) = edges(point_edges_1(test_edge),find(edges(point_edges_1(test_edge),:) ~= order(3)));
        test_node_2(test_edge) = edges(point_edges_2(test_edge),find(edges(point_edges_2(test_edge),:) ~= order(1)));
    end
    for test_edge = 1:3
        if ~isempty(find(test_node_1 == test_node_2(test_edge))) & test_node_2(test_edge) ~= order(2)
            order(4) = test_node_2(test_edge);
        end
    end
    
    % Node 5 is connected to node 1 and which is not nodes 2 or 4
    point_edges = find(edges == order(1));
    point_edges = rem(point_edges,12);
    point_edges = point_edges.*(point_edges ~= 0)+12*(point_edges == 0);
    
    for test_edge = 1:3
        test_node = edges(point_edges(test_edge),find(edges(point_edges(test_edge),:) ~= order(1)));
        if test_node ~= order(2) & test_node ~= order(4)
            order(5) = test_node;
            break
        end
    end
    
    % Node 6 is connected to nodes 5 and 2 and which isn't node 1
    point_edges_1 = find(edges == order(5));
    point_edges_1 = rem(point_edges_1,12);
    point_edges_1 = point_edges_1.*(point_edges_1 ~= 0)+12*(point_edges_1 == 0);
    
    point_edges_2 = find(edges == order(2));
    point_edges_2 = rem(point_edges_2,12);
    point_edges_2 = point_edges_2.*(point_edges_2 ~= 0)+12*(point_edges_2 == 0);
    
    for test_edge = 1:3
        test_node_1(test_edge) = edges(point_edges_1(test_edge),find(edges(point_edges_1(test_edge),:) ~= order(5)));
        test_node_2(test_edge) = edges(point_edges_2(test_edge),find(edges(point_edges_2(test_edge),:) ~= order(2)));
    end
    for test_edge = 1:3
        if ~isempty(find(test_node_1 == test_node_2(test_edge))) & test_node_2(test_edge) ~= order(1)
            order(6) = test_node_2(test_edge);
        end
    end
    
    % Node 7 is connected to nodes 6 and 3 and which isn't node 2
    point_edges_1 = find(edges == order(3));
    point_edges_1 = rem(point_edges_1,12);
    point_edges_1 = point_edges_1.*(point_edges_1 ~= 0)+12*(point_edges_1 == 0);
    
    point_edges_2 = find(edges == order(6));
    point_edges_2 = rem(point_edges_2,12);
    point_edges_2 = point_edges_2.*(point_edges_2 ~= 0)+12*(point_edges_2 == 0);
    
    for test_edge = 1:3
        test_node_1(test_edge) = edges(point_edges_1(test_edge),find(edges(point_edges_1(test_edge),:) ~= order(3)));
        test_node_2(test_edge) = edges(point_edges_2(test_edge),find(edges(point_edges_2(test_edge),:) ~= order(6)));
    end
    for test_edge = 1:3
        if ~isempty(find(test_node_1 == test_node_2(test_edge))) & test_node_2(test_edge) ~= order(2)
            order(7) = test_node_2(test_edge);
        end
    end
    
    % Node 8 is connected to nodes 7 and 5 and which isn't node 4
    point_edges_1 = find(edges == order(7));
    point_edges_1 = rem(point_edges_1,12);
    point_edges_1 = point_edges_1.*(point_edges_1 ~= 0)+12*(point_edges_1 == 0);
    
    point_edges_2 = find(edges == order(5));
    point_edges_2 = rem(point_edges_2,12);
    point_edges_2 = point_edges_2.*(point_edges_2 ~= 0)+12*(point_edges_2 == 0);
    
    for test_edge = 1:3
        test_node_1(test_edge) = edges(point_edges_1(test_edge),find(edges(point_edges_1(test_edge),:) ~= order(7)));
        test_node_2(test_edge) = edges(point_edges_2(test_edge),find(edges(point_edges_2(test_edge),:) ~= order(5)));
    end
    for test_edge = 1:3
        if ~isempty(find(test_node_1 == test_node_2(test_edge))) & test_node_2(test_edge) ~= order(4)
            order(8) = test_node_2(test_edge);
        end
    end
    
case {'prism'}
    % For the prism, node 1 will be the first node. Nodes 2 and 3 are those
    % connected to node 1, and connected to each other.  Nodes 4, 5 and 6 are those
    % connected to nodes 1, 2 and 3 respectively
    
    % Build element-->edges array
    blocks = floor(n_edges/1000000);
    offset = rem(n_edges,1000000);
    
    d_edges = 0;
    if blocks > 0
        for count = 1:blocks
            check = zeros(1000000,12);
            for n_nodes = 1:6
                check(:,n_nodes) = edges([1:1000000]+(count-1)*1000000,1) == nodes(n_nodes,1);
                check(:,n_nodes+6) = edges([1:1000000]+(count-1)*1000000,2) == nodes(n_nodes,1);
            end
            check = sum(check,2);
            f_edges = find(check == 2)';
            if ~isempty(f_edges)
                f_edges = f_edges+(count-1)*1000000;
                edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
                d_edges = d_edges+length(f_edges);
            end
        end
    end
    check = zeros(offset,12);
    for n_nodes = 1:6
        check(:,n_nodes) = edges([1:offset]+blocks*1000000,1) == nodes(n_nodes,1);
        check(:,n_nodes+6) = edges([1:offset]+blocks*1000000,2) == nodes(n_nodes,1);
    end
    check = sum(check,2);
    f_edges = find(check == 2)';
    if ~isempty(f_edges)
        f_edges = f_edges+blocks*1000000;
        edge([d_edges+1:d_edges+length(f_edges)]) = f_edges;
        d_edges = d_edges+length(f_edges);
    end
    
    edges = edges(edge,:);
    clear edge
    
    
    order = zeros(1,6);
    order(1) = 1;
    
    % Re-label nodes in edges
    new_edges = edges*0;
    for node = 1:6
        new_edges(find(edges == nodes(node,1))) = node;
    end
    edges = new_edges;
    
    % Find the nodes connected to node 1 and find the two that are connected to each other
    point_edges = find(edges == order(1));
    point_edges = rem(point_edges,9);
    point_edges = point_edges.*(point_edges ~= 0)+9*(point_edges == 0);
    
    for test_edge = 1:3
        test_node(test_edge) = edges(point_edges(test_edge),find(edges(point_edges(test_edge),:) ~= order(1)));
        test_edges = find(edges == test_node(test_edge));
        test_edges = rem(test_edges,9);
        test_edges = test_edges.*(test_edges ~= 0)+9*(test_edges == 0);
        for end_edge = 1:3
            end_nodes(test_edge,end_edge) = edges(test_edges(end_edge),find(edges(test_edges(end_edge),:) ~= test_node(test_edge)));
        end
    end
    for check_edge = 1:3
        for check_node = 1:3
            if ~isempty(find(end_nodes(check_edge,:) == test_node(check_node)));
                if order(2) == 0
                    order(2) = test_node(check_node);
                else
                    order(3) = test_node(check_node);
                end
            end
        end
    end
    
    % Node 4 must be the test node that wasn't connected to another.
    for check_node = 1:3
        if isempty(find(order == test_node(check_node)))
            order(4) = test_node(check_node);
        end
    end
    
    % Nodes 5 and 6 must be the other
    point_edges = find(edges == order(2));
    point_edges = rem(point_edges,9);
    point_edges = point_edges.*(point_edges ~= 0)+9*(point_edges == 0);
    for test_edge = 1:3
        test_node(test_edge) = edges(point_edges(test_edge),find(edges(point_edges(test_edge),:) ~= order(2)));
        for check_node = 1:3
            if isempty(find(order == test_node(check_node)))
                order(5) = test_node(check_node);
            end
        end
    end
    point_edges = find(edges == order(3));
    point_edges = rem(point_edges,9);
    point_edges = point_edges.*(point_edges ~= 0)+9*(point_edges == 0);
    for test_edge = 1:3
        test_node(test_edge) = edges(point_edges(test_edge),find(edges(point_edges(test_edge),:) ~= order(3)));
        for check_node = 1:3
            if isempty(find(order == test_node(check_node)))
                order(6) = test_node(check_node);
            end
        end
    end
end