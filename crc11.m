function [resto] = crc11(h)
    gx = [1 1 1 0 0 0 1 0 0 0 0 1];
    px = h;
    pxr=[px zeros(1,length(gx)-1)];
    [c r]=deconv(pxr,gx);

    r=mod(abs(r),2);
    resto=r(length(px)+1:end);
endfunction
