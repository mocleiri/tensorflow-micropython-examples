# Copyright (c) 2006 Carnegie Mellon University
#
# You may copy and modify this freely under the same terms as
# Sphinx-III

"""Compute MFCC coefficients.

This module provides functions for computing MFCC (mel-frequency
cepstral coefficients) as used in the Sphinx speech recognition
system.
"""

__author__ = "David Huggins-Daines <dhuggins@cs.cmu.edu>"
__version__ = "$Revision: 6390 $"

from ulab import numpy

def mel(f):
	return 2595. * numpy.log10(1. + f / 700.)

def melinv(m):
	return 700. * (numpy.power(10., m / 2595.) - 1.)

# copied from numpy 1.19ish:
# 2021-01-25
# https://github.com/numpy/numpy/blob/master/numpy/lib/function_base.py
def hamming(M):
    """
    Return the Hamming window.
    The Hamming window is a taper formed by using a weighted cosine.
    Parameters
    ----------
    M : int
        Number of points in the output window. If zero or less, an
        empty array is returned.
    Returns
    -------
    out : ndarray
        The window, with the maximum value normalized to one (the value
        one appears only if the number of samples is odd).
    See Also
    --------
    bartlett, blackman, hanning, kaiser
    Notes
    -----
    The Hamming window is defined as
    .. math::  w(n) = 0.54 - 0.46cos\\left(\\frac{2\\pi{n}}{M-1}\\right)
               \\qquad 0 \\leq n \\leq M-1
    The Hamming was named for R. W. Hamming, an associate of J. W. Tukey
    and is described in Blackman and Tukey. It was recommended for
    smoothing the truncated autocovariance function in the time domain.
    Most references to the Hamming window come from the signal processing
    literature, where it is used as one of many windowing functions for
    smoothing values.  It is also known as an apodization (which means
    "removing the foot", i.e. smoothing discontinuities at the beginning
    and end of the sampled signal) or tapering function.
    References
    ----------
    .. [1] Blackman, R.B. and Tukey, J.W., (1958) The measurement of power
           spectra, Dover Publications, New York.
    .. [2] E.R. Kanasewich, "Time Sequence Analysis in Geophysics", The
           University of Alberta Press, 1975, pp. 109-110.
    .. [3] Wikipedia, "Window function",
           https://en.wikipedia.org/wiki/Window_function
    .. [4] W.H. Press,  B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling,
           "Numerical Recipes", Cambridge University Press, 1986, page 425.
    Examples
    --------
    >>> np.hamming(12)
    array([ 0.08      ,  0.15302337,  0.34890909,  0.60546483,  0.84123594, # may vary
            0.98136677,  0.98136677,  0.84123594,  0.60546483,  0.34890909,
            0.15302337,  0.08      ])
    Plot the window and the frequency response:
    >>> import matplotlib.pyplot as plt
    >>> from numpy.fft import fft, fftshift
    >>> window = np.hamming(51)
    >>> plt.plot(window)
    [<matplotlib.lines.Line2D object at 0x...>]
    >>> plt.title("Hamming window")
    Text(0.5, 1.0, 'Hamming window')
    >>> plt.ylabel("Amplitude")
    Text(0, 0.5, 'Amplitude')
    >>> plt.xlabel("Sample")
    Text(0.5, 0, 'Sample')
    >>> plt.show()
    >>> plt.figure()
    <Figure size 640x480 with 0 Axes>
    >>> A = fft(window, 2048) / 25.5
    >>> mag = np.abs(fftshift(A))
    >>> freq = np.linspace(-0.5, 0.5, len(A))
    >>> response = 20 * np.log10(mag)
    >>> response = np.clip(response, -100, 100)
    >>> plt.plot(freq, response)
    [<matplotlib.lines.Line2D object at 0x...>]
    >>> plt.title("Frequency response of Hamming window")
    Text(0.5, 1.0, 'Frequency response of Hamming window')
    >>> plt.ylabel("Magnitude [dB]")
    Text(0, 0.5, 'Magnitude [dB]')
    >>> plt.xlabel("Normalized frequency [cycles per sample]")
    Text(0.5, 0, 'Normalized frequency [cycles per sample]')
    >>> plt.axis('tight')
    ...
    >>> plt.show()
    """
    if M < 1:
        return array([])
    if M == 1:
        return numpy.ones(1, float)
    n = numpy.arange(1-M, M, 2)
    return 0.54 + 0.46*cos(numpy.pi*n/(M-1))


