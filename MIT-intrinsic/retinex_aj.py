import numpy as np
import os, sys, re, itertools
import html, png, pdb
import intrinsic, comparison

# Use L1 to compute the final results.
USE_L1 = False
#loads a png image and uses all one array as its mask, the png image has to be non-alpha
def load_image(fname):
    reader = png.Reader(fname)
    w, h, pngdata, params = reader.read()
    if params['bitdepth']==16:
        image = np.vstack(itertools.imap(np.uint16, pngdata))
    else:
        image = np.vstack(itertools.imap(np.uint8, pngdata))
    if image.size == 3*w*h:
        image = np.reshape(image, (h, w, 3))
        #    image = image.astype(float) / 255.
    mask = np.ones((h,w))
    return image, mask


def run_experiment(fin):    
    name, estimatorClass = ('Color Retinex (COL-RET)', intrinsic.ColorRetinexEstimator)
    print 'Evaluating %s on %s' % (name, fin)
    sys.stdout.flush()
    params= estimatorClass.param_choices()[21]
    #use {'threshold_color':0.074989420933245579, 'threshold_gray': 1.0}
    estimator = estimatorClass(**params)
    inp = load_image(fin)
    inp = inp + (USE_L1,)
    image = inp[0]
    image = np.mean(image, axis=2)
    est_shading, est_refl = estimator.estimate_shading_refl(*inp)
    est_shading = 255.* est_shading / np.max(est_shading)
    est_refl = 255.* est_refl / np.max(est_refl)    
    return est_shading, est_refl
            
if __name__ == '__main__':
    assert len(sys.argv[1:]) is 2, "accepts 2 inputs: fin fDIR"
    fin, fDIR = sys.argv[1:]
    assert os.path.isdir(fDIR), '%s: directory does not exist' % fDIR
    print 'run color-retinex on: %s write to: %s' % (fin, fDIR)
    L, R = run_experiment(fin)
    html.save_png(R, os.path.join(fDIR, 'R.png'))
    html.save_png(L, os.path.join(fDIR, 'L.png'))
    
            
