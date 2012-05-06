import numpy as np
import os
import sys, re
import itertools
import html
import intrinsic
import comparison
import png
import pdb
# The following objects were used in the evaluation. For the learning algorithms
# (not included here), we used two-fold cross-validation with the following
# randomly chosen split.
images = ['baby','flower', 'fruits', 'teabag', 'rose', 'shoes', 'testface', 'bsr'];
images = ['fruits', 'teabag', 'shoes', 'testface', 'bsr'];
ALL_TAGS = map(lambda x: x+'.png', images)#SET1 + SET2
DATA_DIR = '../data/images';#'../data/MITimages/'; #'data';
# Use L1 to compute the final results. (For efficiency, the parameters are still
# tuned using least squares.)
USE_L1 = False

TRY_ALL_PARAM = True

# Output of the algorithms will be saved here
if USE_L1:
    RESULTS_DIR = 'results_L1'
else:
    RESULTS_DIR = 'testResults'

#loads a png image and uses all one array as its mask, the png image has to be non-alpha
def load_image(name):
    fname = os.path.join(DATA_DIR, name)
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


def run_experiment():
    """Script for running the algorithmic comparisons from the paper

        Roger Grosse, Micah Johnson, Edward Adelson, and William Freeman,
          Ground truth dataset and baseline evaluations for intrinsic
          image algorithms.

    Evaluates each of the algorithms on the MIT Intrinsic Images dataset
    with hold-one-out cross-validation.
    
    For each algorithm, it precomputes the error scores for all objects with
    all parameter settings. Then, for each object, it chooses the parameters
    which achieved the smallest average error on the other objects. The
    results are all output to the HTML file results/index.html."""
    
    assert os.path.isdir(RESULTS_DIR), '%s: directory does not exist' % RESULTS_DIR

    name, estimatorClass = ('Color Retinex (COL-RET)', intrinsic.ColorRetinexEstimator)
    tags = ALL_TAGS
    ntags = len(tags)
    print 'Evaluating %s' % name
    sys.stdout.flush()

    
    choices = estimatorClass.param_choices()
    nchoices = len(choices)

    # Try all parameters on all the objects
    if TRY_ALL_PARAM:
        for i, tag in enumerate(tags):
            gen = html.Generator('Intrinsic image results', re.split('\.', tag)[0])
            gen.heading(tag)
            inp = load_image(tag)            
            image = inp[0]
            gen.image(image)
            gen.divider()
            image = np.mean(image, axis=2)
            for j, params in enumerate(choices):
                estimator = estimatorClass(**params)
                est_shading, est_refl = estimator.estimate_shading_refl(*inp)
                gen.text('%d: %s' % (j, str(params)))
                comparison.save_estimates(gen, image, est_shading, est_refl, inp[1])
                gen.divider()        
            gen.divider()        
    else:
        gen = html.Generator('Intrinsic image results', RESULTS_DIR)
        gen.heading(name)    
        for i, tag in enumerate(tags):
            inp = load_image(tag)
            inp = inp + (USE_L1,)
            image = inp[0]
            image = np.mean(image, axis=2)
            params = choices[20] #random for now
            estimator = estimatorClass(**params)
            est_shading, est_refl = estimator.estimate_shading_refl(*inp)            
            comparison.save_estimates(gen, image, est_shading, est_refl, inp[1])
            gen.divider()

if __name__ == '__main__':
    run_experiment()
