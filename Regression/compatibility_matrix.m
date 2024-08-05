function C = compatibility_matrix(pos,connectivity)
    n = size(pos,1);
    m = size(connectivity,1);
    x = pos(:,1);
    y = pos(:,2);

    C = zeros(m,2*n);
    ux = sym('ux',[n,1]);
    uy = sym('uy',[n,1]);
    u_vec = sym(zeros(2*n,1));
    u_vec(1:2:end) = ux;
    u_vec(2:2:end) = uy;
    for i = 1:m
        inx1 = connectivity(i,1);
        inx2 = connectivity(i,2);
        r1 = [x(inx1),y(inx1)];
        r2 = [x(inx2),y(inx2)];
        e_vec = (r2 - r1)/norm(r2 - r1);
        u1 = [ux(inx1);uy(inx1)];
        u2 = [ux(inx2);uy(inx2)];
        C_vec = e_vec*(u1-u2);
        [C_coeff,t] = coeffs(collect(C_vec,u_vec),u_vec);
        for col = 1:length(t)
            ind = find(t(col) == u_vec);
            C(i,ind) = C_coeff(col);
        end
    end