function coefs = Swap_Coefs(coefs);

temp = coefs;
coefs(1) = 1/temp(1);
coefs(2) = -temp(2)/temp(1);