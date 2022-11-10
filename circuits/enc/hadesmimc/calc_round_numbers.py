from math import *
import sys

if len(sys.argv) != 3:
    print "Usage: <script> <N> <t>"
    exit()

N_fixed = int(sys.argv[1])
t_fixed = int(sys.argv[2])

if N_fixed % t_fixed != 0:
    print "t is not a divisor of N!"
    exit()

def R_F_stat(N, t):
    n = ceil(float(N) / t)
    if n > t + 1:
        return 6
    else:
        return 10

def R_F_grob(N, t):
    n = ceil(float(N) / t)
    return 2 + ceil(float(n + 2 * log(t, 2)) / (2 * log(3, 2)))

def R_F_grob_1st(N, t):
    n = ceil(float(N) / t)
    return 2 + ceil(float(n) / (2 * log(3, 2)) + log(t, 3))

def R_F_grob_2nd(N, t):
    n = ceil(float(N) / t)
    #check1 = ceil(float(N) / (2 * ceil((n) - log(3, 2)))) + (float(N) / (2 * (log(27, 2) - 2)))
    #check2 = ceil(float(N) / (2 * log(float(2 * (2**n - 1) - 1) / 3, 2))) + (float(N) / (2 * (log(27, 2) - 2)))
    #print "check1:", check1
    #print "check2:", check2
    return ceil(float(N) / (2 * log(float(2 * (2**n - 1) - 1) / 3, 2))) + (float(N) / (2 * (log(27, 2) - 2)))
    #return check1

def R_F_grob_3rd(N, t, R_P):
    return 2 + log(2, 3) * ((float(N) / (2*t + R_P)) + 2 * log(t + R_P, 2) - 2 * log(t, 2))

def R_inter(N, t):
    n = ceil(float(N) / t)
    ret_val = 5 + ceil(n * log(2, 3)) + ceil(log(t, 3))
    return int(ret_val)

def psi_1(N, t):
    return max(0, R_inter(N, t), R_F_grob_1st(N, t))

def psi_t(N, t):
    return max(0, R_F_grob_2nd(N, t))

def find_FD_round_numbers(N, t):
    R_P = 0
    R_F = 0
    min_cost = float("inf")
    max_cost_rf = 0
    # Brute-force approach
    for R_P_t in range(1, N):
        for R_F_t in range(1, get_recommendation_1(N, t)[0] + 1):
            if R_F_t % 2 == 0:
                R_F_1 = ceil(R_F_stat(N, t))
                R_F_2 = ceil(psi_1(N, t) - R_P_t)
                R_F_3 = ceil(float(psi_t(N, t) - R_P_t) / t)
                R_F_4 = ceil(R_F_grob_3rd(N, t, R_P_t))
                R_F_max = max([R_F_1, R_F_2, R_F_3, R_F_4])
                if R_F_t >= R_F_max:
                    cost = get_MPC_cost(R_F_t, R_P_t, N, t)
                    # Check if (1) cost is reduced, or (2) cost is the same and depth is the same, but new R_F is smaller
                    if (cost < min_cost) or (cost == min_cost and ((R_F_t + R_P_t) == (R_F + R_P)) and R_F_t < R_F):
                        R_P = ceil(R_P_t)
                        R_F = ceil(R_F_t)
                        min_cost = cost
                        max_cost_rf = R_F
    return (int(R_F), int(R_P))

def find_LD_round_numbers(N, t):
    n = ceil(float(N) / t)
    R_P = 0
    R_F = 0
    min_cost = float("inf")
    max_cost_rf = 0
    # Brute-force approach
    for R_P_t in range(1, N):
        for R_F_t in range(1, get_recommendation_1(N, t)[0] + 1):
            R_F_1 = ceil(4 + ceil(n * log(2, 3)) - floor(2 * log(n, 3)) - R_P_t)
            R_F_2 = ((R_F_grob_2nd(N, t) - R_P_t) / t)
            R_F_3 = ceil(R_F_grob_3rd(N, t, R_P_t))
            R_F_max = max([R_F_1, R_F_2, R_F_3])
            if R_F_t >= R_F_max:
                cost = get_MPC_cost(R_F_t, R_P_t, N, t)
                if (cost < min_cost) or ((cost == min_cost) and (R_F_t > max_cost_rf)):
                    R_P = ceil(R_P_t)
                    R_F = ceil(R_F_t)
                    min_cost = cost
                    max_cost_rf = R_F
    return (int(R_F), int(R_P))

