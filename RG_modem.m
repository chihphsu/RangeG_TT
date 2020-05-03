## Copyright (C) 2020 C Hsu
## 
## Author: cphsu <cphsu@yahoo.com>
## Created: 2020-04-22

function msg_r = RG_modem(msg)

  fft_s = 256;
  symbols_per_pilot = 8;

  hl = [0.7 02i 0.1];
  cp_len = 4;

  num_p = fft_s/symbols_per_pilot;

  EbNodB = 2;
  EbNo = 10^(EbNodB/10);
  sigma = sqrt(1/(2*10^(EbNodB/10)));

  n = 2 * (fft_s - num_p);

  Xn = [];
  for j = 1:fft_s-num_p
    Xn = [Xn; 1-2*msg(2*j-1)+(1-2*msg(2*j))*i];
    if mod(j+symbols_per_pilot/2-1, symbols_per_pilot-1) == 0
      Xn = [Xn; 1+i];
    endif
  endfor

  alpha = sqrt(fft_s);
  xl = alpha * ifft(Xn, fft_s);
  cp = xl(end-cp_len+1:end);
  xlt = [cp; xl];

  ylr = conv(xlt, hl);
  ylr_len = size(ylr)(1);
  nl = sigma * (randn(ylr_len,1) + randn(ylr_len,1)*i);
  ylr = ylr + nl;

  yl = ylr(cp_len+1:end-1);
  Yn = fft(yl, fft_s)/alpha;

  Y = [];
  for j = 1:num_p
    Y = [Y; Yn(symbols_per_pilot/2+(j-1)*symbols_per_pilot+1)];
  endfor

  X = ones(num_p,1)*(1+i);

  Ymean = mean(Y);
  Ryy = (Y - Ymean) * (Y - Ymean)';
  Rhh = (Ryy - sigma^2 * eye(num_p));

  [U S V] = svd(Ryy);
  Ryy_rank = min(rank(Ryy), cp_len)

  Ryyinv = U(:,1:Ryy_rank) * diag(1./S(1:Ryy_rank,1:Ryy_rank)) * V(:,1:Ryy_rank)';
  Hmmse = Rhh*Ryyinv*(Y -Ymean)/(1+i) + Ymean;

  Hx = [Hmmse(end); Hmmse; Hmmse(1)];
  Hn_mmse = interp(Hx, symbols_per_pilot);
  Hn_mmse = Hn_mmse(symbols_per_pilot/2+1:fft_s+symbols_per_pilot/2);

  Xn_r = Yn./Hn_mmse;

  msg_r = [];
  for j = 1:fft_s
    if mod(j-1-symbols_per_pilot/2, symbols_per_pilot) != 0
      msg_r = [msg_r real(Xn_r(j)) imag(Xn_r(j))];
    endif
  endfor
  
endfunction