class MFCC(object):
	def __init__(self, nfilt=40, ncep=13,
	             lowerf=133.3333, upperf=6855.4976, alpha=0.97,
	             samprate=16000, frate=100, wlen=0.0256,
	             nfft=256):
		# Store parameters
		self.lowerf = lowerf
		self.upperf = upperf
		self.nfft = nfft
		self.ncep = ncep
		self.nfilt = nfilt
		self.frate = frate
		self.fshift = float(samprate) / frate

		# Build Hamming window
		self.wlen = int(wlen * samprate)
		self.win = hamming(self.wlen)

		# Prior sample for pre-emphasis
		self.prior = 0
		self.alpha = alpha

		# Build mel filter matrix
		self.filters = numpy.zeros((nfft/2+1,nfilt), 'd')
		dfreq = float(samprate) / nfft
		if upperf > samprate/2:
			raise(Exception,
			      "Upper frequency %f exceeds Nyquist %f" % (upperf, samprate/2))
		melmax = mel(upperf)
		melmin = mel(lowerf)
		dmelbw = (melmax - melmin) / (nfilt + 1)
		# Filter edges, in Hz
		filt_edge = melinv(melmin + dmelbw * numpy.arange(nfilt + 2, dtype='d'))

		for whichfilt in range(0, nfilt):
			# Filter triangles, in DFT points
			leftfr = round(filt_edge[whichfilt] / dfreq)
			centerfr = round(filt_edge[whichfilt + 1] / dfreq)
			rightfr = round(filt_edge[whichfilt + 2] / dfreq)
			# For some reason this is calculated in Hz, though I think
			# it doesn't really matter
			fwidth = (rightfr - leftfr) * dfreq
			height = 2. / fwidth

			if centerfr != leftfr:
				leftslope = height / (centerfr - leftfr)
			else:
				leftslope = 0
			freq = leftfr + 1
			while freq < centerfr:
				self.filters[freq,whichfilt] = (freq - leftfr) * leftslope
				freq = freq + 1
			if freq == centerfr: # This is always true
				self.filters[freq,whichfilt] = height
				freq = freq + 1
			if centerfr != rightfr:
				rightslope = height / (centerfr - rightfr)
			while freq < rightfr:
				self.filters[freq,whichfilt] = (freq - rightfr) * rightslope
				freq = freq + 1
		#             print("Filter %d: left %d=%f center %d=%f right %d=%f width %d" %
		#                   (whichfilt,
		#                   leftfr, leftfr*dfreq,
		#                   centerfr, centerfr*dfreq,
		#                   rightfr, rightfr*dfreq,
		#                   freq - leftfr))
		#             print self.filters[leftfr:rightfr,whichfilt]

		# Build DCT matrix
		self.s2dct = s2dctmat(nfilt, ncep, 1./nfilt)
		self.dct = dctmat(nfilt, ncep, numpy.pi/nfilt)

	def sig2s2mfc(self, sig):
		nfr = int(len(sig) / self.fshift + 1)
		mfcc = numpy.zeros((nfr, self.ncep), 'd')
		fr = 0
		while fr < nfr:
			start = round(fr * self.fshift)
			end = min(len(sig), start + self.wlen)
			frame = sig[start:end]
			if len(frame) < self.wlen:
				frame = numpy.resize(frame,self.wlen)
				frame[self.wlen:] = 0
			mfcc[fr] = self.frame2s2mfc(frame)
			fr = fr + 1
		return mfcc

	def sig2logspec(self, sig):
		nfr = int(len(sig) / self.fshift + 1)
		mfcc = numpy.zeros((nfr, self.nfilt), 'd')
		fr = 0
		while fr < nfr:
			start = round(fr * self.fshift)
			end = min(len(sig), start + self.wlen)
			frame = sig[start:end]
			if len(frame) < self.wlen:
				frame = numpy.resize(frame,self.wlen)
				frame[self.wlen:] = 0
			mfcc[fr] = self.frame2logspec(frame)
			fr = fr + 1
		return mfcc

	def pre_emphasis(self, frame):
		# FIXME: Do this with matrix multiplication
		outfr = numpy.empty(len(frame), 'd')
		outfr[0] = frame[0] - self.alpha * self.prior
		for i in range(1,len(frame)):
			outfr[i] = frame[i] - self.alpha * frame[i-1]
		self.prior = frame[-1]
		return outfr

	def frame2logspec(self, frame):
		frame = self.pre_emphasis(frame) * self.win
		fft = numpy.fft.fft(frame, self.nfft)
		# Square of absolute value
		power = fft.real * fft.real + fft.imag * fft.imag
		return numpy.log(numpy.dot(power, self.filters).clip(1e-5,numpy.inf))

	def frame2s2mfc(self, frame):
		logspec = self.frame2logspec(frame)
		return numpy.dot(logspec, self.s2dct.T) / self.nfilt

