freqErr_on = true;
fading_on = false;
noise_on = true;
plot_on = false;

STS = [0.36799 + 0.36799i; -1.05955 + 0.01872i; -0.10778 - 0.62820i;
 1.14204 - 0.10121i; 0.73598 + 0.00000i; 1.14204 - 0.10121i;
 -0.10778 - 0.62820i; -1.05955 + 0.01872i; 0.36799 + 0.36799i;
 0.01872 - 1.05955i; -0.62820 - 0.10778i; -0.10121 + 1.14204i;
 0.00000 + 0.73598i; -0.10121 + 1.14204i; -0.62820 - 0.10778i;
 0.01872 - 1.05955i];

LTS = [-1.25000 + 0.00000i; 0.09828 - 0.78080i; 0.73373 - 0.84697i;
 -0.73510 - 0.92103i; -0.02245 - 0.43019i; 0.60059 + 0.59232i;
 -1.01859 + 0.16401i; -0.97510 + 0.13253i; -0.28033 + 1.20711i;
 -0.45164 + 0.17443i; -0.48248 - 0.65029i; 0.55645 - 0.11298i;
 0.65775 - 0.73885i; -1.05010 - 0.52182i; -0.45765 - 0.31439i;
 0.29534 - 0.78675i; 0.50000 + 0.50000i; 0.95391 + 0.03276i;
 -0.17987 - 1.28526i; 0.46935 + 0.11951i; 0.19581 + 0.46825i;
 -1.09444 + 0.37904i; 0.00791 + 0.92004i; 0.42670 - 0.03261i;
 0.78033 + 0.20711i; -0.30653 + 0.84937i; -0.92105 + 0.44144i;
 0.47859 + 0.70165i; 0.16889 - 0.22309i; 0.77466 - 0.66238i;
 0.31800 + 0.88926i; -0.04097 + 0.96260i; 1.25000 + 0.00000i;
 -0.04097 - 0.96260i; 0.31800 - 0.88926i; 0.77466 + 0.66238i;
 0.16889 + 0.22309i; 0.47859 - 0.70165i; -0.92105 - 0.44144i;
 -0.30653 - 0.84937i; 0.78033 - 0.20711i; 0.42670 + 0.03261i;
 0.00791 - 0.92004i; -1.09444 - 0.37904i; 0.19581 - 0.46825i;
 0.46935 - 0.11951i; -0.17987 + 1.28526i; 0.95391 - 0.03276i;
 0.50000 - 0.50000i; 0.29534 + 0.78675i; -0.45765 + 0.31439i;
 -1.05010 + 0.52182i; 0.65775 + 0.73885i; 0.55645 + 0.11298i;
 -0.48248 + 0.65029i; -0.45164 - 0.17443i; -0.28033 - 1.20711i;
 -0.97510 - 0.13253i; -1.01859 - 0.16401i; 0.60059 - 0.59232i;
 -0.02245 + 0.43019i; -0.73510 + 0.92103i; 0.73373 + 0.84697i;
 0.09828 + 0.78080i];

SC_dc = 16;
SC_wc = 16;
SC_df = 64;
SC_wf = 32;
SC_th = 1.0;

if noise_on
  EbNodB = 0;
  sigma = sqrt(1/(2*10^(EbNodB/10)));
  N0 = 2*sigma^2
endif

xl = repmat(STS, 10, 1);
xl(1) = xl(1)/2;

delay_s = randi(16);
xlt = [zeros(delay_s+SC_df,1); xl];

xl = [LTS; LTS; LTS(1:32)];
xl(1) = xl(1)/2;

xlt = [xlt; xl; zeros(64,1)];

if fading_on
  hl = [-0.13757 + 0.76230i; -0.59160 + 0.12888i; 0.16513 + 0.07816i];
  ylr = filter(hl, 1, xlt);
else
  ylr = xlt;
endif

if freqErr_on
  p_err = (rand-0.5)*2*pi/32
  perr_v = p_err*[1:size(xlt)(1)]';
  perr_v = exp(mod(perr_v,2*pi)*i);
  ylr = ylr .* perr_v;
endif

if noise_on
  nl = sigma * (randn(size(ylr)(1),1) + randn(size(ylr)(1),1)*i);
  ylr = ylr + nl;
endif

PnC = RG_STS(ylr, SC_dc, SC_wc);

locC = 77;
while abs(PnC(locC)) < SC_th
  locC += 1;
endwhile

locC += 1;
locC = [locC; locC+160-SC_dc-SC_wc];
pkC = abs(PnC(locC));


p_alpha = mean(angle(PnC(locC(1):locC(1)+152-SC_dc-SC_wc)))/SC_dc;
p_correct = p_alpha*[1:size(ylr)(1)]';
p_correct = exp(mod(p_correct,2*pi)*i);
ylr_c = ylr .* p_correct;

PnF = RG_STS(ylr_c(1:locC(1)+SC_df+SC_wf+64), SC_df, SC_wf);

locF = [locC(1)+64 locC(1)+120]';
pkF = abs(PnF(locF));

p_beta = mean(angle(PnF(locF(1,1):locF(2,1))))/SC_df;


p_correct = p_beta*[1:size(ylr)(1)]';
p_correct = exp(mod(p_correct,2*pi)*i);
ylr_c = ylr_c .* p_correct;

LTS_st = locC(1) + 97;
LTS_end = size(ylr)(1)-64;
for idx=1:LTS_end-LTS_st
  An(idx) = transpose(ylr_c(LTS_st+idx:LTS_st+idx+32)) * flip(ylr_c(LTS_st+idx+32:LTS_st+idx+64))/32;
endfor

[pkL,locL]=max(abs(An));

disp([SC_df+delay_s+1 locC(1)-31]);
epoc_cap = mod(locL+16,32)+locC(1)-47

p_beta = mean(angle(PnF(epoc_cap+95:epoc_cap+158)))/SC_df;
p_cap = -(p_alpha+p_beta)

locL = epoc_cap + 63 - locC(1) + [0:3]'*32;
pkL = abs(An(locL));
for idx = 1:4
  Bn(idx) = ylr_c(LTS_st+locL(idx)+32:LTS_st+locL(idx)+64)' * ...
            ylr_c(LTS_st+locL(idx)+32:LTS_st+locL(idx)+64)/32;
  Nu(idx) = mean(ylr_c(LTS_st+locL(idx)+32:LTS_st+locL(idx)+64));
endfor
RnL = Bn -abs(Nu).^2;
N0L = mean(RnL-pkL)

if plot_on
  plot(abs(PnC));
  hold on;
  plot(abs(PnF));
  plot(locC, pkC, 'd');
  plot(locF, pkF, 'd');
  plot(abs(An));
  plot(locL, pkL, 'o');
endif
