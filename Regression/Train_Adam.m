function [k,m_moment,v_moment] = Train_Adam(k0,sgCurr,m,v,iter,params,optims)
    
    alpha = optims.alpha;
    beta1 = optims.beta1;
    beta2 = optims.beta2;
        
    m_moment = beta1.*m + (1 - beta1).*sgCurr;
    v_moment = beta2.*v + (1 - beta2).*(sgCurr.^2);
        
    mHat = m_moment./(1 - beta1^iter);
    vHat = v_moment./(1 - beta2^iter);
        
    k = k0 - alpha.*mHat./(sqrt(vHat) + sqrt(eps));