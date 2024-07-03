# PAHFIT
The Classic IDL-based PAHFIT

This respository contains the last published version of "classic" IDL-based PAHFIT.  See the [new Python-based PAHFIT](../../../pahfit) for a more modern version of PAHFIT. 

<p>
PAHFIT is an IDL tool for decomposing <a href="spitzer.php">Spitzer</a>
IRS spectra of PAH emission sources, with a special emphasis on the
careful recovery of ambiguous silicate absorption, and weak, blended
dust emission features.  PAHFIT is primarily designed for use with full
5-35 micron Spitzer low-resolution IRS spectra.

<p>
PAHFIT uses a simple, physically-motivated model, consisting of
starlight, thermal dust continuum in a small number of fixed temperature
bins, resolved dust features and feature blends, prominent emission
lines (which themselves can be blended with dust features), as well as
simple fully-mixed or screen dust extinction, dominated by the silicate
absorption bands at 9.7 and 18 microns.  Most model components are held
fixed or are tightly constrained.

<p>
The model was trained on a large set of high quality IRS spectra
extracted over the central few square kpc of nearby galaxies drawn from
the <a href="sings.php">SINGS</a> Spitzer Legacy Project.  Since
positions of the PAH bands do not shift significantly, it should also be
perfectly capable of decomposing any spectrum with PAH emission, as long
as the continuum model (fixed temperature starlight and thermal dust up
to 300K) is compatible.

<p>
Note in particular that PAHFIT uses Drude profiles to recover the
full strength of dust emission features and blends, including the
significant power in the wings of the broad emission profiles.  This
means the resulting feature strengths are larger (by factors of 2-4)
than are recovered by methods which estimate the underlying continuum
using line segments or spline curves fit through fiducial wavelength
anchors.  See the paper below for a more thorough comparison of these
methods.

<p>
<font color=red>NOTA BENE: PAHFIT v1.2 overestimates line fluxes
by a constant factor of 1+z, which can be significant for
high-redshift sources.</font>  To avoid this, you can shift your wavelength and spectrum into the rest
frame yourself before fitting.

<p>
<font color=red>NOTA BENE #2: There is a slight bug in the
calculation of dust feature equivalent widths, causing them to be low by
a factor of 1.4 (assuming them Gaussian rather than Drude).</font> Both
will be fixed in an upcoming release.

<h2>Reference</h2>

<dl>
  <dt>PAHFIT is described in detail in:
  <dd> Smith, J.D.T., Draine B.T., et al., 2007, <a href="
https://iopscience.iop.org/article/10.1086/510549/fulltext/65289.html"><b>ApJ</b>,
      656, 770</a></samp> [<a href="download/pah_template_final_apj.pdf">PDF</a>]
</dl>

<p>
See also the set of 5 <a
href="https://iopscience.iop.org/article/10.1086/510549/fulltext/datafile8.txt">noise-free
galaxy templates</a> mentioned in the paper.

<h2>Access</h2>

PAHFIT is available under the terms of the GNU General Public License.
Published use of results from PAHFIT should include the above reference.

<h2>Download</h2>

PAHFIT is currently at version 1.2, and requires:

<ol>
  <li> <a href="http://ittvis.com/idl/">IDL</a> version 6.0 or later.
  <li> Craig Markwardt's <a
href="http://cow.physics.wisc.edu/~craigm/idl/fitting.html">MPFIT
library</a>, with modification date of 2003 or later.  
  <li> The <a href="http://idlastro.gsfc.nasa.gov/">AstroLib library</a>
  from NASA Goddard (which has <em>many</em> useful astronomy-related
  routines).
</ol>

<p>
Download <a href="download/pahfit_v1.2.tar.gz">PAHFIT</a>

<h2>Install</h2>

Simply unpack the PAHFIT package in a directory on your
<samp>IDL_PATH</samp>.

<h2>Using PAHFIT</h2>

PAHFIT is straightforward to use.  First, assemble a full matched IRS
low resolution spectrum (including uncertainty), by averaging the
spectrum in the regions of wavelength overlap.  A recommended technique
is to compare two orders in the region of overlap using a median or
short linear segment, then scale SL2 to SL1, LL2 to LL1, and SL to LL.
Alternatively, the segments can be scaled to their mean in the overlap
region.  Note that segment offsets larger than 10% can impact the shape
and feature strength of the recovered PAH bands, and that PAHFIT does
not account for this source of uncertainty.

<p>
Invoke PAHFIT like:

