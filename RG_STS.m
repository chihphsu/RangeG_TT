## Copyright (C) 2020 cphsu
## Author: cphsu <cphsu@KIRIN>
## Created: 2020-05-13

function Pn = RG_STS(yl, SC_d, SC_w)
  b = zeros(1, SC_w+1);
  b(1) = 1; b(SC_w+1) = -1;
  a = [1 -1];

  yl = [yl; zeros(SC_d,1)];
  v = [zeros(SC_d,1); yl(1:end-SC_d)];
  v = conj(yl) .* v;
  Pn = filter(b, a, v);
  Pn_nf = 10 * SC_w/16;
  Pn = Pn / Pn_nf;
endfunction
