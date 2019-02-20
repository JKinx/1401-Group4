import numpy as np
import random
import matplotlib.pylot as plt
from scipy.optimize import curve_fit


# use their parameters 
# v_in water amount in neuron class, v_out outside of cluster -> take values they set for us
# generate firing rates - ask prof if this is kosher...
# generate graphs
# conduct tests
# clean and organize code
# write experiment results

# [FILL DATA] neuronal firing rate data for each trial
firing_high = []
firing_med = []
firing_low = []
firing_none = []

# [FILL DATA] light data for each trial
V_in_high = [random.gauss(260, 10) for x in range(100)]
V_in_med = [random.gauss() for x in range(100)]
V_in_low = [random.gauss(65, 10) for x in range(100)]
V_in_none = [random.gauss() for x in range(100)]

V_out_high = [random.gauss() for x in range(100)]
V_out_med = [random.gauss() for x in range(100)]
V_out_low = [random.gauss() for x in range(100)]
V_out_none = [random.gauss() for x in range(100)]

################
# Models
################

# fractional model
# R = a+b*Vin/(Vin+Vout)
As = np.linspace(-100, 100, 400) # why do you need this
Bs = np.linspace(-100, 100, 400) # why do you need this
def frac_model(v_in, v_out, a, b)
	return a + b * (v_in / (v_in + v_out))

# difference model
# R = a+b*(Vin-Vout)
def diff_model(v_in, v_out, a, b):
	return a + b * (v_in - v_out)

R_max = max(firing_high)

# simple normalization model
# R = Rmax*Vin/(sigma+Vin+Vout)
def simple_norm(v_in, v_out, sigma):
	global R_max
	return R_max * v_in / (sigma + v_in + v_out)

# full normalization model
# R = Rmax*(Vin+beta)/(sigma+Vin+Vout)
def full_norm(v_in, v_out, beta, sigma):
	global R_max
	return R_max * (v_in + beta) / (sigma + v_in + v_out)

################
# Results
################

# run on all combos of firing rates, V_in, and V_out
# R = firing_rate, outputs a and b -> then use those values to generate the graphs 
# graph firing rates Vs. Y axis in figure 7 and equation solution with the solved for parameters
frac_popt, fract_pocv = curve_fit(frac_model, V_in_high, V_out_high, firing_high)
diff_popt, diff_pocv = curve_fit(diff_model, V_in_high, V_out_high, firing_high)
s_norm_popt, s_norm_pocv = curve_fit(simple_norm, V_in_high, V_out_high, firing_high)
full_norm_popt, full_norm_pocv = curve_fit(full_norm, V_in_high, V_out_high, firing_high)