<p>
<code>IDL> fit=pahfit(obs_lam, flux, flux_unc, REDSHIFT=cz, /PLOT_PROGRESS,
                      XSIZE=1000, YSIZE=600, /SCREEN, /REPORT)
</code>

<p> where <samp>obs_lam</samp> is a vector containing the observed-frame
wavelength, <samp>flux</samp> and <samp>flux_unc</samp> are vectors
containing the flux (or flux intensity) and uncertainty in
<samp>f_nu</samp> units (MJy/sr, by default), <samp>cz</samp> is the
redshift in <samp>km/s</samp> (defaults to zero).  The boolean keyword
flag <samp>/PLOT_PROGRESS</samp> will show an interactive view of the
fit as it improves, while <samp>/REPORT</samp> generates a text report
of the recovered fit parameters.  All fits are performed in the rest
frame.  Note that many of PAHFIT's associated tools take wavelength in
the rest frame, rather than observed frame wavelengths and redshift.

<p> The returned <samp>fit</samp> structure contains a large number of
decomposed parameters fit to the spectrum, including central
wavelengths, FWHM, integrated feature strengths, and equivalent widths
for all the various lines and dust features, as well as strengths of
continuum components and mixed or screen extinction optical depth.
See the header of the file <samp>pahfit.pro</samp> for more
information on this structure, and other calling options.

<p> Note that all fit results are in the rest frame, except equivalent
width, which is computed directly on the rest-frame spectrum, but is not
diluted by <tt>1+z</tt>.


<h2>Troubleshooting</h2>


<dl>
  <dt>After an apparently successful fit run, I get an error like:

<pre>
% Variable is undefined: DF.
% Execution halted at: PAHFIT           1237
</pre>

  <dd>You have an out of date version of MPFIT.  You need a version with
  last modification date of 2003 or later.  Get it <a
  href="http://cow.physics.wisc.edu/~craigm/idl/down/mpfit.tar.gz">here</a>.
  Note that SMART comes with two embedded versions of MPFIT which are
  out of date.  Ensure that you have a more recent version on the
  <tt>IDL_PATH</tt> before the SMART directories (or just move SMART
  away temporarily).
</dl>

<h2>Caveats</h2> 

PAHFIT was developed to recover faint and blended PAH, line, and
silicate features by training on a set of nearby predominantly
star-forming galaxy spectra.  It does not consider contributions from
very hot (~1000K) dust in strong AGN, and may not recover appropriate
continuum levels in these types of sources.  It also does not treat or
recover silicate emission (from AGN tori or the integrated dust
signature of AGB star winds), nor does it consider hydro-carbon, water
and CO ice absorption sometimes seen in very deeply embedded sitelines,
in the Galaxy and some classes of extragalactic objects
(e.g. high-extinction ULIRGs).

<p>The default set of lines and features chosen, the form and
flexibility of the continuum components, and the shape of the extinction
curve are all appropriate for galaxies and Galactic regions dominated by
star-formation.  That said, it is entirely possible to append to the
line list, fit additional continuum components, or substitute
alternative extinction curves; see advanced usage, below.

</p><b>If using PAHFIT on spectra with more limited rest-frame coverage
(e.g. only LL1), be aware that a profound degeneracy exists between
silicate absorption and PAH emission in the rest-frame 7-12um range.  In
this case, try your fits with and without the <tt>/NO_EXTINCTION</tt>
keyword (see below) to bracket this uncertainty.</b>


<h2>Advanced PAHFIT Usage</h2>

PAHFIT is a flexible tool for fitting spectra, and you can add or
disable features, compute combined flux bands, change fitting limits,
etc., without changing the code.  Here we present a few examples of
these methods.

<h3>Combining dust features</h3>

Many dust features are blended, sometimes separably (17um complex),
sometimes profoundly (e.g. the 7um complex).  To combine the fitted
strengths, use PAHFIT_MAIN_FEATURE_POWER:

<pre>
IDL> main_features=pahfit_main_feature_power(fit,lam_rest,flux,flux_uncertainty)
</pre>

where <tt>fit</tt> is the fit structure returned by a call to
<tt>PAHFIT</tt>, <tt>lam_rest, flux, flux_uncertainty</tt> are the rest
wavelength and flux with uncertainty used to produce the fit.  The
returned <tt>main_features</tt>structure will contain combined feature
powers for the most prominent dust features, taking into account the
correlation between blended features to compute accurate error estimate.
You can also compute the main feature powers for many fits at once by
passing multiple fit structures as a vector, and arrays for wavelength,
flux, etc. of matching length.  See PAHFIT_MAIN_FEATURE_POWER.

