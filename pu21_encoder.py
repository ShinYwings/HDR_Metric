import cv2
import utils
import numpy as np
import sys

"""
NOT USED
"""
def pu21_encoder():

    def __init__(self, type='banding_glare'):
        self.L_min = 0.005
        self.L_max = 10000.
        self.epsilon = 1e-5
        if type == 'banding':
            self.par = [1.070275272, 0.4088273932, 0.153224308, 0.2520326168, 1.063512885, 1.14115047, 521.4527484]
        elif type == 'banding_glare':
            self.par = [0.353487901, 0.3734658629, 8.277049286e-05, 0.9062562627, 0.09150303166, 0.9099517204, 596.3148142]
        elif type == 'peaks':
            self.par = [1.043882782, 0.6459495343, 0.3194584211, 0.374025247, 1.114783422, 1.095360363, 384.9217577]
        elif type == 'peaks_glare':
            self.par = [816.885024, 1479.463946, 0.001253215609, 0.9329636822, 0.06746643971, 1.573435413, 419.6006374]
        
    def encode(self, hdr):
        # norm_hdr = hdr / np.max(hdr)
        if hdr.any() < self.L_min - self.epsilon or hdr.any() > self.L_max + self.epsilon:
            print('Values passed to encode are outside the valid range')

        Y = np.min(np.max(hdr, self.L_min), self.L_max)
        V = self.par[6] * (np.pow((self.par[0] + self.par[1]*np.pow(Y,self.par[3]))/ (1+self.par[2]*np.pow(Y, self.par[3]))), self.par[4] - self.par[5])

        return V

    def decode(self, V):
        
        V_p = np.pow(np.max(V/self.par[6]+self.par[5], 0), 1/self.par[4])
        Y = np.pow((np.max(V_p - self.par[0], 0)/ (self.par[1]- self.par[2]*V_p)), 1/self.par[3])

        return Y

        



