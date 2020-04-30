## Copyright (C) 2020 C Hsu
## 
## Author: cphsu <cphsu@yahoo.com>
## Created: 2020-04-22

function msg_r = RG_modem(msg)
  fft_s = 512;
  symbols_per_pilot = 8;

  EbNodB = 25;
  EbNo = 10^(EbNodB/10);
  sigma = sqrt(1/(2*EbNo));

  pkg load signal;

  hl = [0.8 02i];
  cp_len = 4;

  num_p = fft_s/symbols_per_pilot;

  n = 2 * (fft_s - num_p);

  Xn = [];
  for j = 1:fft_s-num_p
    Xn = [Xn 1-2*msg(2*j-1)+(1-2*msg(2*j))*i];
    if mod(j+symbols_per_pilot/2-1, symbols_per_pilot-1) == 0
      Xn = [Xn 1+i];
    endif
  endfor

  Px = ones(1, num_p)*(1+i);
  xl = ifft(Xn, fft_s);
  cp = xl(end-cp_len+1:end);
  xlt = [cp xl];

  ylr = conv(xlt, hl);
  ylr_len = size(ylr)(2);
  nl = sigma * (randn(1,ylr_len) + randn(1, ylr_len)*i);
  ylr = ylr + nl;

  yl = ylr(cp_len+1:end-1);
  Yn = fft(yl, fft_s);

  Py = [];
  for j = 1:num_p
    Py = [Py Yn(symbols_per_pilot/2+(j-1)*symbols_per_pilot+1)];
  endfor

  Hp = Py ./ Px;


  Hpx = [Hp(end) Hp Hp(1)];
  Hn = interp(Hpx, symbols_per_pilot);
  Hn = Hn(symbols_per_pilot/2+1:fft_s+symbols_per_pilot/2);

  Xn_r = Yn./Hn;

  msg_r = [];
  for j = 1:fft_s
    if mod(j-1-symbols_per_pilot/2, symbols_per_pilot) != 0
      msg_r = [msg_r real(Xn_r(j)) imag(Xn_r(j))];
    endif
  endfor
endfunction