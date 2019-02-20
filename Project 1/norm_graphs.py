import numpy as np
import random
import matplotlib.pyplot as plt

# fractional model - R = a+b*Vin/(Vin+Vout)
# def frac_model(v_in, v_out, a, b)
# 	return a + b * (v_in / (v_in + v_out))

# difference model - R = a+b*(Vin-Vout)
# def diff_model(v_in, v_out, a, b):
# 	return a + b * (v_in - v_out)

# simple normalization model - R = Rmax*Vin/(alpha+Vin+Vout)
# def simple_norm(v_in, v_out, alpha, R_max):
# 	return R_max * v_in / (alpha + v_in + v_out)

# full normalization model - R = Rmax*(Vin+beta)/(alpha+Vin+Vout)
def full_norm(r_max, v_in, v_out, beta, alpha):
	return r_max * (v_in + beta) / (alpha + v_in + v_out)

def graph_activity(v_in_list, v_out_list, title):
    # fit parameters
    # (Full Devisive Normalization) for all Vin value conditions together
    r_max = 2.96
    alpha = 1161
    beta = 92.6

    x = []
    y = []

    for v_in in v_in_list:
        for v_out in v_out_list:
            r = full_norm(r_max, v_in, v_out, beta, alpha)
            x_val = 1/(v_in+v_out)
            x.append(x_val)
            y.append(r)

    plt.plot(x,y)
    plt.title(title)
    plt.ylabel('Activity')
    plt.xlabel('1/(v_in+v_out)')
    plt.show() 
    
# effect of extra RF
v_in = [260]
v_out = [130, 163, 195, 228, 260]
title = 'Effect of Extra RF'
graph_activity(v_in, v_out, title)

# RF target value modulation was examined in blocks with extra-RF magnitude fixed
v_out = [130]
v_in = [65, 195, 260, 390]
title = 'RF Target Modulation'
graph_activity(v_in, v_out, title)