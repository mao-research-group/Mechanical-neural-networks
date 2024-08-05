function [DT,bonds] = Triangle(params)
    a = params.a;
    n = params.n;
    a1 = [a,0];
    a2 = [a*cos(pi/3),a*sin(pi/3)];
    p = [];
    for i = 0:n-1
        for j = 0:n-i
            p = [p;-j*a1 - i*a2];
        end
    end
    DT = delaunayTriangulation(p(:,1),p(:,2));
    ind = [];
    for i = 1:size(DT.ConnectivityList,1)
        xy = [DT.Points(DT.ConnectivityList(i,1),1),DT.Points(DT.ConnectivityList(i,1),2);...
            DT.Points(DT.ConnectivityList(i,2),1),DT.Points(DT.ConnectivityList(i,2),2);...
            DT.Points(DT.ConnectivityList(i,3),1),DT.Points(DT.ConnectivityList(i,3),2)];
        if rank(xy(2:end,:) - xy(1,:)) == 1
            ind = [ind,i];
        end
    end
    ConnectivityList = DT.ConnectivityList;
    ConnectivityList(ind,:) = [];

    edge_ID = [];
    for i = 1:size(ConnectivityList,1)
        edge_ID = [edge_ID;[ConnectivityList(i,1),ConnectivityList(i,2)];...
            [ConnectivityList(i,1),ConnectivityList(i,3)];...
            [ConnectivityList(i,2),ConnectivityList(i,3)]];
    end
    idx = [];
    for i = 1:size(edge_ID,1)
        for j = i+1:size(edge_ID,1)
            if i ~= j
                if isequal(edge_ID(i,:),edge_ID(j,:)) || isequal(edge_ID(i,:),flip(edge_ID(j,:),2))
                    idx = [idx,j];
                end
            end
        end
    end
    bonds = edge_ID;
    bonds(idx,:) = [];