def s2dctmat(nfilt,ncep,freqstep):
	"""Return the 'legacy' not-quite-DCT matrix used by Sphinx"""
	melcos = numpy.empty((ncep, nfilt), 'double')
	for i in range(0,ncep):
		freq = numpy.pi * float(i) / nfilt
		melcos[i] = numpy.cos(freq * numpy.arange(0.5, float(nfilt)+0.5, 1.0, 'double'))
	melcos[:,0] = melcos[:,0] * 0.5
	return melcos

def logspec2s2mfc(logspec, ncep=13):
	"""Convert log-power-spectrum bins to MFCC using the 'legacy'
	Sphinx transform"""
	nframes, nfilt = logspec.shape
	melcos = s2dctmat(nfilt, ncep, 1./nfilt)
	return numpy.dot(logspec, melcos.T) / nfilt

def dctmat(N,K,freqstep,orthogonalize=True):
	"""Return the orthogonal DCT-II/DCT-III matrix of size NxK.
	For computing or inverting MFCCs, N is the number of
	log-power-spectrum bins while K is the number of cepstra."""
	cosmat = numpy.zeros((N, K), 'double')
	for n in range(0,N):
		for k in range(0, K):
			cosmat[n,k] = numpy.cos(freqstep * (n + 0.5) * k)
	if orthogonalize:
		cosmat[:,0] = cosmat[:,0] * 1./numpy.sqrt(2)
	return cosmat

def dct(input, K=13):
	"""Convert log-power-spectrum to MFCC using the orthogonal DCT-II"""
	nframes, N = input.shape
	freqstep = numpy.pi / N
	cosmat = dctmat(N,K,freqstep)
	return numpy.dot(input, cosmat) * numpy.sqrt(2.0 / N)

def dct2(input, K=13):
	"""Convert log-power-spectrum to MFCC using the normalized DCT-II"""
	nframes, N = input.shape
	freqstep = numpy.pi / N
	cosmat = dctmat(N,K,freqstep,False)
	return numpy.dot(input, cosmat) * (2.0 / N)

def idct(input, K=40):
	"""Convert MFCC to log-power-spectrum using the orthogonal DCT-III"""
	nframes, N = input.shape
	freqstep = numpy.pi / K
	cosmat = dctmat(K,N,freqstep).T
	return numpy.dot(input, cosmat) * numpy.sqrt(2.0 / K)

def dct3(input, K=40):
	"""Convert MFCC to log-power-spectrum using the unnormalized DCT-III"""
	nframes, N = input.shape
	freqstep = numpy.pi / K
	cosmat = dctmat(K,N,freqstep,False)
	cosmat[:,0] = cosmat[:,0] * 0.5
	return numpy.dot(input, cosmat.T)

def compute_mfcc(wav_data):
    
    mfcc = MFCC(nfilt = 40, ncep = 13, samprate = 8000,
                wlen = 0.0256, frate = 100,
                lowerf=133.33334, upperf=6855.4976)
    mfcc = mfcc.sig2s2mfc(wav_data)
    return mfcc