def get_MPC_cost(R_F, R_P, N, t):
    return int((t * R_F) + R_P)

def get_SIG_cost(R_F, R_P, N, t):
    n = ceil(float(N) / t)
    return int((N * R_F) + (n * R_P))

def get_recommendation_1(N, t):
    R_F = max(R_F_stat(N, t), R_F_grob(N, t))
    if (R_F % 2 == 1):
        R_F += 1
    R_P = max(0, R_inter(N, t) - R_F)
    return (int(R_F), int(R_P))

# Find best possible for t_fixed and N_fixed
(R_F_1, R_P_1) = get_recommendation_1(N_fixed, t_fixed)
(R_F_2, R_P_2) = find_FD_round_numbers(N_fixed, t_fixed)
mpc_cost_1 = get_MPC_cost(R_F_1, R_P_1, N_fixed, t_fixed)
mpc_cost_2 = get_MPC_cost(R_F_2, R_P_2, N_fixed, t_fixed)
print "[MPC] Recommendation for N=" + str(N_fixed) + ", t=" + str(t_fixed) + ":"
if mpc_cost_1 < mpc_cost_2:
    print "(R_F, R_P) =", (R_F_1, R_P_1)
else:
    print "(R_F, R_P) =", (R_F_2, R_P_2)

# Find best possible for N_fixed (and combinations for n and t)
# Search best for MPC (other t_limit due to MDS)
field = 1 # Use prime field here
min_mpc_cost = float("inf")
min_mpc_rn = (0, 0)
min_mpc_n = 0
min_mpc_t = 0
t_limit_mpc = int(N_fixed / (log(((2 * N_fixed) / log(N_fixed + 1, 2) + 1) + 1, 2)))
for t in range(2, t_limit_mpc + 1):
    n = int(ceil(float(N_fixed) / t))
    N_new = n * t
    (R_F_1, R_P_1) = get_recommendation_1(N_new, t)
    (R_F_2, R_P_2) = find_FD_round_numbers(N_new, t)
    mpc_cost_1 = get_MPC_cost(R_F_1, R_P_1, N_new, t)
    mpc_cost_2 = get_MPC_cost(R_F_2, R_P_2, N_new, t)
    # MPC
    if mpc_cost_1 < min_mpc_cost:
        min_mpc_rn = (R_F_1, R_P_1)
        min_mpc_cost = mpc_cost_1
        min_mpc_n = n
        min_mpc_t = t
    if mpc_cost_2 < min_mpc_cost:
        min_mpc_rn = (R_F_2, R_P_2)
        min_mpc_cost = mpc_cost_2
        min_mpc_n = n
        min_mpc_t = t
print "[MPC] Recommendation for N=" + str(min_mpc_n * min_mpc_t) + ", t=" + str(min_mpc_t) + ":"
print "(R_F, R_P) =", min_mpc_rn

# Search best for SIG (higher t_limit, no MDS necessary)
field = 0 # Use binary field here
min_sig_cost = float("inf")
min_sig_rn = (0, 0)
min_sig_n = 0
min_sig_t = 0
t_limit_sig = int(ceil(float(N_fixed) / 3))
for t in range(2, t_limit_sig + 1):
    n = int(ceil(float(N_fixed) / t))
    if n % 2 == 0:
        continue
    N_new = n * t
    (R_F_1, R_P_1) = find_LD_round_numbers(N_new, t)
    sig_cost = get_SIG_cost(R_F_1, R_P_1, N_new, t)

    # SIG
    if sig_cost <= min_sig_cost:
        min_sig_rn = (R_F_1, R_P_1)
        min_sig_cost = sig_cost
        min_sig_n = n
        min_sig_t = t
    
#print "[MPC] Recommendation for N=~" + str(N_fixed) + ":"
#print "(Cost, n, t, N_new, R_F, R_P) =", (min_mpc_cost, min_mpc_n, min_mpc_t, (min_mpc_n * min_mpc_t)) + (min_mpc_rn)

print "[SIG] Recommendation for N=~" + str(N_fixed) + ":"
print "(Cost, n, t, N_new, R_F, R_P) =", (min_sig_cost, min_sig_n, min_sig_t, (min_sig_n * min_sig_t)) + (min_sig_rn)

