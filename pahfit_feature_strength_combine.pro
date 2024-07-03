;+
; NAME:
;
;   PAHFIT_FEATURE_STRENGTH_COMBINE
;
; PURPOSE:
;
;   Combine feature strengths as produced by PAHFIT, taking care of
;   covariance among the features being combined when computing the
;   uncertainty.
;
; REFERENCE:
; 
;   Smith, J.D., Draine B.T., et al., ApJ, 2006, XXX, XXX
;
; CATEGORY:
;
;   IRS Spectral fitting, PAH Emission
;
; CALLING SEQUENCE:
;
;   total_strength=pahfit_feature_strength_combine(decoded, recs,
;                                                  [UNCERTAINTY=])
;
; INPUTS:
;
;   decoded: The decoded fit structure returned by PAHFIT.
;
;   recs: An array of structures with INT_STRENGTH, and CENTRAL_INTEN
;      members, typically taken from the decoded structure,
;      e.g. decoded.dust_features[0:3].
;
; KEYWORD PARAMETERS:
;
;   UNCERTAINTY: The uncertainty in the combined strength (output),
;      with proper accounting for feature covariance.
;      
; OUTPUT:
;
;   The combined feature strength of the individual features/lines
;      passed.
;
; EXAMPLE:
;
;   decoded_fit=pahfit(lam,flux,flux_unc,REDSHIFT=z/PLOT_PROGRESS,/SCREEN)
;   wh=where(decoded_fit.dust_features.wavelength lt 9.)
;   int_pah=pahfit_feature_strength_combine(decoded_fit,
;                                           decoded.dust_features[wh])
;
; MODIFICATION HISTORY:
;
;  2005-07-01 (JD Smith & Bruce Draine): Written.
;-
;##############################################################################
;
; LICENSE
;
;  Copyright (C) 2005-2006 J.D. Smith
;
;  This file is part of PAHFIT.
;
;  PAHFIT is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2, or (at your option)
;  any later version.
;
;  PAHFIT is distributed in the hope that it will be useful, but
;  WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with PAHFIT; see the file COPYING.  If not, write to the Free
;  Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;  MA 02110-1301, USA.
;
;##############################################################################


;=========================================================================
;  pahfit_feature_strength_combine - Add two or more feature strengths
;                                    together and compute the
;                                    resulting uncertainty, assuming
;                                    non-zero covariance only between
;                                    their central intensities.  Pass
;                                    the full decoded structure, and
;                                    the desired "lines" and/or
;                                    "dust_features" structures to
;                                    combine.
;=========================================================================
function pahfit_feature_strength_combine,decoded,recs,UNCERTAINTY=unc
  
  if n_elements(recs) eq 1 then begin 
     unc=recs.int_strength_unc
     return,recs.int_strength
  endif 
  
  strength=total(recs.int_strength,/NAN)
  cov=decoded.covariance

  
  fac=recs.int_strength/recs.central_inten ;presume ~constant pre-factors
  
  inds=recs.parinfo_covar_index ;original parinfo indices
  n=n_elements(inds) 
  x=rebin(inds,n,n)
  y=rebin(transpose(inds),n,n)
  
  ;; prefacs are fac_a^2 var(a) + 2 fac_a_b cov(a,b)
  fac=rebin(fac,n,n)*rebin(transpose(fac),n,n)
  
  ;; var(x+y)=var(x)+var(y)+2cov(x,y)
  ;; cov(x,y)=cov(y,x) and here we double all off-diagonal elements.
  ;; cov(x,x)=var(x) and take a single diagonal element, resulting in:
  unc=sqrt(total(fac*cov[x,y],/NAN))
  return,strength
end