<h3>Modifying the Fit Parameters</h3>

You can modify PAHFIT parameters in several ways.  The simplest is to
use the keywords provided for making several common modifications.
E.g. <samp>STARLIGHT_TEMPERATURE</samp>,
<samp>CONTINUUM_TEMPERATURES</samp>, <samp>LINES</samp>,
<samp>DUST_FEATURES</samp>, <samp>NO_EXTINCTION</samp>.  The latter is a
boolean determining whether to fix the silicate extinction optical depth
to zero.  The former two are structures defining the line and dust
features to be fit (see PAHFIT), and the first two are simple thermal
dust and effective stellar temperatures for fitting the continuum.  See
PAHFIT (header documentation of pahfit.pro).

<p>A more powerful method to modify the fit relates to the
<samp>PARINFO</samp> structure, documented on the <a
href="http://cow.physics.wisc.edu/~craigm/idl/down/mpfitfun.pro">MPFIT
pages</a> (see CONSTRAINING PARAMETER VALUES WITH THE PARINFO KEYWORD).
PAHFIT can be seeded with an arbitrary PARINFO structure, and can return
the default structure without any fitting, for modification.  An example
of fixing the fitting details except for several dust features:

<pre>
IDL> void=pahfit(lam,PARINFO=parinfo,/NO_FIT) ; get parinfo default
IDL> w=where(stregex(parinfo.parname,'dust_feature_(lam|cen|frac).*\[1[67]\.',/BOOLEAN)
IDL> parinfo.fixed=1b & parinfo[w].fixed=0b
IDL> fit17=pahfit(lam,flux,error,REDSHIFT=cz,/PLOT_PROGRESS,PARINFO=parinfo,ITERARGS={XRANGE:[15,20]})
</pre>

This takes the standard parameter info structure, fixes all features
except the 17um complex, and performs the fit with those constraints.
Using the same method, you could zero out paramters, change, remove, or
add fitting limits, etc.  You might prefer to start with an existing fit
and make modifications.  The list of PAHFIT's default parameter info
names, which can be used to select parameters for modification in this
way, can be found with:

<pre>
IDL> void=pahfit(lam,PARINFO=parinfo,/NO_FIT) & print,parinfo.parname
</pre>

<h3>Plotting PAHFIT fit results</h3>

The PAHFIT_PLOT procedure allows you to plot saved fits, for example to
save to postscript with object and chi_square labels.

<pre>
!P.THICK=2
set_plot,'PS' & device,/ENCAPSULATED,/COLOR,FILENAME='fit.eps'
pahfit_plot,pahfit,lambda_rest,flux,flux_uncertainty, TITLE='My Object Fit', $
            POSITION=[.13,.12,.9,.92],SYMSIZE=0.4
xyouts,.85,.85,/NORMAL,ALIGNMENT=1.0,string(FORMAT='(%"red. chi-sq: %8.3f")',pahfit.reduced_chi_sq)
device,/close & set_plot,'X'
</pre>

<h2>Quick-start guide for non-IDL users</h2>

Users who aren't familiar with IDL should be able to use PAHFIT without
undue difficulty.  The main concern is to allow IDL to find and compile
the PAHFIT code.  To accomplish this, you need to place it on your
<samp>IDL_PATH</samp>.  You can set this environment variable to point to
locations of interest, e.g.:

<pre>
setenv IDL_PATH setenv IDL_PATH "<IDL_DEFAULT>:+${HOME}/idl"
</pre>

which adds to the IDL default paths <samp>~/idl</samp>.  Anything under this
directory containing <samp>.pro</samp> files will be auto-discovered.

<p>
A complete session for reading a spectrum from a text file, running
PAHFIT, and saving the results is below.  This requires the installation
of the excellent <a href="http://idlastro.gsfc.nasa.gov/">IDL astronomy
user's library</a>, a good resource for many astronomy related IDL
capabilities.

<pre>
IDL> cd,'/path/to/spectra'
IDL> rdfloat,'spectrum.txt',lambda,flux,error,SKIPLINE=2
IDL> fit=pahfit(lambda,flux,error,REDSHIFT=250.,/PLOT_PROGRESS,REPORT='pahfit.txt')
</pre>


<h2>Feedback</h2>

Feedback on the performance of PAHFIT with your spectra is very much
appreciated (email below). 
